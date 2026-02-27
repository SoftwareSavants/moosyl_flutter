import 'package:moosyl/moosyl.dart';
import 'package:moosyl_flutter/src/models/payment_request_model.dart';

/// Base URL for the Moosyl API.
const String _defaultBaseUrl = 'https://moosyl.moosyl.workers.dev';

/// A service class for fetching Payment Request details.
///
/// This class provides methods to interact with the backend and retrieve
/// Payment Request information using the Moosyl SDK [PaymentRequestApi].
class GetPaymentRequestService {
  /// The API key used for authentication with the backend.
  final String authorizations;

  /// Optional base URL override.
  final String? baseUrlOverride;

  /// Constructs a [GetPaymentRequestService] with the provided [authorizations].
  GetPaymentRequestService(
    this.authorizations, {
    this.baseUrlOverride,
  });

  /// Fetches Payment Request details for the specified [transactionId].
  ///
  /// Makes an API call via [PaymentRequestApi] to retrieve the Payment Request.
  /// Returns a [PaymentRequestModel] object containing the Payment Request details.
  Future<PaymentRequestModel> get(String transactionId) async {
    final client = Moosyl(
      basePathOverride: baseUrlOverride ?? _defaultBaseUrl,
    );

    client.dio.options.headers['Authorization'] = authorizations;

    final paymentRequestApi = client.getPaymentRequestApi();
    final response =
        await paymentRequestApi.getPaymentRequestByTransactionByTransactionId(
      transactionId: transactionId,
    );

    final data = response.data?.data;
    if (data == null) {
      throw StateError('Payment request not found');
    }

    return PaymentRequestModel(
      id: data.id,
      phoneNumber: data.phoneNumber,
      amount: data.amount.toDouble(),
    );
  }
}
