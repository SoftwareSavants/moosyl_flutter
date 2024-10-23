import 'package:moosyl/src/helpers/fetcher.dart';
import 'package:moosyl/src/models/payment_request_model.dart';

/// A service class for fetching Payment Request details.
///
/// This class provides methods to interact with the backend and retrieve
/// Payment Request information based on the Payment Request ID.
class GetPaymentRequestService {
  /// The API key used for authentication with the backend.
  final String apiKey;

  /// Constructs a [GetPaymentRequestService] with the provided [apiKey].
  GetPaymentRequestService(this.apiKey);

  /// Fetches Payment Request details for the specified [transactionId].
  ///
  /// Makes an API call to retrieve the Payment Request information.
  /// Returns an [PaymentRequestModel] object containing the Payment Request details.
  Future<PaymentRequestModel> get(String transactionId) async {
    // Fetch the Payment Request details from the backend.
    final methodsResult = await Fetcher(apiKey).get(
      Endpoints.paymentRequest(transactionId),
    );

    // Convert the result data to an PaymentRequestModel instance.
    return PaymentRequestModel.fromMap(methodsResult.data['data']);
  }
}
