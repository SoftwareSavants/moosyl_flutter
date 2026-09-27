import 'package:built_value/serializer.dart' show DeserializationError;
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
// The generated client also exports a `GimtelInstructions` model (the raw
// wire shape); hide it so our own domain type (below) is unambiguous.
import 'package:moosyl/moosyl.dart' hide GimtelInstructions;
import 'package:moosyl_flutter/src/gimtel/gimtel_models.dart';
import 'package:moosyl_flutter/src/helpers/exception_handling/exceptions.dart';

const String _defaultBaseUrl = 'https://moosyl.moosyl.workers.dev';

/// The generated `moosyl` client defaults to a 3 s receive / 5 s connect
/// timeout, which is too tight for `GET /payment/{id}/status`: the backend
/// may run an inline bank sync there (bounded to ~4 s server-side) before
/// responding. Give Gimtel's client more headroom for that.
const Duration _receiveTimeout = Duration(seconds: 15);
const Duration _connectTimeout = Duration(seconds: 10);

/// The three calls the Gimtel flow needs. An interface so tests can use a fake.
abstract class GimtelApi {
  /// Creates a Gimtel payment and returns what the payer needs to complete it.
  Future<GimtelInstructions> createPayment({
    required String configurationId,
    required String transactionId,
    required String phoneNumber,
  });

  /// Polls the current status of a payment.
  Future<GimtelStatus> status(String paymentId);

  /// Sandbox-only: simulates the payer's bank transfer to complete the payment.
  Future<void> simulateTransfer(String paymentId);
}

/// [GimtelApi] backed by the generated `moosyl` client.
class MoosylGimtelApi implements GimtelApi {
  /// Creates an adapter authenticated with [publishableApiKey], optionally
  /// overriding the base URL. [client] is exposed only so tests can inject a
  /// [Moosyl] wired to a fake [Dio] adapter; production code should omit it.
  MoosylGimtelApi(
    this.publishableApiKey, {
    String? baseUrl,
    @visibleForTesting Moosyl? client,
  }) : _client = client ??
            (Moosyl(
              dio: Dio(BaseOptions(
                baseUrl: baseUrl ?? _defaultBaseUrl,
                connectTimeout: _connectTimeout,
                receiveTimeout: _receiveTimeout,
              )),
            )..setApiKey('ApiKey', publishableApiKey));

  /// The API key used for authentication with the backend.
  final String publishableApiKey;

  final Moosyl _client;

  /// The underlying generated client, exposed only so tests can assert on
  /// its configuration (e.g. `client.dio.options`).
  @visibleForTesting
  Moosyl get client => _client;

  @override
  Future<GimtelInstructions> createPayment({
    required String configurationId,
    required String transactionId,
    required String phoneNumber,
  }) async {
    final Response<PostPayment200Response> response;
    try {
      response = await _client.getPaymentApi().postPayment(
            paymentCreate: PaymentCreate((b) => b
              ..configurationId = configurationId
              ..transactionId = transactionId
              ..phoneNumber = phoneNumber),
          );
    } on DioException catch (e) {
      throw backendError(e) ?? e;
    }
    final i = response.data?.instructions;
    if (i == null) {
      throw StateError('Gimtel instructions missing from the payment response');
    }
    return GimtelInstructions(
      receivingPhone: i.receivingPhone,
      receivingBank: i.receivingBank,
      amount: i.amount,
      payerPhone: i.payerPhone,
      paymentId: i.paymentId,
      claimExpiresAt: i.claimExpiresAt,
    );
  }

  @override
  Future<GimtelStatus> status(String paymentId) async {
    try {
      final response =
          await _client.getPaymentApi().getPaymentByIdStatus(id: paymentId);
      return gimtelStatusFrom(response.data?.status.name);
    } on DioException catch (e) {
      // The generated enum deserializer throws `ArgumentError` for a status
      // value it doesn't recognize (see the `valueOf` switch's `default` in
      // `GetPaymentByIdStatus200ResponseStatusEnum`'s `.g.dart`), which
      // `built_value` wraps in one `DeserializationError` per nesting level,
      // and the generated API method wraps again as a `DioException`. Treat
      // an unrecognized status the same as a missing one: keep polling
      // rather than surfacing a hard failure.
      if (_causedByUnrecognizedEnumValue(e.error)) return GimtelStatus.pending;
      rethrow;
    }
  }

  static bool _causedByUnrecognizedEnumValue(Object? error) {
    var cause = error;
    while (cause is DeserializationError) {
      cause = cause.error;
    }
    return cause is ArgumentError;
  }

  @override
  Future<void> simulateTransfer(String paymentId) async {
    try {
      await _client
          .getPaymentApi()
          .postPaymentByIdSimulateTransfer(id: paymentId);
    } on DioException catch (e) {
      throw backendError(e) ?? e;
    }
  }

  /// The backend's `{ message }` error body as an [AppException] (so
  /// `ExceptionMapper` can localize known messages), or `null` when the
  /// response carries no message (network error, timeout, empty body, ...).
  @visibleForTesting
  static AppException? backendError(DioException e) {
    final data = e.response?.data;
    final message = data is Map ? data['message'] : null;
    if (message is! String || message.trim().isEmpty) return null;
    return AppException(
      code: AppExceptionCode(message),
      message: message,
      stackTrace: e.stackTrace,
    );
  }
}
