import 'package:flutter_test/flutter_test.dart';

import 'package:example/main.dart';

void main() {
  testWidgets('shows Moosyl demo menu actions', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Moosyl Demo'), findsWidgets);
    expect(find.text('Test MoosylView'), findsOneWidget);
    expect(find.text('Test embedded platforms'), findsOneWidget);
    expect(find.text('Test custom methods UI'), findsOneWidget);
  });
}
