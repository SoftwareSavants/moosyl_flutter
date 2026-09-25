import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moosyl/moosyl.dart';
import 'package:moosyl_flutter/src/gimtel/gimtel_api.dart';
import 'package:moosyl_flutter/src/gimtel/gimtel_models.dart';

/// Builds a [Moosyl] client whose [Dio] never hits the network: a request
/// interceptor answers `/payment` and `/payment/{id}/status` calls directly,
/// so the test exercises the real generated request/response serialization.
Moosyl _fakeClient({
  required void Function(Map<String, dynamic> body) onCreatePayment,
  required String statusToReturn,
}) {
  final dio = Dio(BaseOptions(baseUrl: 'https://fake.test'));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        if (options.method == 'POST' && options.path == '/payment') {
          onCreatePayment(Map<String, dynamic>.from(options.data as Map));
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'id': 'pay_1',
                'status': 'pending',
                'instructions': {
                  'kind': 'gimtel_transfer',
                  'receivingPhone': '36551929',
                  'receivingBank': 'bankily',
                  'amount': 1500,
                  'payerPhone': '22233344',
                  'paymentId': 'pay_1',
                  'claimExpiresAt': '2026-01-01T00:00:00Z',
                },
              },
            ),
          );
          return;
        }
        if (options.method == 'GET' &&
            options.path == '/payment/pay_1/status') {
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {'id': 'pay_1', 'status': statusToReturn},
            ),
          );
          return;
        }
        handler.reject(
          DioException(
            requestOptions: options,
            error: 'Unexpected request: ${options.method} ${options.path}',
          ),
        );
      },
    ),
  );
  return Moosyl(dio: dio, interceptors: const []);
}

void main() {
  group('MoosylGimtelApi.createPayment', () {
    test('sends no passCode and maps instructions', () async {
      Map<String, dynamic>? sentBody;
      final api = MoosylGimtelApi(
        'pk_test',
        client: _fakeClient(
          onCreatePayment: (body) => sentBody = body,
          statusToReturn: 'pending',
        ),
      );

      final instructions = await api.createPayment(
        configurationId: 'config_1',
        transactionId: 'txn_1',
        phoneNumber: '36551929',
      );

      expect(sentBody, isNotNull);
      expect(sentBody!.containsKey('passCode'), isFalse);
      expect(sentBody!['configurationId'], 'config_1');
      expect(sentBody!['transactionId'], 'txn_1');
      expect(sentBody!['phoneNumber'], '36551929');

      expect(instructions.receivingPhone, '36551929');
      expect(instructions.receivingBank, 'bankily');
      expect(instructions.amount, 1500);
      expect(instructions.payerPhone, '22233344');
      expect(instructions.paymentId, 'pay_1');
      expect(instructions.claimExpiresAt, '2026-01-01T00:00:00Z');
    });
  });

  group('MoosylGimtelApi.status', () {
    test('maps a known wire status to its GimtelStatus', () async {
      final api = MoosylGimtelApi(
        'pk_test',
        client:
            _fakeClient(onCreatePayment: (_) {}, statusToReturn: 'completed'),
      );

      expect(await api.status('pay_1'), GimtelStatus.completed);
    });

    test('maps an unrecognized wire status to pending', () async {
      final api = MoosylGimtelApi(
        'pk_test',
        client: _fakeClient(onCreatePayment: (_) {}, statusToReturn: '???'),
      );

      expect(await api.status('pay_1'), GimtelStatus.pending);
    });
  });
}
