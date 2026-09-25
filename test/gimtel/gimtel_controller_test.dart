import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moosyl_flutter/src/gimtel/gimtel_api.dart';
import 'package:moosyl_flutter/src/gimtel/gimtel_controller.dart';
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
    final index = createCalls < paymentIds.length
        ? createCalls
        : paymentIds.length - 1;
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

  @override
  Future<void> simulateTransfer(String paymentId) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  GimtelController make(FakeApi api) => GimtelController(
      api: api, configurationId: 'c1', transactionId: 't1', initialPhone: '');

  test('rejects an invalid phone without calling the API', () async {
    final api = FakeApi();
    final c = make(api);
    await c.submitPhone('123');
    expect(c.error, 'invalidPhone');
    expect(api.lastPhone, isNull);
    c.dispose();
  });

  test('normalizes the phone, moves to pay, polls until completed once', () {
    fakeAsync((async) {
      final api = FakeApi()
        ..statuses.addAll([GimtelStatus.pending, GimtelStatus.completed]);
      final c = make(api);
      var completed = 0;
      c.onCompleted(() => completed++);
      c.submitPhone('+222 36 55 19 29');
      async.flushMicrotasks();
      expect(api.lastPhone, '36551929');
      expect(c.step, GimtelStep.pay);
      async.elapse(const Duration(seconds: 9));
      expect(c.status, GimtelStatus.completed);
      expect(completed, 1);
      final calls = api.statusCalls;
      async.elapse(const Duration(seconds: 20));
      expect(api.statusCalls, calls, reason: 'stops polling after a terminal status');
      c.dispose();
    });
  });

  test('pauses polling in background and polls immediately on resume', () {
    fakeAsync((async) {
      final api = FakeApi();
      final c = make(api);
      c.submitPhone('36551929');
      async.flushMicrotasks();
      async.elapse(const Duration(seconds: 1));
      c.didChangeAppLifecycleState(AppLifecycleState.paused);
      final before = api.statusCalls;
      async.elapse(const Duration(seconds: 30));
      expect(api.statusCalls, before);
      c.didChangeAppLifecycleState(AppLifecycleState.resumed);
      async.flushMicrotasks();
      expect(api.statusCalls, before + 1);
      c.dispose();
    });
  });

  test('expired stops polling; startAgain creates a fresh payment', () {
    fakeAsync((async) {
      final api = FakeApi()..statuses.add(GimtelStatus.expired);
      final c = make(api);
      c.submitPhone('36551929');
      async.flushMicrotasks();
      async.elapse(const Duration(seconds: 5));
      expect(c.status, GimtelStatus.expired);
      api.lastPhone = null;
      c.startAgain();
      async.flushMicrotasks();
      expect(api.lastPhone, '36551929');
      expect(c.status, GimtelStatus.pending);
      c.dispose();
    });
  });

  test('dispose stops the timer and never calls onCompleted afterwards', () {
    fakeAsync((async) {
      // Two statuses, like the "polls until completed" test above: the
      // immediate poll on payment creation consumes the first ('pending',
      // resolved within the same flushMicrotasks() as createPayment() per
      // Dart's async/await semantics), so `dispose()` below runs while the
      // payment is still pending and the terminal 'completed' response is
      // still queued for a later periodic tick that must never happen.
      final api = FakeApi()
        ..statuses.addAll([GimtelStatus.pending, GimtelStatus.completed]);
      final c = make(api);
      var completed = 0;
      c.onCompleted(() => completed++);
      c.submitPhone('36551929');
      async.flushMicrotasks();
      expect(c.status, GimtelStatus.pending,
          reason: 'sanity check: still pending, not yet terminal, at dispose time');
      c.dispose();
      async.elapse(const Duration(seconds: 20));
      expect(completed, 0);
    });
  });

  // --- Stale-response race regression tests (controller ruling amendment) ---

  test(
      'a stale create() error arriving after changeNumber + resubmit does not '
      're-enable submitting or show a stale error on the new flow', () {
    fakeAsync((async) {
      final api = FakeApi()..paymentIds.add('p2');
      final firstCreate = Completer<GimtelInstructions>();
      api.pendingCreate = firstCreate; // gates only the *next* createPayment call.

      final c = make(api);
      c.submitPhone('36551929');
      async.flushMicrotasks(); // first createPayment() is now pending.
      expect(c.submitting, isTrue);

      // Change number (abandoning the in-flight create), then resubmit: the
      // second createPayment() is not gated, so it resolves immediately.
      c.changeNumber();
      c.submitPhone('36551929');
      async.flushMicrotasks();
      expect(c.step, GimtelStep.pay);
      expect(c.instructions?.paymentId, 'p2');
      expect(c.submitting, isFalse);
      expect(c.error, isNull);

      // The first (superseded) createPayment() finally settles - with an
      // error. It must not re-enable the submit button or surface a stale
      // error on top of the already-successful second flow.
      firstCreate.completeError(Exception('boom: superseded request'));
      async.flushMicrotasks();

      expect(c.submitting, isFalse,
          reason: 'a stale create() failure must not flip submitting back on');
      expect(c.error, isNull,
          reason: 'a stale create() failure must not surface on the new flow');
      expect(c.step, GimtelStep.pay);
      expect(c.instructions?.paymentId, 'p2');

      c.dispose();
    });
  });

  test(
      'a late in-flight poll for a superseded payment is ignored after '
      'changeNumber + resubmit, and the new payment keeps polling', () {
    fakeAsync((async) {
      final api = FakeApi()..paymentIds.add('p2');
      // Hold p1's first status response open so we can resolve it *after*
      // changeNumber() + resubmit have already moved on to p2.
      final p1Response = Completer<GimtelStatus>();
      api.pendingFor['p1'] = p1Response;

      final c = make(api);
      var completed = 0;
      c.onCompleted(() => completed++);

      c.submitPhone('36551929');
      async.flushMicrotasks();
      expect(c.step, GimtelStep.pay);
      expect(c.instructions?.paymentId, 'p1');
      final callsAfterP1FirstPoll = api.statusCalls;
      expect(callsAfterP1FirstPoll, 1);

      // Change number while p1's poll is still in flight, then resubmit.
      c.changeNumber();
      expect(c.step, GimtelStep.phone);

      c.submitPhone('36551929');
      async.flushMicrotasks();
      expect(c.step, GimtelStep.pay);
      expect(c.instructions?.paymentId, 'p2');
      // p2's first poll must not be blocked by p1's in-flight request.
      expect(api.statusCalls, callsAfterP1FirstPoll + 1);

      // p1's late response finally arrives: it must be dropped entirely.
      p1Response.complete(GimtelStatus.expired);
      async.flushMicrotasks();
      expect(c.status, GimtelStatus.pending);
      expect(c.instructions?.paymentId, 'p2');
      expect(completed, 0);

      // p2 keeps being polled normally afterwards.
      final callsBeforeElapse = api.statusCalls;
      async.elapse(const Duration(seconds: 9));
      expect(api.statusCalls, greaterThan(callsBeforeElapse));

      c.dispose();
    });
  });

  test('changeNumber while createPayment is pending discards the stale result', () {
    fakeAsync((async) {
      final api = FakeApi();
      final createResponse = Completer<GimtelInstructions>();
      api.pendingCreate = createResponse;

      final c = make(api);
      c.submitPhone('36551929');
      async.flushMicrotasks(); // createPayment is now pending.

      c.changeNumber();
      expect(c.step, GimtelStep.phone);

      createResponse.complete(const GimtelInstructions(
        receivingPhone: '30393659',
        receivingBank: 'BIM Bank',
        amount: 100,
        payerPhone: '36551929',
        paymentId: 'p1',
        claimExpiresAt: '2026-09-25T10:10:00Z',
      ));
      async.flushMicrotasks();

      expect(c.step, GimtelStep.phone,
          reason: 'a stale create() result must not override changeNumber()');
      expect(c.instructions, isNull);
      expect(api.statusCalls, 0,
          reason: 'no polling should start for a discarded create() result');

      c.dispose();
    });
  });
}
