import 'package:software_pay/src/helpers/fetcher.dart';

class PayService {
  final String apiKey;

  PayService(this.apiKey);

  Future<void> pay({
    required String operationId,
    required String phoneNumber,
    required String passCode,
    required String paymentMethodId,
  }) async {
    await Fetcher(apiKey).post(
      Endpoints.paymentMethods,
      body: {
        'operationId': operationId,
        'phoneNumber': phoneNumber,
        'passCode': passCode,
        'paymentMethodId': paymentMethodId,
      },
    );
  }
}
