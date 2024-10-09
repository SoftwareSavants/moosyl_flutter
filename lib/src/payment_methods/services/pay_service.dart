import 'package:file_picker/file_picker.dart';
import 'package:moosyl/src/helpers/fetcher.dart';

/// A service class for processing payments.
///
/// This class provides methods to interact with the backend and
/// execute payment transactions.
class PayService {
  /// The API key used for authentication with the backend.
  final String apiKey;

  /// Constructs a [PayService] with the provided [apiKey].
  PayService(this.apiKey);

  /// Processes a payment transaction.
  ///
  /// This method makes an API call to process a payment using the specified
  /// parameters. It requires the Transaction ID, phone number, passcode,
  /// and payment method ID.
  Future<void> pay({
    required String transactionId,
    required String phoneNumber,
    required String passCode,
    required String paymentMethodId,
  }) async {
    // Make a POST request to the payment methods endpoint with the payment details.
    await Fetcher(apiKey).post(
      Endpoints.pay,
      body: {
        'transactionId': transactionId,
        'phoneNumber': phoneNumber,
        'passCode': passCode,
        'configurationId': paymentMethodId,
      },
    );
  }

  /// Manually processes a payment by making a POST request to the payment methods endpoint.
  ///
  /// This method sends the payment details including the transaction ID, payment method ID,
  /// and a screenshot of the payment to the server for processing.
  ///
  /// Parameters:
  /// - `transactionId` (required): The unique identifier for the transaction.
  /// - `paymentMethodId` (required): The identifier for the selected payment method.
  /// - `selectedImage` (required): A screenshot of the payment as a `PlatformFile`.
  ///
  /// Returns:
  /// - A `Future<void>` that completes when the payment has been processed.

  Future<void> manualPay({
    required String transactionId,
    required String paymentMethodId,
    required PlatformFile selectedImage,
  }) async {
    // Make a POST request to the payment methods endpoint with the payment details.
    await Fetcher(apiKey).multipartPost(
      Endpoints.pay,
      files: [selectedImage],
      body: {
        'operationId': transactionId,
        'configurationId': paymentMethodId,
      },
    );
  }
}
