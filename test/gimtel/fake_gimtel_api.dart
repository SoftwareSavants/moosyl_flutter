import 'dart:async';

import 'package:moosyl_flutter/src/gimtel/gimtel_api.dart';
import 'package:moosyl_flutter/src/gimtel/gimtel_models.dart';

/// A fake [GimtelApi] whose `createPayment` returns ids from [paymentIds] in
/// order (the last id repeats for further calls), and whose `status` answers
/// are queued globally (`statuses`, matching the original single-payment
/// tests) or per-payment (`statusesFor`) or, when a race needs to be
/// simulated, held open until the test completes a [Completer]
/// (`pendingCreate` / `pendingFor`).
class FakeApi implements GimtelApi {
  final statuses = <GimtelStatus>[];
  final statusesFor = <String, List<GimtelStatus>>{};
  final pendingFor = <String, Completer<GimtelStatus>>{};
  final paymentIds = <String>['p1'];

  /// When set, the *next* `createPayment` call awaits this instead of
  /// resolving immediately (consumed on use, so later calls fall back to the
  /// normal [paymentIds]-driven flow).
  Completer<GimtelInstructions>? pendingCreate;

  int statusCalls = 0;
  int createCalls = 0;
  String? lastPhone;

  @override
  Future<GimtelInstructions> createPayment({
    required String configurationId,
    required String transactionId,
    required String phoneNumber,
  }) async {
    lastPhone = phoneNumber;
    final gate = pendingCreate;
    if (gate != null) {
      pendingCreate = null;
      createCalls++;
      return gate.future;
    }
    final index =
        createCalls < paymentIds.length ? createCalls : paymentIds.length - 1;
    final id = paymentIds[index];
    createCalls++;
    return GimtelInstructions(
      receivingPhone: '30393659',
      receivingBank: 'BIM Bank',
      amount: 100,
      payerPhone: '36551929',
      paymentId: id,
      claimExpiresAt: '2026-09-25T10:10:00Z',
    );
  }

  @override
  Future<GimtelStatus> status(String paymentId) async {
    statusCalls++;
    final pending = pendingFor[paymentId];
    if (pending != null) return pending.future;
    final queue = statusesFor[paymentId];
    if (queue != null) {
      return queue.isEmpty ? GimtelStatus.pending : queue.removeAt(0);
    }
    return statuses.isEmpty ? GimtelStatus.pending : statuses.removeAt(0);
  }

  int simulateCalls = 0;

  @override
  Future<void> simulateTransfer(String paymentId) async {
    simulateCalls++;
  }
}
