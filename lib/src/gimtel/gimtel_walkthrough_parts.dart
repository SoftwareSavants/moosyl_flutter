part of 'gimtel_walkthrough.dart';

const double _ring = 28;
const double _rippleSize = 40;
const double _finger = 28;

/// A field to fill, showing the payer's real value over the demo one.
class _FieldChip extends StatelessWidget {
  const _FieldChip({
    required this.field,
    required this.value,
    required this.accent,
    required this.appear,
    required this.area,
  });

  final GimtelField field;
  final String value;
  final Color accent;

  /// 0 → 1: the chip pops in.
  final Animation<double> appear;

  /// Size of the screenshot the percentages refer to.
  final Size area;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: area.width * field.x / 100,
      top: area.height * field.y / 100,
      width: area.width * field.w / 100,
      height: area.height * field.h / 100,
      child: FadeTransition(
        opacity: appear,
        child: ScaleTransition(
          scale: appear.drive(Tween(begin: 0.92, end: 1)),
          child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: accent, width: 2),
              boxShadow: [
                BoxShadow(color: accent.withAlpha(64), blurRadius: 3)
              ],
            ),
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textScaler: TextScaler.noScaling,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFF171717),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A hollow ring (so the label under it stays readable) with a ripple and a
/// finger that lands beside it and taps.
class _TapMarker extends StatelessWidget {
  const _TapMarker({
    required this.at,
    required this.accent,
    required this.dot,
    required this.finger,
    required this.press,
    required this.ripple,
    required this.still,
  });

  /// Where to tap, in pixels within the screenshot.
  final Offset at;
  final Color accent;

  /// 0 → 1: the ring pops in.
  final Animation<double> dot;

  /// 0 → 1: the finger slides in from the bottom right.
  final Animation<double> finger;

  /// 0 → 1: the finger presses down and releases.
  final Animation<double> press;

  /// 0 → 1, looping: the ripple grows and fades.
  final Animation<double> ripple;

  /// Reduced motion: a faint static ripple instead of the loop.
  final bool still;

  static final _rippleOpacity = TweenSequence([
    TweenSequenceItem(tween: Tween<double>(begin: 0, end: 0.9), weight: 15),
    TweenSequenceItem(tween: Tween<double>(begin: 0.9, end: 0), weight: 85),
  ]);
  static final _pressScale = TweenSequence([
    TweenSequenceItem(tween: Tween<double>(begin: 1, end: 0.86), weight: 55),
    TweenSequenceItem(tween: Tween<double>(begin: 0.86, end: 1), weight: 45),
  ]);

  Widget _circle(double size, Widget child) => Positioned(
        left: at.dx - size / 2,
        top: at.dy - size / 2,
        width: size,
        height: size,
        child: child,
      );

  @override
  Widget build(BuildContext context) {
    final rippleRing = DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: accent, width: 2),
      ),
    );
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _circle(
          _rippleSize,
          still
              ? Opacity(opacity: 0.35, child: rippleRing)
              : FadeTransition(
                  opacity: ripple.drive(_rippleOpacity),
                  child: ScaleTransition(
                    scale: ripple.drive(Tween(begin: 0.3, end: 1.9)),
                    child: rippleRing,
                  ),
                ),
        ),
        // A thin white halo keeps the ring visible on any screenshot colour.
        _circle(
          _ring + 4,
          FadeTransition(
            opacity: dot,
            child: ScaleTransition(
              scale: dot.drive(Tween(begin: 0.2, end: 1)),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xE6FFFFFF), width: 2),
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withAlpha(38),
                    border: Border.all(color: accent, width: 2.5),
                  ),
                ),
              ),
            ),
          ),
        ),
        // The fingertip of `touch_app` sits ~(11, 2) into the icon: offset
        // (4, 12) lands it beside the ring, like the web and RN versions.
        Positioned(
          left: at.dx + 4,
          top: at.dy + 12,
          child: AnimatedBuilder(
            animation: Listenable.merge([finger, press]),
            builder: (context, child) => Opacity(
              opacity: finger.value.clamp(0.0, 1.0),
              child: Transform.translate(
                offset:
                    Offset(18 * (1 - finger.value), 32 * (1 - finger.value)),
                child: Transform.scale(
                  scale: _pressScale.transform(press.value),
                  child: child,
                ),
              ),
            ),
            child: const Icon(
              Icons.touch_app,
              size: _finger,
              color: Color(0xFF171717),
              shadows: [
                Shadow(
                  color: Color(0xFFFFFFFF),
                  blurRadius: 2,
                ),
                Shadow(
                  color: Color(0x4D000000),
                  blurRadius: 3,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Story-style segments, one per screen; the current one fills with
/// [progress].
class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.count,
    required this.index,
    required this.progress,
    required this.accent,
    required this.track,
  });

  final int count;
  final int index;
  final Animation<double> progress;
  final Color accent;
  final Color track;

  Widget _fill(double factor) => FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: factor,
        child: ColoredBox(color: accent),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        children: [
          for (var i = 0; i < count; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: Container(
                  height: 4,
                  color: track,
                  child: i == index
                      ? AnimatedBuilder(
                          animation: progress,
                          builder: (_, __) => _fill(progress.value),
                        )
                      : _fill(i < index ? 1 : 0),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
