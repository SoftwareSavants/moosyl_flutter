import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:moosyl_flutter/src/gimtel/gimtel_api.dart';
import 'package:moosyl_flutter/src/gimtel/gimtel_models.dart';
import 'package:moosyl_flutter/src/gimtel/gimtel_phone.dart';

/// Which step of the Gimtel sheet is showing.
enum GimtelStep {
  /// Collecting (or correcting) the payer's phone number.
  phone,

  /// Showing payment instructions and polling for their status.
  pay,
}

/// Owns the Gimtel flow: phone -> create payment -> poll (heartbeat) until a
/// terminal status. Polling pauses while the app is in the background (the
/// payer is in their bank app) and resumes (with an immediate poll) when the
/// app comes back to the foreground.
///
/// Payment identity is re-checked after every await: a poll or a
/// `createPayment` response that resolves after the user has moved on
/// (`changeNumber()`, a newer `submitPhone()`/`startAgain()` call, or
/// `dispose()`) is dropped rather than applied to whatever payment is
/// current by the time it arrives. See the in-flight/stale-response guards
/// below.
class GimtelController extends ChangeNotifier with WidgetsBindingObserver {
  /// Creates a controller for a single Gimtel payment flow.
  GimtelController({
    required this.api,
    required this.configurationId,
    required this.transactionId,
    required String initialPhone,
    this.pollInterval = const Duration(seconds: 4),
  }) : phone = normalizeGimtelPhone(initialPhone) ?? '' {
    WidgetsBinding.instance.addObserver(this);
  }

  /// The backend the controller talks to.
  final GimtelApi api;

  /// The Gimtel configuration to create the payment under.
  final String configurationId;

  /// The transaction this Gimtel payment pays for.
  final String transactionId;

  /// How often to poll for a status update while the app is foregrounded.
  final Duration pollInterval;

  /// Which step of the flow is currently showing.
  GimtelStep step = GimtelStep.phone;

  /// The payer's phone number, normalized to 8 local digits once valid.
  String phone;

  /// Whether a `submitPhone()`/`startAgain()` call is in flight.
  bool submitting = false;

  /// `'invalidPhone'`, the error thrown by [api] (render it with
  /// `gimtelErrorMessage`, never `toString()`), or `null`.
  Object? error;

  /// What the payer needs to complete the transfer, once created.
  GimtelInstructions? instructions;

  /// The current payment's status, as last observed by polling.
  GimtelStatus status = GimtelStatus.pending;

  Timer? _timer;

  /// The paymentId a `status()` call is currently in flight for, if any.
  /// Scoped per payment (not a single boolean) so a still-in-flight poll for
  /// a superseded payment can't block the new payment's first poll.
  String? _inFlightFor;

  /// Identifies *which* `_poll()` invocation currently owns `_inFlightFor`.
  /// Bumped on every `_poll()` call; a call only clears `_inFlightFor` in its
  /// `finally` if this still matches the token it captured. Without this, a
  /// stale request for the same payment id (e.g. one still in flight when
  /// `didChangeAppLifecycleState` force-clears `_inFlightFor` for a resume
  /// poll) would clear the *new* poll's in-flight marker when it finally
  /// settles, letting a third, overlapping request go out on the next tick.
  int _pollToken = 0;
  int? _inFlightToken;

  bool _foreground = true;
  bool _disposed = false;
  VoidCallback? _onCompleted;

  /// Bumped on every `_create()` call, on `changeNumber()`, and on
  /// `dispose()`. A `createPayment()` response is only applied when this
  /// still matches the token captured before the call was made; otherwise a
  /// newer create (or a changeNumber/dispose) has already superseded it.
  int _createToken = 0;

  /// Registers the single listener invoked when a payment completes.
  void onCompleted(VoidCallback callback) => _onCompleted = callback;

  /// Validates and normalizes [input]; on success, creates the payment and
  /// moves to [GimtelStep.pay]. On failure, sets [error] to `'invalidPhone'`.
  Future<void> submitPhone(String input) async {
    final normalized = normalizeGimtelPhone(input);
    if (normalized == null) {
      error = 'invalidPhone';
      notifyListeners();
      return;
    }
    phone = normalized;
    await _create();
  }

