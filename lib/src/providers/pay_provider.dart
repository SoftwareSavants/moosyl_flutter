import 'dart:async';
import 'package:flutter/material.dart';
import 'package:moosyl/moosyl.dart';
import 'package:moosyl_flutter/src/helpers/exception_handling/error_handlers.dart';
import 'package:moosyl_flutter/src/services/get_payment_request_service.dart';
import 'package:moosyl_flutter/src/services/pay_service.dart';

/// A provider class for handling payment payment requests.
///
/// This class extends [ChangeNotifier] to notify listeners about changes
/// in the payment payment request state, including loading status and errors.
class PayProvider extends ChangeNotifier {
  /// The API key used for authentication with the payment services.
  final String publishableApiKey;

  /// The ID of the payment request being processed.
  final String transactionId;

  /// The payment method selected for the payment process.
  final ConfigurationListDataInner method;

  /// Callback function that gets called on successful payment.
  final FutureOr<void> Function()? onPaymentSuccess;

  /// Optional callback called before [onPaymentSuccess] when payment completes.
  /// Use this to close the dialog before invoking the success callback.
  VoidCallback? onBeforePaymentSuccess;

  /// Constructs a [PayProvider].
  ///
  /// Initiates fetching the payment request details upon creation.
  PayProvider({
    required this.publishableApiKey,
    required this.transactionId,
    this.onPaymentSuccess,
    required this.method,
  }) : service = PayService(publishableApiKey) {
    getPaymentRequest();
  }

  /// Text controller for inputting the passcode.
  final passCodeTextController = TextEditingController();

  /// Text controller for inputting the phone number.
  final phoneNumberTextController = TextEditingController();

  /// Key for the payment form.
  final formKey = GlobalKey<FormState>();

  /// Holds the payment request details.
  PaymentRequestGetData? paymentRequest;

  /// Holds any error messages that occur during payment processing.
  Object? error;

  /// Indicates whether the provider is currently loading data.
  bool isLoading = false;

  /// The payment service used for processing payments.
  final PayService service;

  /// Cached future for getPaymentRequest to avoid duplicate fetches.
  Future<void>? _getPaymentRequestFuture;

  ///
  String? paymentCode;

  /// Asynchronously fetches payment request details from the service.
  ///
  /// Updates the loading state and handles any errors that occur during
  /// the fetching process. Notifies listeners when the data changes.
  Future<void> getPaymentRequest() async {
    if (_getPaymentRequestFuture != null) return _getPaymentRequestFuture!;
    _getPaymentRequestFuture = _getPaymentRequestImpl();
    return _getPaymentRequestFuture!;
  }

  Future<void> _getPaymentRequestImpl() async {
    error = null;
    isLoading = true;
    notifyListeners();

    final result = await ErrorHandlers.catchErrors(
      () => GetPaymentRequestService(publishableApiKey).get(transactionId),
      showFlashBar: false,
    );

    isLoading = false;

    if (result.isError) {
      error = result.error;
      return notifyListeners();
    }

    // Set the payment request details from the result.
    paymentRequest = result.result;

    String phoneNumber = paymentRequest!.phoneNumber ?? '';

    if (phoneNumber.length > 8) {
      phoneNumber = phoneNumber.substring(phoneNumber.length - 8);
    }

    phoneNumberTextController.text = phoneNumber;

    // Notify listeners of the change in payment request details.
    notifyListeners();
  }

  /// Processes the payment for the payment request.
  ///
  /// Validates the form, sets the loading state, and calls the payment service.
  /// If payment is successful, it invokes the [onPaymentSuccess] callback.
  Future<void> pay([BuildContext? context]) async {
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
    paymentCode =
        result.result?.metadata?.asMap['paymentCode'].toString() ?? '';
    notifyListeners();
    if (result.result?.metadata?.asMap['provider'] == 'bankily') {
      onBeforePaymentSuccess?.call();
      onPaymentSuccess?.call();
    }
  }

  /// Initiates Sedad/Bim Bank payment to get the payment code.
  /// Call this when user presses Pay on the selection screen (before showing the dialog).
  /// Waits for payment request, then calls pay with phone from request and empty passcode.
  Future<String?> getPaymentCodeForSedad() async {
    await getPaymentRequest();
    passCodeTextController.clear();
    await pay();
    return paymentCode;
  }

  /// Handles the payment for the payment request.
  void handleSedadPay() async {
    error = null;
    isLoading = true;
    notifyListeners();

    final result = await ErrorHandlers.catchErrors(
      () => service.getPayment(transactionId: transactionId),
    );

    if (result.isError) {
      error = result.error;
      return notifyListeners();
    }
    isLoading = false;

    if (result.result!.status.name == 'completed') {
      onBeforePaymentSuccess?.call();
      onPaymentSuccess?.call();
    } else {
      error = 'PaymentNotCompleted';
      return notifyListeners();
    }
    notifyListeners();
  }
}
