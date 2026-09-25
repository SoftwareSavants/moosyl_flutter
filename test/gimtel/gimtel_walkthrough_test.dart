import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moosyl_flutter/src/gimtel/gimtel_walkthrough.dart';
import 'package:moosyl_flutter/src/gimtel/gimtel_walkthrough_data.dart';

final _screens = gimtelWalkthroughs['bankily']!;
const _values = {
  GimtelFieldValue.bank: 'BIMBANK',
  GimtelFieldValue.phone: '30393659',
  GimtelFieldValue.amount: '100 MRU',
};
const _captions = ['c1', 'c2', 'c3', 'c4'];
const _phone = ValueKey('gimtel-walkthrough-phone');

Future<void> _pump(WidgetTester tester, {bool disableAnimations = false}) {
  return tester.pumpWidget(MaterialApp(
    home: Directionality(
      textDirection: TextDirection.rtl,
      child: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(disableAnimations: disableAnimations),
          child: Scaffold(
            body: SingleChildScrollView(
              child: Center(
                child: GimtelWalkthrough(
                  screens: _screens,
                  captions: _captions,
                  values: _values,
                  accent: const Color(0xFF0B7A75),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  ));
}

/// Asset of the screenshot currently shown.
String _asset(WidgetTester tester) {
  final image = tester.widget<Image>(find.byType(Image)).image as AssetImage;
  expect(image.package, 'moosyl_flutter');
  return image.assetName;
}

Duration _ms(int ms) => Duration(milliseconds: ms);

/// Lets a caption switch settle so only the new caption remains.
Future<void> _settleCaption(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(_ms(300));
}

Future<void> _tap(WidgetTester tester, {required bool right}) async {
  final rect = tester.getRect(find.byKey(_phone));
  await tester.tapAt(rect.center + Offset(right ? 40 : -40, 0));
  await tester.pump();
}

void main() {
  testWidgets('starts on screen 1 and advances exactly at its duration',
      (tester) async {
    await _pump(tester);
    expect(_asset(tester), _screens[0].asset);
    expect(find.text('c1'), findsOneWidget);

    await tester.pump(_ms(gimtelScreenDurationMs(_screens[0]) - 100));
    await tester.pump();
    expect(_asset(tester), _screens[0].asset);

    await tester.pump(_ms(100));
    await tester.pump(_ms(1));
    expect(_asset(tester), _screens[1].asset);
    await _settleCaption(tester);
    expect(find.text('c2'), findsOneWidget);
    expect(find.text('c1'), findsNothing);
  });

  testWidgets('screen 3 overlays the payer values on its fields',
      (tester) async {
    await _pump(tester);
    expect(find.text('BIMBANK'), findsNothing);

    await tester.pump(_ms(gimtelScreenDurationMs(_screens[0])));
    await tester.pump(_ms(1));
    await tester.pump(_ms(gimtelScreenDurationMs(_screens[1])));
    await tester.pump(_ms(1));
    expect(_asset(tester), _screens[2].asset);
    await tester.pump(_ms(1800)); // all three chips have popped in

    for (final value in _values.values) {
      expect(find.text(value), findsOneWidget);
      final opacity = tester.widget<FadeTransition>(find
          .ancestor(of: find.text(value), matching: find.byType(FadeTransition))
          .first);
      expect(opacity.opacity.value, 1.0, reason: value);
    }
  });

  testWidgets('loops from the last screen back to the first', (tester) async {
    await _pump(tester);
    for (final screen in _screens) {
      expect(_asset(tester), screen.asset);
      await tester.pump(_ms(gimtelScreenDurationMs(screen)));
      await tester.pump(_ms(1));
    }
    expect(_asset(tester), _screens[0].asset);
  });

  testWidgets('right half goes to the next screen, left half to the previous',
      (tester) async {
    await _pump(tester);
    await _tap(tester, right: true);
    expect(_asset(tester), _screens[1].asset);

    await _tap(tester, right: false);
    expect(_asset(tester), _screens[0].asset);

    // Going back from the first screen wraps to the last.
    await _tap(tester, right: false);
    expect(_asset(tester), _screens.last.asset);

    // A manual step restarts the full duration of the new screen.
    await tester.pump(_ms(gimtelScreenDurationMs(_screens.last) - 100));
    expect(_asset(tester), _screens.last.asset);
  });

  testWidgets('pauses while long-pressed and resumes on release',
      (tester) async {
    await _pump(tester);
    final gesture =
        await tester.startGesture(tester.getCenter(find.byKey(_phone)));
    await tester.pump(kLongPressTimeout + _ms(50));
    await tester.pump(_ms(10000));
    await tester.pump();
    expect(_asset(tester), _screens[0].asset);

    await gesture.up();
    await tester.pump();
    // Still on screen 1: releasing a long press is not a tap.
    expect(_asset(tester), _screens[0].asset);
    await tester.pump(_ms(gimtelScreenDurationMs(_screens[0])));
    await tester.pump(_ms(1));
    expect(_asset(tester), _screens[1].asset);
  });

  testWidgets('with animations disabled it is static and manual',
      (tester) async {
    await _pump(tester, disableAnimations: true);
    await tester.pump(_ms(10000));
    await tester.pump();
    expect(_asset(tester), _screens[0].asset);
    expect(tester.binding.transientCallbackCount, 0,
        reason: 'nothing should be ticking');

    await _tap(tester, right: true);
    await _tap(tester, right: true);
    expect(_asset(tester), _screens[2].asset);
    // The final frame: values are fully shown without waiting.
    final opacity = tester.widget<FadeTransition>(find
        .ancestor(
            of: find.text('BIMBANK'), matching: find.byType(FadeTransition))
        .first);
    expect(opacity.opacity.value, 1.0);
  });

  testWidgets('the screenshot stays left-to-right under an RTL app',
      (tester) async {
    await _pump(tester);
    // The brief's ancestor check would also match MaterialApp's own LTR
    // Directionality, so check the one that actually applies.
    expect(Directionality.of(tester.element(find.byType(Image))),
        TextDirection.ltr);
    // The caption follows the app: in RTL the step number is on the right.
    expect(tester.getCenter(find.text('1')).dx,
        greaterThan(tester.getCenter(find.text('c1')).dx));
  });

  testWidgets('disposing mid-animation leaves nothing ticking', (tester) async {
    await _pump(tester);
    // Past the tap: the ripple loop is running.
    await tester.pump(_ms(gimtelScreenDurationMs(_screens[0]) - 200));
    expect(tester.binding.transientCallbackCount, greaterThan(0));

    await tester.pumpWidget(const SizedBox());
    expect(tester.binding.transientCallbackCount, 0);
    expect(tester.takeException(), isNull);
  });
}
