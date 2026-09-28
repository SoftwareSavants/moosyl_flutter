import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moosyl/moosyl.dart' show ConfigurationListDataInner;
import 'package:moosyl_flutter/l10n/moosyl_localization.dart';
import 'package:moosyl_flutter/src/gimtel/gimtel_models.dart';
import 'package:moosyl_flutter/src/models/payment_method_model.dart';
import 'package:moosyl_flutter/src/pages/bankily_view.dart';
import 'package:moosyl_flutter/src/pages/payment_methods_view.dart';
import 'package:moosyl_flutter/src/providers/get_payment_methods_provider.dart';
import 'package:provider/provider.dart';

import 'fake_services.dart';
import 'gimtel/fake_gimtel_api.dart';

const _gimtelSheet = ValueKey('gimtel-sheet');

void main() {
  group('isGimtelMethod', () {
    final cases = <(String, String), bool>{
      ('bankily', 'gimtel'): true,
      ('bankily', 'native'): false,
      ('bci_pay', 'native'): true,
      ('bci_pay', 'gimtel'): true,
      ('amanty', 'native'): true,
      ('sedad', 'native'): false,
      ('bim_bank', 'native'): false,
      ('masrivi', 'native'): false,
    };
    cases.forEach((input, expected) {
      final (type, integration) = input;
      test('$type/$integration -> $expected', () {
        expect(
            isGimtelMethod(method(type, integration: integration)), expected);
      });
    });
  });

  test('tryParse returns null for an unknown type', () {
    expect(PaymentMethodTypes.tryParse('future_bank'), isNull);
    expect(PaymentMethodTypes.tryParse('bci_pay'), PaymentMethodTypes.bCIpay);
  });

  group('MoosylPaymentMethods', () {
    late FakeApi gimtelApi;
    late List<bool> successes;

    Future<MoosylPaymentMethodsController> pumpMethods(
      WidgetTester tester,
      List<ConfigurationListDataInner> methods,
    ) async {
      tester.view.physicalSize = const Size(1200, 2700);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      gimtelApi = FakeApi();
      successes = [];
      final controller = MoosylPaymentMethodsController();
      addTearDown(controller.dispose);
      final provider = GetPaymentMethodsProvider(
        publishableApiKey: 'pk_test',
        transactionId: 't1',
        totalAmount: 0,
        methodsService: FakeMethodsService(methods),
        requestService: FakeRequestService(),
        gimtelApi: gimtelApi,
      );

      await tester.pumpWidget(MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: MoosylLocalization.localizationsDelegates,
        supportedLocales: MoosylLocalization.supportedLocales,
        home: Scaffold(
          body: ChangeNotifierProvider.value(
            value: provider,
            child: SingleChildScrollView(
              child: MoosylPaymentMethods(
                publishableApiKey: 'pk_test',
                transactionId: 't1',
                controller: controller,
                onPaymentSuccess: successes.add,
              ),
            ),
          ),
        ),
      ));
      await tester.pump();
      await tester.pumpAndSettle();
      return controller;
    }

    Future<void> selectAndContinue(WidgetTester tester,
        MoosylPaymentMethodsController controller, String title) async {
      await tester.tap(find.text(title));
      await tester.pumpAndSettle();
      unawaited(controller.continuePayment());
      await tester.pumpAndSettle();
    }

    testWidgets('an unknown method type is skipped; known rows still render',
        (tester) async {
      await pumpMethods(tester, [
        method('bankily'),
        method('future_bank'),
        method('sedad'),
      ]);

      expect(tester.takeException(), isNull);
      expect(find.text('Bankily'), findsOneWidget);
      expect(find.text('Sedad'), findsOneWidget);
    });

    testWidgets('only Gimtel rows carry the "via Gimtel" subtitle',
        (tester) async {
      await pumpMethods(tester, [
        method('bankily'),
        method('bci_pay'),
      ]);

      expect(find.text('Via Gimtel'), findsOneWidget);
      expect(
        find.descendant(
          of: find.ancestor(
              of: find.text('BCI Pay'), matching: find.byType(InkWell)),
          matching: find.text('Via Gimtel'),
        ),
        findsOneWidget,
      );
    });

    for (final (type, integration, title) in [
      ('bankily', 'gimtel', 'Bankily'),
      ('bci_pay', 'native', 'BCI Pay'),
      ('amanty', 'native', 'Amanty'),
    ]) {
      testWidgets('$type/$integration opens the Gimtel sheet', (tester) async {
        final controller =
            await pumpMethods(tester, [method(type, integration: integration)]);

        await selectAndContinue(tester, controller, title);

        expect(find.byKey(_gimtelSheet), findsOneWidget);
        expect(find.byType(BankilyView), findsNothing);
      });
    }

    testWidgets('a completed Gimtel payment reports success exactly once',
        (tester) async {
      final controller =
          await pumpMethods(tester, [method('bankily', integration: 'gimtel')]);
      gimtelApi.statuses.add(GimtelStatus.completed);
      await selectAndContinue(tester, controller, 'Bankily');

      await tester.enterText(
          find.byKey(const ValueKey('gimtel-phone-input')), '36551929');
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('gimtel-continue')));
      await tester.pumpAndSettle();

      expect(successes, [true]);
      expect(find.byKey(_gimtelSheet), findsNothing);
    });

    testWidgets('leaving the Gimtel sheet reports nothing', (tester) async {
      final controller =
          await pumpMethods(tester, [method('bankily', integration: 'gimtel')]);
      await selectAndContinue(tester, controller, 'Bankily');

      await tester.tap(find.byKey(const ValueKey('gimtel-other-method')));
      await tester.pumpAndSettle();

      expect(find.byKey(_gimtelSheet), findsNothing);
      expect(successes, isEmpty);
    });

    testWidgets('native Bankily opens the existing passcode dialog',
        (tester) async {
      final controller = await pumpMethods(tester, [method('bankily')]);

      await selectAndContinue(tester, controller, 'Bankily');

      expect(find.byType(BankilyView), findsOneWidget);
      expect(find.byKey(_gimtelSheet), findsNothing);
      expect(gimtelApi.createCalls, 0);
    });
  });
}
