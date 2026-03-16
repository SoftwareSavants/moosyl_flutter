import 'package:moosyl/moosyl.dart';

/// Unified model for payment success, used across Sedad, Bankily, and Masrivi.
///
/// Normalizes [PaymentGetData] and [PostPayment200Response] into a common shape
/// for display in the success dialog and for [onPaymentSuccess] callback.
class PaymentSuccess {
  /// Creates a new [PaymentSuccess] instance.
  ///
  /// * [id]: The ID of the payment.
  /// * [amount]: The amount of the payment.
  /// * [status]: The status of the payment.
  const PaymentSuccess({
    required this.id,
    required this.amount,
    required this.status,
  });

  /// Payment ID.
  final String id;

  /// Payment amount (e.g. in MRU).
  final int amount;

  /// Payment status (e.g. 'completed').
  final String status;

  /// Creates from [PaymentGetData] (Sedad - from getPayment).
  factory PaymentSuccess.fromPaymentRequestGetData(PaymentRequestGetData data) {
    return PaymentSuccess(
      id: data.id,
      amount: data.amount,
      status: 'completed',
    );
  }

  /// Creates from [PostPayment200Response] (Bankily - from postPayment).
  /// [amountFallback] is used when amount is not in the response (e.g. from payment request).
  factory PaymentSuccess.fromPostPaymentResponse(
    PostPayment200Response response, {
    required int amountFallback,
  }) {
    final amount = response.metadata?.asMap['amount'] != null
        ? (response.metadata!.asMap['amount'] is int
            ? response.metadata!.asMap['amount'] as int
            : int.tryParse(response.metadata!.asMap['amount'].toString()) ??
                amountFallback)
        : amountFallback;
    return PaymentSuccess(
      id: response.id,
      amount: amount,
      status: response.status,
    );
  }
}
