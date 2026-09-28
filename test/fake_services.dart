import 'package:moosyl/moosyl.dart';
import 'package:moosyl_flutter/src/services/get_payment_methods_service.dart';
import 'package:moosyl_flutter/src/services/get_payment_request_service.dart';
import 'package:moosyl_flutter/src/services/pay_service.dart';

/// Builds a configuration row as the API returns it.
ConfigurationListDataInner method(
  String type, {
  String? id,
  String integration = 'native',
}) =>
    ConfigurationListDataInner((b) => b
      ..id = id ?? '$type-$integration'
      ..type = type
      ..integration = integration
      ..isTestingMode = true);

/// Returns [methods] instead of calling the API.
class FakeMethodsService extends GetPaymentMethodsService {
  FakeMethodsService(this.methods) : super('pk_test');

  final List<ConfigurationListDataInner> methods;

  @override
  Future<List<ConfigurationListDataInner>> get() async => methods;
}

/// Returns an unpaid payment request of [amount] instead of calling the API.
class FakeRequestService extends GetPaymentRequestService {
  FakeRequestService({this.amount = 100, this.phoneNumber}) : super('pk_test');

  final int amount;
  final String? phoneNumber;

  @override
  Future<PaymentRequestGetData> get(String transactionId) async =>
      PaymentRequestGetData((b) => b
        ..id = 'pr1'
        ..amount = amount
        ..totalAmount = amount
        ..phoneNumber = phoneNumber
        ..transactionId = transactionId
        ..environmentId = 'env1'
        ..retryCount = 0
        ..createdAt = DateTime.utc(2026, 9, 25)
        ..updatedAt = DateTime.utc(2026, 9, 25));
}

/// Answers `pay` with [response] and records how often it was called.
class FakePayService extends PayService {
  FakePayService(this.response) : super('pk_test');

  final PostPayment200Response response;
  int calls = 0;

  @override
  Future<PostPayment200Response> pay({
    required String transactionId,
    required String phoneNumber,
    required String passCode,
    required String paymentMethodId,
  }) async {
    calls++;
    return response;
  }
}
