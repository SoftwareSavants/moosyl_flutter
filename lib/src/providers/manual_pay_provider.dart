import 'dart:async';
import 'package:file_picker/file_picker.dart';
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
class ManualPayProvider extends ChangeNotifier {
  /// The API key used for authentication with the payment services.
  final String apiKey;

  /// The ID of the payment request being processed.
  final String transactionId;

  /// The payment method used for the payment request.

  /// Callback function that gets called on successful payment.
  final FutureOr<void> Function()? onPaymentSuccess;

  /// The payment method selected for the payment process.
  final ManualConfigModel method;

  /// Constructs a [ManualPayProvider].
  ///
  /// Initiates fetching the payment request details upon creation.
  ManualPayProvider({
    required this.apiKey,
    required this.transactionId,
    this.onPaymentSuccess,
    required this.method,
  }) : service = PayService(apiKey) {
    getPaymentRequest();
  }

  /// Manual payment request model.
  PaymentRequestModel? paymentRequest;

  /// The selected file for manual payment.
  PlatformFile? selectedFile;

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
      () => GetPaymentRequestService(apiKey).get(transactionId),
      showFlashBar: false,
    );

    isLoading = false;

    if (result.isError) {
      error = result.error;
      return notifyListeners();
    }

    // Set the payment request details from the result.
    paymentRequest = result.result;

    // Notify listeners of the change in payment request details.
    notifyListeners();
  }

  /// Processes the payment for the payment request.
  void manualPay(BuildContext context, PaymentMethod method) async {
    if (selectedFile == null) return; // Ensure the form is valid.

    error = null;
    isLoading = true;
    notifyListeners();

    final result = await ErrorHandlers.catchErrors(
      () => service.manualPay(
        transactionId: transactionId,
        paymentMethodId: method.id,
        selectedImage: selectedFile!,
      ),
    );

    isLoading = false;

    if (result.isError) {
      error = result.error;
      return notifyListeners();
    }

    await onPaymentSuccess?.call();

    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  /// A provider class for handling payment payment requests.
  void setSelectedImage(PlatformFile? file) {
    selectedFile = file;
    notifyListeners();
  }
}
