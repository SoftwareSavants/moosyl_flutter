import 'dart:async';
import 'package:flutter/material.dart';
import 'package:moosyl/src/helpers/exception_handling/error_handlers.dart';
import 'package:moosyl/src/models/payment_request_model.dart';
import 'package:moosyl/src/models/payment_method_model.dart';
import 'package:moosyl/src/services/get_payment_request_service.dart';
import 'package:moosyl/src/services/pay_service.dart';

/// A provider class for handling payment payment requests.
///
/// This class extends [ChangeNotifier] to notify listeners about changes
/// in the payment payment request state, including loading status and errors.
class AutomaticPayProvider extends ChangeNotifier {
  /// The API key used for authentication with the payment services.
  final String authorization;

  /// The ID of the payment request being processed.
  final String transactionId;

  /// The payment method selected for the payment process.
  final PaymentMethod method;

  /// Callback function that gets called on successful payment.
  final FutureOr<void> Function()? onPaymentSuccess;

  /// Constructs a [AutomaticPayProvider].
  ///
  /// Initiates fetching the payment request details upon creation.
  AutomaticPayProvider({
    required this.authorization,
    required this.transactionId,
    this.onPaymentSuccess,
    required this.method,
  }) : service = PayService(authorization) {
    getPaymentRequest();
  }

  /// Text controller for inputting the passcode.
  final passCodeTextController = TextEditingController();

  /// Text controller for inputting the phone number.
  final phoneNumberTextController = TextEditingController();

  /// Key for the payment form.
  final formKey = GlobalKey<FormState>();

  /// Holds the payment request details.
  PaymentRequestModel? paymentRequest;

  /// Holds any error messages that occur during payment processing.
  Object? error;

  /// Indicates whether the provider is currently loading data.
  bool isLoading = false;

  /// The payment service used for processing payments.
  final PayService service;

  /// Asynchronously fetches payment request details from the service.
  ///
  /// Updates the loading state and handles any errors that occur during
  /// the fetching process. Notifies listeners when the data changes.
  void getPaymentRequest() async {
    error = null;
    isLoading = true;
    notifyListeners();

    final result = await ErrorHandlers.catchErrors(
      () => GetPaymentRequestService(authorization).get(transactionId),
      showFlashBar: false,
    );

    isLoading = false;

    if (result.isError) {
      error = result.error;
      return notifyListeners();
    }

    // Set the payment request details from the result.
    paymentRequest = result.result;
    phoneNumberTextController.text = paymentRequest!.phoneNumber ?? '';

    // Notify listeners of the change in payment request details.
    notifyListeners();
  }

  /// Processes the payment for the payment request.
  ///
  /// Validates the form, sets the loading state, and calls the payment service.
  /// If payment is successful, it invokes the [onPaymentSuccess] callback.
  void pay(BuildContext context) async {
    if (!formKey.currentState!.validate()) return; // Ensure the form is valid.

    error = null;
    isLoading = true;
    notifyListeners();

    final result = await ErrorHandlers.catchErrors(
      () => service.pay(
        transactionId: transactionId,
        paymentMethodId: method.id,
        passCode: passCodeTextController.text,
        phoneNumber: phoneNumberTextController.text,
      ),
    );

    isLoading = false;

    if (result.isError) {
      error = result.error;
      return notifyListeners();
    }

    if (context.mounted) {
      Navigator.pop(context);
    }

    await onPaymentSuccess?.call();
  }
}
