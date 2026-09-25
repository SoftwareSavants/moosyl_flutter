import 'package:built_value/serializer.dart' show DeserializationError;
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
// The generated client also exports a `GimtelInstructions` model (the raw
// wire shape); hide it so our own domain type (below) is unambiguous.
import 'package:moosyl/moosyl.dart' hide GimtelInstructions;
import 'package:moosyl_flutter/src/gimtel/gimtel_models.dart';

const String _defaultBaseUrl = 'https://moosyl.moosyl.workers.dev';

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
            (Moosyl(basePathOverride: baseUrl ?? _defaultBaseUrl)
              ..setApiKey('ApiKey', publishableApiKey));

  /// The API key used for authentication with the backend.
  final String publishableApiKey;

  final Moosyl _client;

  @override
  Future<GimtelInstructions> createPayment({
    required String configurationId,
    required String transactionId,
    required String phoneNumber,
  }) async {
    final response = await _client.getPaymentApi().postPayment(
          paymentCreate: PaymentCreate((b) => b
            ..configurationId = configurationId
            ..transactionId = transactionId
            ..phoneNumber = phoneNumber),
        );
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
    await _client
        .getPaymentApi()
        .postPaymentByIdSimulateTransfer(id: paymentId);
  }
}
