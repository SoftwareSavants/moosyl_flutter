import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:software_pay/payment_methods/models/payment_method_model.dart';

part 'get_payment_methods_service.g.dart';

@riverpod
GetPaymentMethodsService getPaymentMethodsService(
  GetPaymentMethodsServiceRef ref,
) =>
    GetPaymentMethodsService();

class GetPaymentMethodsService {
  GetPaymentMethodsService();

  Future<List<PaymentMethod>> get() {
    return Future.value([]);
  }
}
