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

  /// Like [pendingFor], but consumed on the *next* `status()` call for that
  /// payment id only (mimics a single stale/hung request rather than every
  /// call for that payment hanging forever).
  final pendingOnceFor = <String, Completer<GimtelStatus>>{};

  /// A per-payment FIFO queue of completers, one consumed per `status()`
  /// call for that payment id (falls back to the other sources once empty).
  /// Lets a test hold open several *distinct* calls independently (e.g. a
  /// stale pre-background call and the resume poll that follows it) to
  /// control exactly when each settles relative to the other.
  final queuedGatesFor = <String, List<Completer<GimtelStatus>>>{};
  final paymentIds = <String>['p1'];

  /// How many `status()` calls are concurrently awaiting a response right
  /// now, and the highest value that has ever reached. A controller/hook
  /// that never lets two real requests for the same payment overlap should
  /// keep [maxConcurrentStatusCalls] at 1.
  int _activeStatusCalls = 0;
  int maxConcurrentStatusCalls = 0;

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
    _activeStatusCalls++;
    if (_activeStatusCalls > maxConcurrentStatusCalls) {
      maxConcurrentStatusCalls = _activeStatusCalls;
    }
    try {
      final once = pendingOnceFor.remove(paymentId);
      if (once != null) return await once.future;
      final gates = queuedGatesFor[paymentId];
      if (gates != null && gates.isNotEmpty) {
        return await gates.removeAt(0).future;
      }
      final pending = pendingFor[paymentId];
      if (pending != null) return await pending.future;
      final queue = statusesFor[paymentId];
      if (queue != null) {
        return queue.isEmpty ? GimtelStatus.pending : queue.removeAt(0);
      }
      return statuses.isEmpty ? GimtelStatus.pending : statuses.removeAt(0);
    } finally {
      _activeStatusCalls--;
    }
  }

  int simulateCalls = 0;

  /// When set, `simulateTransfer` throws this.
  Object? simulateError;

  @override
  Future<void> simulateTransfer(String paymentId) async {
    simulateCalls++;
    final e = simulateError;
    if (e != null) throw e;
  }
}
