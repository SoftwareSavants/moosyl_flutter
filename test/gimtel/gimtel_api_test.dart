import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moosyl/moosyl.dart';
import 'package:moosyl_flutter/src/gimtel/gimtel_api.dart';
import 'package:moosyl_flutter/src/gimtel/gimtel_models.dart';
import 'package:moosyl_flutter/src/helpers/exception_handling/exceptions.dart';

/// A fake [HttpClientAdapter] that waits [delay] before responding with
/// [statusCode]/[data] - unless the request's own `receiveTimeout` is
/// shorter than [delay], in which case it raises the same
/// [DioException.receiveTimeout] the real (`IOHttpClientAdapter`-backed)
/// stack would once that timeout elapses. This lets a test prove that a
/// slow (e.g. inline-bank-sync) response only succeeds because the client is
/// configured with a long enough `receiveTimeout` - it fails the same way
/// the old, too-short default would.
class _DelayedAdapter implements HttpClientAdapter {
  _DelayedAdapter({
    required this.delay,
    required this.statusCode,
    required this.data,
  });

  final Duration delay;
  final int statusCode;
  final Map<String, dynamic> data;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final receiveTimeout = options.receiveTimeout;
    if (receiveTimeout != null && receiveTimeout < delay) {
      await Future<void>.delayed(receiveTimeout);
      throw DioException.receiveTimeout(
        timeout: receiveTimeout,
        requestOptions: options,
      );
    }
    await Future<void>.delayed(delay);
    return ResponseBody.fromString(
      jsonEncode(data),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

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
  group('MoosylGimtelApi timeouts', () {
    test(
        'createPayment keeps the moosyl-dart default timeouts (it never '
        'runs the inline bank sync)', () {
      final api = MoosylGimtelApi('pk_test');
      final options = api.client.dio.options;
      expect(options.receiveTimeout, const Duration(milliseconds: 3000));
      expect(options.connectTimeout, const Duration(milliseconds: 5000));
    });

    test(
        'status/simulateTransfer use longer timeouts than the moosyl-dart '
        "default, so a call that runs the backend's inline bank sync "
        '(bounded to ~4s) does not time out', () {
      final api = MoosylGimtelApi('pk_test');
      final options = api.statusClient.dio.options;
      expect(options.receiveTimeout, const Duration(seconds: 15));
      expect(options.connectTimeout, const Duration(seconds: 10));
    });

    test(
        'a status response arriving after 4s still succeeds on the real '
        "statusClient's configured timeouts (would fail at the old 3s "
        'default)', () {
      fakeAsync((async) {
        // The production (non-injected) statusClient, so this exercises the
        // same `receiveTimeout`/`connectTimeout` set in the constructor.
        final api = MoosylGimtelApi('pk_test');
        api.statusClient.dio.httpClientAdapter = _DelayedAdapter(
          delay: const Duration(seconds: 4),
          statusCode: 200,
          data: {'id': 'pay_1', 'status': 'completed'},
        );

        GimtelStatus? result;
        Object? error;
        unawaited(api.status('pay_1').then(
              (r) => result = r,
              onError: (Object e) => error = e,
            ));
        async.elapse(const Duration(seconds: 5));

        expect(error, isNull);
        expect(result, GimtelStatus.completed);
      });
    });

    test(
        'sanity check: the same delayed response times out under the old '
        '3s receiveTimeout, proving the fake adapter enforces it', () {
      fakeAsync((async) {
        final dio = Dio(BaseOptions(
          baseUrl: 'https://fake.test',
          receiveTimeout: const Duration(seconds: 3),
        ));
        dio.httpClientAdapter = _DelayedAdapter(
          delay: const Duration(seconds: 4),
          statusCode: 200,
          data: {'id': 'pay_1', 'status': 'completed'},
        );
        final api = MoosylGimtelApi(
          'pk_test',
          statusClient: Moosyl(dio: dio, interceptors: const [])
            ..setApiKey('ApiKey', 'pk_test'),
        );

        Object? error;
        unawaited(
          api.status('pay_1').catchError((Object e) {
            error = e;
            return GimtelStatus.pending;
          }),
        );
        async.elapse(const Duration(seconds: 5));

        expect(error, isA<DioException>());
      });
    });
  });

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
      final fakeClient =
          _fakeClient(onCreatePayment: (_) {}, statusToReturn: 'completed');
      final api = MoosylGimtelApi(
        'pk_test',
        statusClient: fakeClient,
      );

      expect(await api.status('pay_1'), GimtelStatus.completed);
    });

    test('maps an unrecognized wire status to pending', () async {
      final fakeClient =
          _fakeClient(onCreatePayment: (_) {}, statusToReturn: '???');
      final api = MoosylGimtelApi(
        'pk_test',
        statusClient: fakeClient,
      );

      expect(await api.status('pay_1'), GimtelStatus.pending);
    });
  });

  group('MoosylGimtelApi errors', () {
    MoosylGimtelApi failing(DioException Function(RequestOptions) fail) {
      final dio = Dio(BaseOptions(baseUrl: 'https://fake.test'));
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) => handler.reject(fail(options)),
      ));
      final fakeClient = Moosyl(dio: dio, interceptors: const []);
      return MoosylGimtelApi(
        'pk_test',
        client: fakeClient,
        statusClient: fakeClient,
      );
    }

    Future<void> create(MoosylGimtelApi api) => api.createPayment(
        configurationId: 'c', transactionId: 't', phoneNumber: '36551929');

    test('a backend { message } body becomes an AppException with it',
        () async {
      final api = failing((o) => DioException(
            requestOptions: o,
            type: DioExceptionType.badResponse,
            response: Response(
                requestOptions: o,
                statusCode: 404,
                data: {'message': 'Payment not found'}),
          ));
      await expectLater(
        create(api),
        throwsA(isA<AppException>()
            .having((e) => e.message, 'message', 'Payment not found')
            // Known backend messages keep their code, so ExceptionMapper
            // can localize them.
            .having((e) => e.code, 'code', AppExceptionCode.paymentNotFound)),
      );
      await expectLater(api.simulateTransfer('p1'),
          throwsA(isA<AppException>()));
    });

    test('an error without a backend message is rethrown unchanged', () async {
      final api = failing((o) => DioException(
            requestOptions: o,
            type: DioExceptionType.connectionError,
          ));
      await expectLater(create(api), throwsA(isA<DioException>()));
    });
  });
}