  Future<void> _create() async {
    final token = ++_createToken;
    submitting = true;
    error = null;
    _stopPolling();
    notifyListeners();

    GimtelInstructions result;
    try {
      result = await api.createPayment(
        configurationId: configurationId,
        transactionId: transactionId,
        phoneNumber: phone,
      );
    } catch (e) {
      if (_disposed || token != _createToken) return;
      submitting = false;
      error = e;
      notifyListeners();
      return;
    }

    if (_disposed || token != _createToken) {
      // Superseded by changeNumber(), a newer create, or dispose() while
      // this request was in flight: discard the result entirely.
      return;
    }

    instructions = result;
    status = GimtelStatus.pending;
    step = GimtelStep.pay;
    submitting = false;
    notifyListeners();
    _startPolling(result.paymentId);
  }

  /// Abandons the current payment (if any) and returns to [GimtelStep.phone]
  /// so the payer can correct their number.
  void changeNumber() {
    _createToken++; // invalidate any in-flight createPayment()/poll.
    _stopPolling();
    instructions = null; // clear the current payment id: late results are ignored.
    step = GimtelStep.phone;
    submitting = false;
    error = null;
    notifyListeners();
  }

  /// Creates a fresh payment for the same [phone] (e.g. after expiry).
  Future<void> startAgain() => _create();

  /// Sandbox-only: simulates the payer's bank transfer, then polls once. A
  /// no-op once the payment has already reached a terminal status.
  Future<void> simulate() async {
    final id = instructions?.paymentId;
    if (id == null || status != GimtelStatus.pending) return;
    try {
      await api.simulateTransfer(id);
    } catch (e) {
      if (_disposed) return;
      error = e;
      notifyListeners();
      return;
    }
    await _poll(id);
  }

  void _startPolling(String paymentId) {
    _stopPolling();
    // Never (re)start polling for a payment that's already terminal: e.g. a
    // background/foreground cycle (or a stray simulate()) after completion
    // must not re-poll and re-fire onCompleted.
    if (!_foreground || status != GimtelStatus.pending) return;
    unawaited(_poll(paymentId));
    _timer = Timer.periodic(pollInterval, (_) => _poll(paymentId));
  }

  void _stopPolling() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _poll(String paymentId) async {
    if (_inFlightFor == paymentId) return;
    final token = ++_pollToken;
    _inFlightFor = paymentId;
    _inFlightToken = token;
    GimtelStatus? next;
    try {
      next = await api.status(paymentId);
    } catch (_) {
      // Network blip: the next tick retries. Only the network call itself is
      // guarded here - a throw from notifyListeners()/onCompleted() below
      // must propagate normally, not be swallowed as a "blip".
    } finally {
      // Only clear the marker if it's still ours: a resume poll may have
      // force-cleared and re-set `_inFlightFor`/`_inFlightToken` for the same
      // paymentId while this (stale) call was in flight, and this call must
      // not clear the newer poll's marker out from under it.
      if (_inFlightFor == paymentId && _inFlightToken == token) {
        _inFlightFor = null;
        _inFlightToken = null;
      }
    }
    if (next == null || _disposed) return;
    if (paymentId != instructions?.paymentId || step != GimtelStep.pay) {
      // Stale: this response was for a payment we've since moved on from
      // (changeNumber(), a newer create, ...). Ignore it entirely.
      return;
    }
    if (status != GimtelStatus.pending) {
      // Already terminal: a stale request (e.g. one still in flight from
      // before the app was backgrounded) resolving after a newer poll
      // already completed this payment must not move `status` backwards or
      // re-fire `onCompleted`. `startAgain()` resets `status` to `pending`
      // for the next attempt, so this never blocks a genuinely new payment.
      return;
    }
    if (next != GimtelStatus.pending) {
      status = next;
      notifyListeners();
      _stopPolling();
      if (next == GimtelStatus.completed) {
        _onCompleted?.call();
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (step != GimtelStep.pay) return;
    final id = instructions?.paymentId;
    if (id == null) return;
    if (_foreground) {
      // A status request started before backgrounding may still be in
      // flight (hung, or slow to fail/succeed on the OS side) - without
      // this, the per-payment in-flight guard in `_poll` would silently
      // drop the resume poll. Force-clearing both fields lets a fresh poll
      // go out immediately; `_poll`'s token check then keeps that stale
      // request's eventual `finally` from clobbering the new poll's marker,
      // and its result (if it arrives) is dropped by the paymentId/step
      // check or the terminal-status check above.
      if (_inFlightFor == id) {
        _inFlightFor = null;
        _inFlightToken = null;
      }
      _startPolling(id);
    } else {
      _stopPolling();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _createToken++;
    _stopPolling();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
