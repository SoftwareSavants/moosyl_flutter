import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moosyl_flutter/src/gimtel/gimtel_rich_text.dart';

const _base = TextStyle(fontSize: 14);
const _bold = TextStyle(fontSize: 14, fontWeight: FontWeight.w700);

List<InlineSpan> _parse(String template) => gimtelRichSpans(
      template,
      base: _base,
      bold: _bold,
      gimtelBadge: (text) => Text('badge:$text'),
    );

TextSpan _text(InlineSpan span) => span as TextSpan;

void main() {
  group('gimtelRichSpans', () {
    test('keeps runs in order with the right kind and style', () {
      final spans =
          _parse('Open <g>Gimtel</g>, pay <n>36 55</n> then tap <b>Send</b>.');

      expect(spans, hasLength(7));
      expect(_text(spans[0]).text, 'Open ');
      expect(_text(spans[0]).style, _base);

      final badge = spans[1] as WidgetSpan;
      expect((badge.child as Text).data, 'badge:Gimtel');

      expect(_text(spans[2]).text, ', pay ');
      // Numbers stay left-to-right inside Arabic text.
      expect(_text(spans[3]).text, '\u206636 55\u2069');
      expect(_text(spans[3]).style, _bold);
      expect(_text(spans[4]).text, ' then tap ');
      expect(_text(spans[5]).text, 'Send');
      expect(_text(spans[5]).style, _bold);
      expect(_text(spans[6]).text, '.');
    });

    test('a template without tags is one plain run', () {
      final spans = _parse('Nothing to see');
      expect(spans, hasLength(1));
      expect(_text(spans.single).text, 'Nothing to see');
      expect(_text(spans.single).style, _base);
    });

    test('unbalanced or unknown tags stay literal instead of throwing', () {
      for (final template in [
        '<b>Gimtel',
        'Gimtel</b>',
        '<b>Gimtel</n>',
        '<i>Gimtel</i>',
      ]) {
        final spans = _parse(template);
        expect(spans.map((s) => _text(s).text).join(), template,
            reason: template);
        expect(spans.every((s) => _text(s).style == _base), isTrue,
            reason: template);
      }
    });

    test('a tagged run may span lines', () {
      final spans = _parse('<b>two\nlines</b>');
      expect(_text(spans.single).text, 'two\nlines');
      expect(_text(spans.single).style, _bold);
    });
  });

  testWidgets('GimtelBadge stays left-to-right inside RTL text',
      (tester) async {
    await tester.pumpWidget(const Directionality(
      textDirection: TextDirection.rtl,
      child: Center(child: GimtelBadge('جيمتل')),
    ));
    final g = tester.getCenter(find.text('G'));
    final label = tester.getCenter(find.text('جيمتل'));
    expect(g.dx, lessThan(label.dx));
  });
}
