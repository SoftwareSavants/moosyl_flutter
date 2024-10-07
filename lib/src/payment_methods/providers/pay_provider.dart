import 'dart:async';
import 'dart:nativewrappers/_internal/vm/lib/ffi_allocation_patch.dart';

import 'package:flutter/material.dart';
import 'package:software_pay/src/helpers/exception_handling/error_handlers.dart';
import 'package:software_pay/src/payment_methods/models/operation_model.dart';
import 'package:software_pay/src/payment_methods/models/payment_method_model.dart';
import 'package:software_pay/src/payment_methods/services/get_operation_service.dart';
import 'package:software_pay/src/payment_methods/services/pay_service.dart';

/// A provider class for handling payment operations.
///
/// This class extends [ChangeNotifier] to notify listeners about changes
/// in the payment operation state, including loading status and errors.
class PayProvider extends ChangeNotifier {
  /// The API key used for authentication with the payment services.
  final String apiKey;

  /// The ID of the operation being processed.
  final String operationId;

  /// The context used for displaying error messages.
  final BuildContext context;

  /// The payment method used for the operation.
  final PaymentMethod method;

  /// Callback function that gets called on successful payment.
  final FutureOr<void> Function()? onPaymentSuccess;

  /// Constructs a [PayProvider].
  ///
  /// Initiates fetching the operation details upon creation.
  PayProvider({
    required this.apiKey,
    required this.method,
    required this.operationId,
    required this.context,
    this.onPaymentSuccess,
  }) {
    getOperation();
  }

  /// Text controller for inputting the passcode.
  final passCodeTextController = TextEditingController();

  /// Text controller for inputting the phone number.
  final phoneNumberTextController = TextEditingController();

  /// Key for the payment form.
  final formKey = GlobalKey<FormState>();

  /// Holds the operation details.
  OperationModel? operation;

  /// Holds any error messages that occur during payment processing.
  String? error;

  /// Indicates whether the provider is currently loading data.
  bool isLoading = false;

  /// Asynchronously fetches operation details from the service.
  ///
  /// Updates the loading state and handles any errors that occur during
  /// the fetching process. Notifies listeners when the data changes.
  void getOperation() async {
    error = null;
    isLoading = true;

    final result = await ErrorHandlers.catchErrors(
      () => GetOperationService(apiKey).get(operationId),
      showFlashBar: false,
      context: context,
    );

    isLoading = false;

    if (result.isError) {
      error = result.error;
      return notifyListeners();
    }

    // Set the operation details from the result.
    operation = result.result;

    // Notify listeners of the change in operation details.
    notifyListeners();
  }

  /// Processes the payment for the operation.
  ///
  /// Validates the form, sets the loading state, and calls the payment service.
  /// If payment is successful, it invokes the [onPaymentSuccess] callback.
  void pay(BuildContext context) async {
    if (!formKey.currentState!.validate()) return; // Ensure the form is valid.

    error = null;
    isLoading = true;
    notifyListeners();

    final result = await ErrorHandlers.catchErrors(
      () => PayService(apiKey).pay(
        operationId: operationId,
        paymentMethodId: method.id,
        passCode: passCodeTextController.text,
        phoneNumber: phoneNumberTextController.text,
      ),
      context: context,
    );

    isLoading = false;

    if (result.isError) {
      error = result.error;
      return notifyListeners();
    }

    notifyListeners();

    // Call the success callback if the payment was successful.
    if (error != null) return;

    await onPaymentSuccess.call();

    if (context.mounted) {
      Navigator.pop(context);
      Navigator.pop(context);
    }
  }
}
