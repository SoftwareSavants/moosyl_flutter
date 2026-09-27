import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moosyl_flutter/src/gimtel/gimtel_controller.dart';
import 'package:moosyl_flutter/src/gimtel/gimtel_models.dart';

import 'fake_gimtel_api.dart';

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
      expect(api.statusCalls, calls,
          reason: 'stops polling after a terminal status');
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
          reason:
              'sanity check: still pending, not yet terminal, at dispose time');
      c.dispose();
      final callsAtDispose = api.statusCalls;
      async.elapse(const Duration(seconds: 20));
      expect(api.statusCalls, callsAtDispose,
          reason: 'dispose() must actually cancel the polling timer');
      expect(completed, 0);
    });
  });

  test(
      'onCompleted fires only once: lifecycle resume and simulate() after '
      'completion do not re-poll or re-fire it', () {
    fakeAsync((async) {
      final api = FakeApi()..statuses.addAll([GimtelStatus.completed]);
      final c = make(api);
      var completed = 0;
      c.onCompleted(() => completed++);

      c.submitPhone('36551929');
      async.flushMicrotasks();
      expect(c.status, GimtelStatus.completed);
      expect(completed, 1);
      final callsAtCompletion = api.statusCalls;

      // A background/foreground cycle after completion must not re-poll or
      // re-fire onCompleted.
      c.didChangeAppLifecycleState(AppLifecycleState.inactive);
      c.didChangeAppLifecycleState(AppLifecycleState.resumed);
      async.flushMicrotasks();
      async.elapse(const Duration(seconds: 30));
      expect(api.statusCalls, callsAtCompletion);
      expect(completed, 1);

      // simulate() after completion must be a no-op too.
      c.simulate();
      async.flushMicrotasks();
      expect(api.simulateCalls, 0);
      expect(api.statusCalls, callsAtCompletion);
      expect(completed, 1);

      c.dispose();
    });
  });

  // --- Stale-response race regression tests (controller ruling amendment) ---

  test(
      'a stale create() error arriving after changeNumber + resubmit does not '
      're-enable submitting or show a stale error on the new flow', () {
    fakeAsync((async) {
      final api = FakeApi()..paymentIds.add('p2');
      final firstCreate = Completer<GimtelInstructions>();
      api.pendingCreate =
          firstCreate; // gates only the *next* createPayment call.

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

  test(
      'a stale in-flight status request does not block the resume poll; its '
      'late completion does not re-fire onCompleted', () {
    fakeAsync((async) {
      final api = FakeApi();
      final stale = Completer<GimtelStatus>();
      // Gates only the first status() call for p1 (the pre-background poll);
      // it never resolves during the test, simulating a request that hung
      // while the app was backgrounded.
      api.pendingOnceFor['p1'] = stale;
      // The resume poll (the second status() call) resolves normally.
      api.statuses.add(GimtelStatus.completed);

      final c = make(api);
      var completed = 0;
      c.onCompleted(() => completed++);

      c.submitPhone('36551929');
      async.flushMicrotasks(); // first poll goes out and hangs on `stale`.
      expect(api.statusCalls, 1);
      expect(c.status, GimtelStatus.pending);

      c.didChangeAppLifecycleState(AppLifecycleState.paused);
      c.didChangeAppLifecycleState(AppLifecycleState.resumed);
      async.flushMicrotasks();

      // The resume poll must go out immediately despite the still-in-flight
      // stale request, and must be the one that resolves the payment.
      expect(api.statusCalls, 2,
          reason:
              'resume poll is sent immediately despite a stale in-flight request');
      expect(c.status, GimtelStatus.completed);
      expect(completed, 1);

      // The stale request finally resolves 'completed' too: it must not
      // double-fire onCompleted.
      stale.complete(GimtelStatus.completed);
      async.flushMicrotasks();
      expect(completed, 1);

      c.dispose();
    });
  });

  test(
      'a stale poll resolving pending after the resume poll already '
      'completed the payment does not move status backwards, and does not '
      're-fire onCompleted', () {
    fakeAsync((async) {
      final api = FakeApi();
      final stale = Completer<GimtelStatus>();
      api.pendingOnceFor['p1'] = stale; // pre-background poll: hangs.
      api.statuses.add(GimtelStatus.completed); // resume poll: completed.

      final c = make(api);
      var completed = 0;
      c.onCompleted(() => completed++);

      c.submitPhone('36551929');
      async.flushMicrotasks();
      expect(api.statusCalls, 1);

      c.didChangeAppLifecycleState(AppLifecycleState.paused);
      c.didChangeAppLifecycleState(AppLifecycleState.resumed);
      async.flushMicrotasks();

      expect(c.status, GimtelStatus.completed);
      expect(completed, 1);

      // The stale request finally resolves 'pending' (e.g. a cached value
      // from before the resume poll completed the payment): it must not
      // move `status` backwards, nor re-fire `onCompleted`.
      stale.complete(GimtelStatus.pending);
      async.flushMicrotasks();
      expect(c.status, GimtelStatus.completed,
          reason: "a stale 'pending' response must not undo completion");
      expect(completed, 1);

      c.dispose();
    });
  });

  test(
      'the stale request resolving while the resume poll is still in flight '
      'does not let a third, overlapping request go out', () {
    fakeAsync((async) {
      final api = FakeApi();
      final stale = Completer<GimtelStatus>(); // pre-background poll.
      final resumePoll = Completer<GimtelStatus>(); // the resume poll.
      api.queuedGatesFor['p1'] = [stale, resumePoll];

      final c = make(api);
      c.submitPhone('36551929');
      async.flushMicrotasks();
      expect(api.statusCalls, 1); // `stale` is in flight.

      c.didChangeAppLifecycleState(AppLifecycleState.paused);
      c.didChangeAppLifecycleState(AppLifecycleState.resumed);
      async.flushMicrotasks();
      expect(api.statusCalls, 2); // the resume poll went out immediately.

      // `stale` finally resolves *while the resume poll is still pending*.
      stale.complete(GimtelStatus.pending);
      async.flushMicrotasks();

      // The next periodic tick must not be let through: `resumePoll` is
      // still the one legitimately in flight, so the in-flight guard must
      // still block a third request, leaving `resumePoll` the only
      // outstanding request from here on.
      async.elapse(const Duration(seconds: 4));
      expect(api.statusCalls, 2,
          reason:
              "stale's late resolution must not have freed the in-flight "
              'marker that belongs to the still-pending resume poll');
      // `stale` and `resumePoll` briefly overlapping (2) is expected and
      // intentional (that's what lets the resume poll go out immediately);
      // what must never happen is a *third* request piling on once `stale`
      // settles while `resumePoll` is still outstanding.
      expect(api.maxConcurrentStatusCalls, 2,
          reason: 'only the resume poll and the stale request ever overlap; '
              'no third concurrent request is ever created');

      resumePoll.complete(GimtelStatus.pending);
      async.flushMicrotasks();

      c.dispose();
    });
  });

  test('changeNumber while createPayment is pending discards the stale result',
      () {
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
