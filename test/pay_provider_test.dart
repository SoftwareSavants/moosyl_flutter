import 'package:built_value/json_object.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moosyl/moosyl.dart';
import 'package:moosyl_flutter/src/models/selection_error.dart';
import 'package:moosyl_flutter/src/providers/pay_provider.dart';

import 'fake_services.dart';

PostPayment200Response _response(String status, Map<String, Object?> meta) =>
    PostPayment200Response((b) => b
      ..id = 'pay1'
      ..status = status
      ..metadata = JsonObject(meta));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<(PayProvider, List<bool>)> pay(PostPayment200Response response,
      {String type = 'bankily'}) async {
    final successes = <bool>[];
    final provider = PayProvider(
      publishableApiKey: 'pk_test',
      transactionId: 't1',
      method: method(type),
      onPaymentSuccess: successes.add,
      service: FakePayService(response),
      requestService: FakeRequestService(),
    );
    await provider.pay();
    return (provider, successes);
  }

  test('native Bankily that is not completed is an error, never a success',
      () async {
    final (provider, successes) =
        await pay(_response('pending', {'provider': 'bankily'}));

    expect(successes, isEmpty);
    expect(provider.error, 'paymentNotCompleted');
    // The payer must see "Payment not completed", not the unknown-error text.
    expect(SelectionErrorType.fromStr(provider.error.toString()),
        SelectionErrorType.paymentNotCompleted);
  });

  test('native Bankily reports success once when completed', () async {
    final (provider, successes) =
        await pay(_response('completed', {'provider': 'bankily'}));

    expect(successes, [true]);
    expect(provider.error, isNull);
  });

  test('a response without a paymentCode never yields the string "null"',
      () async {
    final (provider, _) =
        await pay(_response('pending', {'provider': 'sedad'}), type: 'sedad');

    expect(provider.paymentCode, isNull);
    expect(await provider.getPaymentCodeForSedad(), isNot('null'));
  });

  test('the payment code is read from the response metadata', () async {
    final (provider, _) = await pay(
        _response('pending', {'provider': 'sedad', 'paymentCode': 4821}),
        type: 'sedad');

    expect(provider.paymentCode, '4821');
  });
}
