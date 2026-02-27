import 'package:flutter/material.dart';
import 'package:moosyl_flutter/src/helpers/exception_handling/error_handlers.dart';
import 'package:moosyl_flutter/src/models/payment_method_model.dart';
import 'package:moosyl_flutter/src/models/payment_request_model.dart';
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

  /// A map of custom icons for specific payment method types.
  final Map<PaymentMethodTypes, String>? customIcons;

  /// The payment method selected for the payment process.
  PaymentMethod? selected;

  /// Whether the app is in testing mode.
  final bool isTestingMode;

  /// The payment method selected in the list (radio) before confirming with Pay.
  PaymentMethod? pendingSelection;

  /// Error to show on payment method selection when validation fails.
  String? selectionError;

  /// Constructs a [GetPaymentMethodsProvider].
  GetPaymentMethodsProvider({
    required this.publishableApiKey,
    required this.transactionId,
    required this.totalAmount,
    required this.isTestingMode,
    required this.customIcons,
  }) {
    getMethods();
    getPaymentRequest();
  }

  /// Holds any error messages that occur during method retrieval.
  Object? error;

  /// Indicates whether the provider is currently loading data.
  bool isLoading = false;

  /// Indicates whether validation is in progress (fetching payment request).
  bool isValidating = false;

  /// List of available payment methods.
  final List<PaymentMethod> methods = [];

  /// The payment request model.
  PaymentRequestModel? paymentRequest;

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
  Future<PaymentMethod?> setPaymentMethodWithValidation(PaymentMethod method) async {
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

    final isDialogMethod = method.method == PaymentMethodTypes.sedad ||
        method.method == PaymentMethodTypes.bimBank ||
        method.method == PaymentMethodTypes.bankily;

    if (isDialogMethod) {
      return method;
    }

    setPaymentMethod(method);
    return null;
  }

  /// Retrieves the list of supported payment method types.
  List<PaymentMethodTypes> get supportedTypes {
    return [...methods.map((method) => method.method)];
  }

  /// Retrieves the list of valid payment method types, including custom handlers.
  List<PaymentMethodTypes> get validMethods =>
      [...methods.map((e) => e.method)];

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

    final selected = methods.firstWhere((element) => element.method == type);

    setPaymentMethod(selected);
  }

  /// Sets the selected payment method (confirms and proceeds to payment).
  void setPaymentMethod(PaymentMethod? method) {
    selected = method;
    pendingSelection = method;
    notifyListeners();
  }

  /// Sets the pending selection (radio choice before Pay is tapped).
  void setPendingSelection(PaymentMethod? method) {
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
    final result = await ErrorHandlers.catchErrors(
      () => GetPaymentRequestService(publishableApiKey).get(transactionId),
      showFlashBar: false,
    );

    paymentRequest = result.result;

    notifyListeners();
  }
}
