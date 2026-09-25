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

  /// `'invalidPhone'`, the server's error message, or `null`.
  String? error;

  /// What the payer needs to complete the transfer, once created.
  GimtelInstructions? instructions;

  /// The current payment's status, as last observed by polling.
  GimtelStatus status = GimtelStatus.pending;

  Timer? _timer;

  /// The paymentId a `status()` call is currently in flight for, if any.
  /// Scoped per payment (not a single boolean) so a still-in-flight poll for
  /// a superseded payment can't block the new payment's first poll.
  String? _inFlightFor;

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
      error = e.toString();
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

  /// Sandbox-only: simulates the payer's bank transfer, then polls once.
  Future<void> simulate() async {
    final id = instructions?.paymentId;
    if (id == null) return;
    await api.simulateTransfer(id);
    await _poll(id);
  }

  void _startPolling(String paymentId) {
    _stopPolling();
    if (!_foreground) return;
    unawaited(_poll(paymentId));
    _timer = Timer.periodic(pollInterval, (_) => _poll(paymentId));
  }

  void _stopPolling() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _poll(String paymentId) async {
    if (_inFlightFor == paymentId) return;
    _inFlightFor = paymentId;
    try {
      final next = await api.status(paymentId);
      if (_disposed) return;
      if (paymentId != instructions?.paymentId || step != GimtelStep.pay) {
        // Stale: this response was for a payment we've since moved on from
        // (changeNumber(), a newer create, ...). Ignore it entirely.
        return;
      }
      if (next != status) {
        status = next;
        notifyListeners();
      }
      if (next != GimtelStatus.pending) {
        _stopPolling();
        if (next == GimtelStatus.completed) _onCompleted?.call();
      }
    } catch (_) {
      // Network blip: the next tick retries.
    } finally {
      if (_inFlightFor == paymentId) _inFlightFor = null;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (step != GimtelStep.pay) return;
    final id = instructions?.paymentId;
    if (id == null) return;
    if (_foreground) {
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
