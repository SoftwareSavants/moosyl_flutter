import 'package:moosyl/moosyl.dart';

/// Base URL for the Moosyl API.
const String _defaultBaseUrl = 'https://moosyl.moosyl.workers.dev';

/// A service class for processing payments.
///
/// This class provides methods to interact with the backend and
/// execute payment transactions using the Moosyl SDK [PaymentApi].
class PayService {
  /// The API key used for authentication with the backend.
  final String publishableApiKey;

  /// Optional base URL override.
  final String? baseUrlOverride;

  /// Constructs a [PayService] with the provided [publishableApiKey].
  PayService(
    this.publishableApiKey, {
    this.baseUrlOverride,
  });

  /// Processes a payment transaction via [PaymentApi].
  ///
  /// This method makes an API call to process a payment using the specified
  /// parameters. It requires the Transaction ID, phone number, passcode,
  /// and payment method ID.
  Future<PostPayment200Response> pay({
    required String transactionId,
    required String phoneNumber,
    required String passCode,
    required String paymentMethodId,
  }) async {
    final client = _createClient();
    final paymentApi = client.getPaymentApi();

    final paymentCreate = PaymentCreate(
      (b) => b
        ..configurationId = paymentMethodId
        ..transactionId = transactionId
        ..phoneNumber = phoneNumber
        ..passCode = passCode,
    );

    final response = await paymentApi.postPayment(paymentCreate: paymentCreate);
    final data = response.data;
    if (data == null) {
      throw StateError('payment not found');
    }
    return data;
  }

  Moosyl _createClient() {
    final client = Moosyl(
      basePathOverride: baseUrlOverride ?? _defaultBaseUrl,
    );
    client.setApiKey('ApiKey', publishableApiKey);
    return client;
  }
}
