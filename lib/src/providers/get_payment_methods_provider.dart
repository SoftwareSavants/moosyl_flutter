import 'package:flutter/material.dart';
import 'package:moosyl/moosyl.dart';
import 'package:moosyl_flutter/src/gimtel/gimtel_api.dart';
import 'package:moosyl_flutter/src/helpers/exception_handling/error_handlers.dart';
import 'package:moosyl_flutter/src/models/payment_method_model.dart';
import 'package:moosyl_flutter/src/services/get_payment_methods_service.dart';
import 'package:moosyl_flutter/src/services/get_payment_request_service.dart';
import 'package:moosyl_flutter/src/services/pay_service.dart';

/// A provider class for managing and retrieving payment methods.
///
/// This class extends [ChangeNotifier] to notify listeners about changes
/// in the payment methods' loading state and results.
class GetPaymentMethodsProvider extends ChangeNotifier {
  /// The API key used for authentication with the payment methods service.
  final String publishableApiKey;

  /// The transaction ID for payment request validation.
  final String transactionId;

  /// The total amount to validate against payment request.
  final double totalAmount;

  /// The payment method selected for the payment process.
  ConfigurationListDataInner? selected;

  /// The payment method selected in the list (radio) before confirming with Pay.
  ConfigurationListDataInner? pendingSelection;

  /// Error to show on payment method selection when validation fails.
  String? selectionError;

  /// Fetches the configured payment methods.
  final GetPaymentMethodsService methodsService;

  /// Fetches the payment request being paid.
  final GetPaymentRequestService requestService;

  /// Submits native (passcode / payment code) payments.
  final PayService payService;

  /// Backend of the Gimtel payment sheet.
  final GimtelApi gimtelApi;

  /// Constructs a [GetPaymentMethodsProvider].
  ///
  /// The services default to the live Moosyl API; pass them only to
  /// substitute the network (e.g. in tests).
  GetPaymentMethodsProvider({
    required this.publishableApiKey,
    this.transactionId = '',
    required this.totalAmount,
    GetPaymentMethodsService? methodsService,
    GetPaymentRequestService? requestService,
    PayService? payService,
    GimtelApi? gimtelApi,
  })  : methodsService =
            methodsService ?? GetPaymentMethodsService(publishableApiKey),
        requestService =
            requestService ?? GetPaymentRequestService(publishableApiKey),
        payService = payService ?? PayService(publishableApiKey),
        gimtelApi = gimtelApi ?? MoosylGimtelApi(publishableApiKey) {
    getMethods();
    if (transactionId.isNotEmpty) {
      getPaymentRequest();
    }
  }

  /// Holds any error messages that occur during method retrieval.
  Object? error;

  /// Indicates whether the provider is currently loading data.
  bool isLoading = false;

  /// Indicates whether validation is in progress (fetching payment request).
  bool isValidating = false;

  /// List of available payment methods.
  final List<ConfigurationListDataInner> methods = [];

  /// The payment request model.
  PaymentRequestGetData? paymentRequest;

  /// Clears the selection error.
  void clearSelectionError() {
    if (selectionError != null) {
      selectionError = null;
      notifyListeners();
    }
  }

  /// Validates payment request and sets or returns the payment method.
  /// For Gimtel methods, Sedad, BIM Bank and native Bankily: returns the
  /// method so the caller shows its sheet/dialog.
  /// For Masrivi etc: calls setPaymentMethod and returns null.
  /// On validation error: returns null and sets selectionError.
  Future<ConfigurationListDataInner?> setPaymentMethodWithValidation(
      ConfigurationListDataInner method) async {
    selectionError = null;
    isValidating = true;
    notifyListeners();

    final result = await ErrorHandlers.catchErrors(
      () => requestService.get(transactionId),
      showFlashBar: false,
    );

    isValidating = false;

    if (result.isError) {
      selectionError = result.error?.toString();
      notifyListeners();
      return null;
    }

    final paymentRequest = result.result!;
    this.paymentRequest = paymentRequest;

    if (paymentRequest.amount == 0) {
      selectionError = 'paymentRequestFullyPaid';
      notifyListeners();
      return null;
    }

    if (totalAmount > 0 && (totalAmount - paymentRequest.amount).abs() > 0.01) {
      selectionError = 'amountToPayShouldMatchPaymentRequest';
      notifyListeners();
      return null;
    }

    // Gimtel methods open the Gimtel sheet; Sedad/BIM Bank/native Bankily
    // open their dialogs. The caller shows either.
    final type = PaymentMethodTypes.tryParse(method.type);
    final isDialogMethod = isGimtelMethod(method) ||
        type == PaymentMethodTypes.sedad ||
        type == PaymentMethodTypes.bimBank ||
        type == PaymentMethodTypes.bankily;

    if (isDialogMethod) {
      return method;
    }

    setPaymentMethod(method);
    return null;
  }

  /// Retrieves the list of supported payment method types.
  List<PaymentMethodTypes> get supportedTypes {
    return [
      ...methods
          .map((method) => PaymentMethodTypes.tryParse(method.type))
          .whereType<PaymentMethodTypes>()
    ];
  }

  /// Retrieves the list of valid payment method types, including custom handlers.
  List<PaymentMethodTypes> get validMethods =>
      [...methods.map((e) => PaymentMethodTypes.tryParse(e.type)).whereType()];

  /// Asynchronously fetches available payment methods from the service.
  ///
  /// Updates the loading state and handles any errors that occur during
  /// the fetching process. Notifies listeners when the data changes.
  void getMethods() async {
    error = null;
    isLoading = true;
    notifyListeners();

    final result = await ErrorHandlers.catchErrors(
      () => methodsService.get(),
      showFlashBar: false,
    );

    isLoading = false;

    if (result.isError) {
      error = result.error;

      return notifyListeners();
    }

    // Add the retrieved methods, skipping types this SDK version doesn't
    // know (a newer backend may offer methods an older app can't render).
    methods.addAll(result.result!
        .where((method) => PaymentMethodTypes.tryParse(method.type) != null));
    // Notify listeners of the change in payment methods.
    notifyListeners();
  }

  /// Handles tap events for selecting a payment method type.
  ///
  /// If a custom handler is defined for the tapped payment method,
  /// it invokes the handler. Otherwise, it selects the corresponding
  /// payment method from the list and calls the [onSelected] callback.
  void onTap(PaymentMethodTypes type, BuildContext context) async {
    // Find and select the payment method from the list.

    final selected = methods.firstWhere(
        (element) => PaymentMethodTypes.tryParse(element.type) == type);

    setPaymentMethod(selected);
  }

  /// Sets the selected payment method (confirms and proceeds to payment).
  void setPaymentMethod(ConfigurationListDataInner? method) {
    selected = method;
    pendingSelection = method;
    notifyListeners();
  }

  /// Sets the pending selection (radio choice before Pay is tapped).
  void setPendingSelection(ConfigurationListDataInner? method) {
    pendingSelection = method;
    clearSelectionError();
    notifyListeners();
  }

  /// Confirms the pending selection and proceeds to payment.
  void confirmSelection() {
    if (pendingSelection != null) {
      setPaymentMethod(pendingSelection);
    }
  }

  /// Updates the payment request details and notifies listeners when the data changes.
  void getPaymentRequest() async {
    if (transactionId.isEmpty) {
      return;
    }

    final result = await ErrorHandlers.catchErrors(
      () => requestService.get(transactionId),
      showFlashBar: false,
    );

    paymentRequest = result.result;

    notifyListeners();
  }
}
