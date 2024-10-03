import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:software_pay/helpers/fetcher.dart';
import 'package:software_pay/payment_methods/models/payment_method_model.dart';

part 'get_payment_methods_service.g.dart';

@riverpod
GetPaymentMethodsService getPaymentMethodsService(
  GetPaymentMethodsServiceRef ref,
) =>
    GetPaymentMethodsService(ref.read(fetcherProvider));

class GetPaymentMethodsService {
  final Fetcher _fetcherProvider;
  GetPaymentMethodsService(this._fetcherProvider);

  Future<List<PaymentMethod>> get() async {
    final methodsResult = await _fetcherProvider.get(Endpoints.paymentMethods);
    return methodsResult.data
        .map<PaymentMethod>((e) => PaymentMethod.fromType(e))
        .toList();
  }
}
