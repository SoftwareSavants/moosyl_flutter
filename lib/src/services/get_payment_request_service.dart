import 'package:moosyl/moosyl.dart';

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
  /// Returns a [PaymentRequestGetData] object containing the Payment Request details.
  Future<PaymentRequestGetData> get(String transactionId) async {
    final client = Moosyl(
      basePathOverride: baseUrlOverride ?? _defaultBaseUrl,
    );

    client.setApiKey('ApiKey', authorizations);

    final paymentRequestApi = client.getPaymentRequestApi();
    final response =
        await paymentRequestApi.getPaymentRequestByTransactionByTransactionId(
      transactionId: transactionId,
    );

    final data = response.data?.data;
    if (data == null) {
      throw StateError('Payment request not found');
    }

    return data;
  }
}
