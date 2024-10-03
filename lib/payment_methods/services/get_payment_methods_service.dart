import 'package:software_pay/helpers/fetcher.dart';
import 'package:software_pay/payment_methods/models/payment_method_model.dart';

class GetPaymentMethodsService {
  final String apiKey;

  GetPaymentMethodsService(this.apiKey);

  Future<List<PaymentMethod>> get() async {
    final methodsResult = await Fetcher(apiKey).get(Endpoints.paymentMethods);
    return methodsResult.data
        .map<PaymentMethod>((e) => PaymentMethod.fromType(e))
        .toList();
  }
}
