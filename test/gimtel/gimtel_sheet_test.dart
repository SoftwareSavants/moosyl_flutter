import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moosyl/moosyl.dart' show ConfigurationListDataInner;
import 'package:moosyl_flutter/l10n/moosyl_localization.dart';
import 'package:moosyl_flutter/src/gimtel/gimtel_models.dart';
import 'package:moosyl_flutter/src/gimtel/gimtel_sheet.dart';
import 'package:moosyl_flutter/src/gimtel/gimtel_walkthrough.dart';

import 'fake_gimtel_api.dart';

const _host = ValueKey('host');
const _phoneInput = ValueKey('gimtel-phone-input');
const _phoneError = ValueKey('gimtel-phone-error');
const _continue = ValueKey('gimtel-continue');
const _payStep = ValueKey('gimtel-pay-step');
const _merchant = ValueKey('gimtel-merchant-number');
const _amount = ValueKey('gimtel-amount');
const _copyMerchant = ValueKey('gimtel-copy-merchant');
const _copiedMerchant = ValueKey('gimtel-copied-merchant');
const _copyAmount = ValueKey('gimtel-copy-amount');
const _waitingHint = ValueKey('gimtel-waiting-hint');
const _textSteps = ValueKey('gimtel-text-steps');
const _simulate = ValueKey('gimtel-simulate');
const _otherMethod = ValueKey('gimtel-other-method');
const _terminal = ValueKey('gimtel-terminal');
const _startAgain = ValueKey('gimtel-start-again');

ConfigurationListDataInner _method(
        {String type = 'bankily', bool testing = false}) =>
    ConfigurationListDataInner((b) => b
      ..id = 'c1'
      ..type = type
      ..integration = 'gimtel'
      ..isTestingMode = testing);

