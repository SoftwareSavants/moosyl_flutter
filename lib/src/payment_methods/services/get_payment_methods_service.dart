import 'package:software_pay/src/helpers/fetcher.dart';
import 'package:software_pay/src/payment_methods/models/payment_method_model.dart';

class GetPaymentMethodsService {
  final String apiKey;

  GetPaymentMethodsService(this.apiKey);

  Future<List<PaymentMethod>> get() async {
    final methodsResult = await Fetcher(apiKey).get(Endpoints.paymentMethods);
    return List.from(methodsResult.data)
        .map<PaymentMethod>((e) => PaymentMethod.fromType(e))
        .toList();
  }
}
