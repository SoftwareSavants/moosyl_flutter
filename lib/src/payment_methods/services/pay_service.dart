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

  Future<void> manualPay({
    required String transactionId,
    required String paymentMethodId,
    required PlatformFile selectedImage,
  }) async {
    // Make a POST request to the payment methods endpoint with the payment details.
    await Fetcher(apiKey).post(
      Endpoints.pay,
      body: {
        'operationId': transactionId,
        'configurationId': paymentMethodId,
        'screenShot': selectedImage
      },
    );
  }
}
