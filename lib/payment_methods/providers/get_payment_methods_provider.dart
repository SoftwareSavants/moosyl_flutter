import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:software_pay/payment_methods/models/payment_method_model.dart';
import 'package:software_pay/payment_methods/services/get_payment_methods_service.dart';

part 'get_payment_methods_provider.g.dart';

@riverpod
Future<List<PaymentMethod>> getPaymentMethod(GetPaymentMethodRef ref) {
  return ref.read(getPaymentMethodsServiceProvider).get();
}
