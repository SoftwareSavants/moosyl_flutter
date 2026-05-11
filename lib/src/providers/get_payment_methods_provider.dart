import 'package:flutter/material.dart';
import 'package:moosyl/moosyl.dart';
import 'package:moosyl_flutter/src/helpers/exception_handling/error_handlers.dart';
import 'package:moosyl_flutter/src/models/payment_method_model.dart';
import 'package:moosyl_flutter/src/services/get_payment_methods_service.dart';
import 'package:moosyl_flutter/src/services/get_payment_request_service.dart';

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

  /// Constructs a [GetPaymentMethodsProvider].
  GetPaymentMethodsProvider({
    required this.publishableApiKey,
    this.transactionId = '',
    required this.totalAmount,
  }) {
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
  /// For Sedad/Bankily: returns the method to show dialog (caller shows dialog).
  /// For Masrivi etc: calls setPaymentMethod and returns null.
  /// On validation error: returns null and sets selectionError.
  Future<ConfigurationListDataInner?> setPaymentMethodWithValidation(
      ConfigurationListDataInner method) async {
    selectionError = null;
    isValidating = true;
    notifyListeners();

    final result = await ErrorHandlers.catchErrors(
      () => GetPaymentRequestService(publishableApiKey).get(transactionId),
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

    final isDialogMethod = PaymentMethodTypes.fromString(method.type) ==
            PaymentMethodTypes.sedad ||
        PaymentMethodTypes.fromString(method.type) ==
            PaymentMethodTypes.bimBank ||
        PaymentMethodTypes.fromString(method.type) ==
            PaymentMethodTypes.bankily;

    if (isDialogMethod) {
      return method;
    }

    setPaymentMethod(method);
    return null;
  }

  /// Retrieves the list of supported payment method types.
  List<PaymentMethodTypes> get supportedTypes {
    return [
      ...methods.map((method) => PaymentMethodTypes.fromString(method.type))
    ];
  }

  /// Retrieves the list of valid payment method types, including custom handlers.
  List<PaymentMethodTypes> get validMethods =>
      [...methods.map((e) => PaymentMethodTypes.fromString(e.type))];

  /// Asynchronously fetches available payment methods from the service.
  ///
  /// Updates the loading state and handles any errors that occur during
  /// the fetching process. Notifies listeners when the data changes.
  void getMethods() async {
    error = null;
    isLoading = true;
    notifyListeners();

    final result = await ErrorHandlers.catchErrors(
      () => GetPaymentMethodsService(publishableApiKey).get(),
      showFlashBar: false,
    );

    isLoading = false;

    if (result.isError) {
      error = result.error;

      return notifyListeners();
    }

    // Add the retrieved methods to the methods list.
    methods.addAll(result.result!);
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
        (element) => PaymentMethodTypes.fromString(element.type) == type);

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
      () => GetPaymentRequestService(publishableApiKey).get(transactionId),
      showFlashBar: false,
    );

    paymentRequest = result.result;

    notifyListeners();
  }
}
