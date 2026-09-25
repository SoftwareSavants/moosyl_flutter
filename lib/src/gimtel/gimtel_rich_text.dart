import 'package:flutter/widgets.dart';

/// Bank apps' teal "G" mark color for Gimtel.
const Color gimtelBadgeColor = Color(0xFF3AA7BD);

/// A known tag with its matching closing tag; tags do not nest.
final RegExp _tagged = RegExp(r'<(b|n|g)>(.*?)</\1>', dotAll: true);

/// Keeps a run left-to-right inside right-to-left text (Unicode LRI … PDI).
String _ltr(String text) => '\u2066$text\u2069';

/// Splits a translated caption template into spans: `<b>` bold, `<n>` a bold
/// left-to-right number or label, `<g>` the Gimtel badge built by
/// [gimtelBadge]. Anything that is not a balanced known tag stays literal
/// text in [base]; this never throws.
List<InlineSpan> gimtelRichSpans(
  String template, {
  required TextStyle base,
  required TextStyle bold,
  required Widget Function(String text) gimtelBadge,
}) {
  final spans = <InlineSpan>[];
  var last = 0;
  for (final match in _tagged.allMatches(template)) {
    if (match.start > last) {
      spans.add(
          TextSpan(text: template.substring(last, match.start), style: base));
    }
    final text = match.group(2)!;
    switch (match.group(1)) {
      case 'b':
        spans.add(TextSpan(text: text, style: bold));
      case 'n':
        spans.add(TextSpan(text: _ltr(text), style: bold));
      case 'g':
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: gimtelBadge(text),
        ));
    }
    last = match.end;
  }
  if (last < template.length) {
    spans.add(TextSpan(text: template.substring(last), style: base));
  }
  return spans;
}

/// "Gimtel" with the round G mark the bank apps use for it, so payers
/// recognize the menu. Always laid out left-to-right.
class GimtelBadge extends StatelessWidget {
  /// Creates a badge labelled [text]; [style] styles the label and [size] is
  /// the mark's diameter.
  const GimtelBadge(this.text, {super.key, this.style, this.size = 16});

  /// The label next to the mark, e.g. "Gimtel".
  final String text;

  /// Style of the label; bold by default.
  final TextStyle? style;

  /// Diameter of the round mark.
  final double size;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ExcludeSemantics(
            child: Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: gimtelBadgeColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                'G',
                textScaler: TextScaler.noScaling,
                style: TextStyle(
                  color: const Color(0xFFFFFFFF),
                  fontSize: (size * 0.6).roundToDouble(),
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
          ),
          SizedBox(width: size / 4),
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w700).merge(style),
          ),
        ],
      ),
    );
  }
}