/// Pumps an app with a pushed "host" page (so an extra pop would be visible)
/// and opens the sheet from it. Returns every value the sheet resolved with.
Future<List<bool>> _open(
  WidgetTester tester,
  FakeApi api, {
  String type = 'bankily',
  bool testing = false,
  String initialPhone = '',
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = const Size(1200, 2700);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final navigator = GlobalKey<NavigatorState>();
  late BuildContext hostContext;
  await tester.pumpWidget(MaterialApp(
    navigatorKey: navigator,
    locale: locale,
    localizationsDelegates: MoosylLocalization.localizationsDelegates,
    supportedLocales: MoosylLocalization.supportedLocales,
    home: const Scaffold(body: SizedBox.expand()),
  ));
  navigator.currentState!.push(MaterialPageRoute<void>(
    builder: (_) => Scaffold(
      key: _host,
      body: Builder(builder: (context) {
        hostContext = context;
        return const SizedBox.expand();
      }),
    ),
  ));
  await tester.pumpAndSettle();

  final results = <bool>[];
  unawaited(showGimtelSheet(
    hostContext,
    api: api,
    method: _method(type: type, testing: testing),
    methodLabel: 'Bankily',
    transactionId: 't1',
    amount: 100,
    initialPhone: initialPhone,
    accent: const Color(0xFF0B7A75),
  ).then(results.add));
  await tester.pumpAndSettle();
  return results;
}

/// Lets frames run without waiting for the (endless) walkthrough and pulse
/// animations to settle.
Future<void> _frames(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _submit(WidgetTester tester, String phone) async {
  await tester.enterText(find.byKey(_phoneInput), phone);
  await tester.pump(); // enables Continue once there is text
  await tester.tap(find.byKey(_continue));
  await _frames(tester);
}

Future<void> _tap(WidgetTester tester, Key key) async {
  await tester.ensureVisible(find.byKey(key));
  await tester.pump();
  await tester.tap(find.byKey(key));
  await _frames(tester);
}

String _text(WidgetTester tester, Key key) {
  final text = tester.widget<Text>(find.byKey(key));
  return text.data ?? text.textSpan!.toPlainText();
}

void main() {
  testWidgets('prefills a valid initial phone, normalized', (tester) async {
    await _open(tester, FakeApi(), initialPhone: '+222 36 55 19 29');
    expect(tester.widget<TextField>(find.byKey(_phoneInput)).controller!.text,
        '36551929');
  });

  testWidgets('an invalid number shows an inline error and never calls the API',
      (tester) async {
    final api = FakeApi();
    await _open(tester, api);
    expect(find.byKey(_phoneError), findsNothing);
    await _submit(tester, '123');
    expect(find.byKey(_phoneError), findsOneWidget);
    expect(api.createCalls, 0);
    expect(find.byKey(_payStep), findsNothing);
  });

  testWidgets(
      'a valid number shows the merchant number, amount, grouped payer phone '
      'and the bank walkthrough', (tester) async {
    final api = FakeApi();
    await _open(tester, api);
    await _submit(tester, '36551929');
    expect(api.lastPhone, '36551929');
    expect(find.byKey(_payStep), findsOneWidget);
    expect(_text(tester, _merchant), contains('30393659'));
    expect(_text(tester, _amount), contains('100 MRU'));
    expect(_text(tester, _waitingHint), contains('36 55 19 29'));
    expect(find.byType(GimtelWalkthrough), findsOneWidget);
    expect(find.byKey(_textSteps), findsNothing);
  });

  testWidgets('a bank without a walkthrough gets 3 filled-in text steps',
      (tester) async {
    await _open(tester, FakeApi(), type: 'amanty');
    await _submit(tester, '36551929');
    expect(find.byType(GimtelWalkthrough), findsNothing);
    expect(find.byKey(_textSteps), findsOneWidget);
    for (var i = 0; i < 3; i++) {
      expect(find.byKey(ValueKey('gimtel-text-step-$i')), findsOneWidget);
    }
    expect(find.byKey(const ValueKey('gimtel-text-step-3')), findsNothing);
    final step2 = _text(tester, const ValueKey('gimtel-text-step-1'));
    expect(step2, contains('30393659'));
    expect(step2, contains('100 MRU'));
  });

  testWidgets('copy tiles write the raw value to the clipboard',
      (tester) async {
    final copied = <String>[];
    tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        copied.add((call.arguments as Map)['text'] as String);
      }
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));

    await _open(tester, FakeApi());
    await _submit(tester, '36551929');
    expect(find.byKey(_copiedMerchant), findsNothing);

    await _tap(tester, _copyMerchant);
    expect(copied, ['30393659']);
    expect(find.byKey(_copiedMerchant), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1600));
    expect(find.byKey(_copiedMerchant), findsNothing);

    await _tap(tester, _copyAmount);
    expect(copied, ['30393659', '100'], reason: 'copies the bare amount');
  });

  testWidgets('a completed payment closes the sheet with true, exactly once',
      (tester) async {
    final api = FakeApi()..statuses.add(GimtelStatus.completed);
    final results = await _open(tester, api);
    await _submit(tester, '36551929');
    await tester.pumpAndSettle();
    expect(results, [true]);
    expect(find.byKey(_payStep), findsNothing);
    expect(find.byKey(_host), findsOneWidget,
        reason: 'must not pop the page under the sheet');
  });

  testWidgets(
      'a completion arriving while the sheet is already closing does not pop '
      'the page underneath', (tester) async {
    final api = FakeApi();
    final status = Completer<GimtelStatus>();
    api.pendingFor['p1'] = status;
    final results = await _open(tester, api);
    await _submit(tester, '36551929');

    await tester.ensureVisible(find.byKey(_otherMethod));
    await tester.pump();
    await tester.tap(find.byKey(_otherMethod));
    await tester.pump(const Duration(milliseconds: 50)); // mid close animation
    status.complete(GimtelStatus.completed);
    await tester.pumpAndSettle();

    expect(results, [false]);
    expect(find.byKey(_host), findsOneWidget);
  });

  testWidgets('an expired payment offers Start again, which re-creates it',
      (tester) async {
    final api = FakeApi()..statuses.add(GimtelStatus.expired);
    await _open(tester, api);
    await _submit(tester, '36551929');
    expect(find.byKey(_terminal), findsOneWidget);
    expect(find.byKey(_waitingHint), findsNothing);

    await _tap(tester, _startAgain);
    expect(api.createCalls, 2);
    expect(find.byKey(_terminal), findsNothing);
    expect(find.byKey(_waitingHint), findsOneWidget);
  });

  testWidgets(
      '"Use another method" closes with false and stops polling for good',
      (tester) async {
    final api = FakeApi();
    final results = await _open(tester, api);
    await _submit(tester, '36551929');
    await _tap(tester, _otherMethod);
    await tester.pumpAndSettle();
    expect(results, [false]);
    expect(find.byKey(_host), findsOneWidget);

    final calls = api.statusCalls;
    await tester.pump(const Duration(seconds: 20));
    expect(api.statusCalls, calls);
  });

  testWidgets('the phone step can be left with a visible button',
      (tester) async {
    final results = await _open(tester, FakeApi());
    await tester.tap(find.byKey(_otherMethod));
    await tester.pumpAndSettle();
    expect(results, [false]);
  });

  testWidgets('the phone step closes with false on a barrier tap',
      (tester) async {
    final results = await _open(tester, FakeApi());
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(results, [false]);
  });

  testWidgets('the pay step ignores barrier taps, drags and back',
      (tester) async {
    // Text steps keep the content short enough not to scroll, so a drag
    // reaches the sheet itself.
    final results = await _open(tester, FakeApi(), type: 'amanty');
    await _submit(tester, '36551929');

    await tester.tapAt(const Offset(10, 10));
    await _frames(tester);
    await tester.drag(find.byKey(_payStep), const Offset(0, 600));
    await _frames(tester);
    final nav = tester.state<NavigatorState>(find.byType(Navigator));
    await nav.maybePop();
    await _frames(tester);

    expect(results, isEmpty);
    expect(find.byKey(_payStep), findsOneWidget);
  });

  testWidgets('Simulate shows only for a testing-mode method', (tester) async {
    final api = FakeApi();
    await _open(tester, api, testing: true);
    await _submit(tester, '36551929');
    await _tap(tester, _simulate);
    expect(api.simulateCalls, 1);
  });

  testWidgets('Simulate is absent for a live method', (tester) async {
    await _open(tester, FakeApi());
    await _submit(tester, '36551929');
    expect(find.byKey(_simulate), findsNothing);
  });

  testWidgets('renders both steps in Arabic without layout errors',
      (tester) async {
    await _open(tester, FakeApi(), locale: const Locale('ar'));
    expect(Directionality.of(tester.element(find.byKey(_phoneInput))),
        TextDirection.rtl);
    await _submit(tester, '36551929');
    expect(find.byKey(_payStep), findsOneWidget);
    expect(_text(tester, _waitingHint), contains('36 55 19 29'));
    expect(tester.takeException(), isNull);
  });
}
