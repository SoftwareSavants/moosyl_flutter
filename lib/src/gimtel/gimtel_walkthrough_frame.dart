part of 'gimtel_walkthrough.dart';

/// The phone bezel around the screenshot area.
class _PhoneFrame extends StatelessWidget {
  const _PhoneFrame({required this.width, required this.child});

  final double width;

  /// The screenshot area, laid out at the screenshots' aspect ratio.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        border: Border.all(color: const Color(0xFF171717), width: 6),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x59000000),
            blurRadius: 20,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        // The screenshots are left-to-right apps: pin LTR so in Arabic the
        // ring and chips don't anchor to the wrong edge.
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: AspectRatio(aspectRatio: 400 / 826, child: child),
        ),
      ),
    );
  }
}

/// The step number and the screen's caption; follows the app's direction.
class _Caption extends StatelessWidget {
  const _Caption({
    super.key,
    required this.number,
    required this.template,
    required this.accent,
  });

  final int number;

  /// Caption template, see `gimtelRichSpans`.
  final String template;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final base = TextStyle(
      fontSize: 14,
      height: 20 / 14,
      color: colors.onSurfaceVariant,
    );
    final bold = base.copyWith(
      fontWeight: FontWeight.w700,
      color: colors.onSurface,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          margin: const EdgeInsets.only(top: 1),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          child: Text(
            '$number',
            textScaler: TextScaler.noScaling,
            style: const TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text.rich(
            TextSpan(
              style: base,
              children: gimtelRichSpans(
                template,
                base: base,
                bold: bold,
                gimtelBadge: (text) => GimtelBadge(text, style: bold),
              ),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
