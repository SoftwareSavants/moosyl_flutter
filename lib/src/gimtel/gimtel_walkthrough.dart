import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';

import 'gimtel_rich_text.dart';
import 'gimtel_walkthrough_data.dart';

part 'gimtel_walkthrough_frame.dart';
part 'gimtel_walkthrough_parts.dart';

const String _package = 'moosyl_flutter';
const Duration _captionSwitch = Duration(milliseconds: 260);
const Duration _rippleLoop = Duration(milliseconds: 1400);
const int _firstFieldMs = 300;

/// A story-style replay of the payer's own bank app: each screen shows where
/// to tap and overlays the payer's values on the fields to fill. Auto-advances
/// and loops; tap the right half for next, the left half for previous; press
/// and hold to pause. With animations disabled it is static and manual.
class GimtelWalkthrough extends StatefulWidget {
  /// Creates a walkthrough of [screens], captioned by [captions] (one
  /// template per screen, see `gimtelRichSpans`), showing [values] in the
  /// highlighted fields, drawn in [accent].
  const GimtelWalkthrough({
    super.key,
    required this.screens,
    required this.captions,
    required this.values,
    required this.accent,
  });

  /// The bank app's screens, e.g. `gimtelWalkthroughs['bankily']`.
  final List<GimtelScreen> screens;

  /// One translated caption template per screen (`<b>`, `<n>`, `<g>` tags).
  final List<String> captions;

  /// What the payer types into the highlighted fields.
  final Map<GimtelFieldValue, String> values;

  /// Color of the tap marker, field outlines, progress and step number.
  final Color accent;

  @override
  State<GimtelWalkthrough> createState() => _GimtelWalkthroughState();
}

class _GimtelWalkthroughState extends State<GimtelWalkthrough>
    with TickerProviderStateMixin {
  /// 0 → 1 over the current screen; drives every per-screen animation.
  late final AnimationController _play = AnimationController(vsync: this)
    ..addStatusListener(_onPlayStatus)
    ..addListener(_syncRipple);
  late final AnimationController _ripple =
      AnimationController(vsync: this, duration: _rippleLoop);

  /// Bumped by every navigation; the screen shown is `_step % count`.
  int _step = 0;
  bool _held = false;
  bool _still = false;
  bool _started = false;
  bool _precached = false;

  int get _count => widget.screens.length;
  int get _index => _count == 0 ? 0 : _step % _count;
  GimtelScreen get _screen => widget.screens[_index];
  int get _tapDelayMs => _screen.fields.length * gimtelFieldStaggerMs + 500;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_precached) {
      _precached = true;
      for (final screen in widget.screens) {
        precacheImage(AssetImage(screen.asset, package: _package), context,
            onError: (_, __) {});
      }
    }
    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (!_started || still != _still) {
      _started = true;
      _still = still;
      _restart();
    }
  }

  @override
  void didUpdateWidget(GimtelWalkthrough oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A rebuilt but equal list (same const screens) must not restart.
    if (!listEquals(oldWidget.screens, widget.screens)) {
      _step = 0;
      _restart();
    }
  }

  @override
  void dispose() {
    _play.dispose();
    _ripple.dispose();
    super.dispose();
  }

  /// Plays the current screen from its start (or shows its final frame).
  void _restart() {
    _ripple
      ..stop()
      ..value = 0;
    if (_count == 0) return _play.stop();
    _play.duration = Duration(milliseconds: gimtelScreenDurationMs(_screen));
    if (_still) {
      _play.value = 1;
    } else {
      _play.value = 0;
      if (!_held) _play.forward();
    }
  }

  void _onPlayStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_still) _go(1);
  }

  /// Starts the ripple loop once the finger has tapped.
  void _syncRipple() {
    if (_still || _held || _ripple.isAnimating) return;
    final duration = _play.duration;
    if (duration == null) return;
    if (_play.value * duration.inMilliseconds >= _tapDelayMs) _ripple.repeat();
  }

  void _go(int delta) {
    if (_count == 0) return;
    setState(() => _step += delta);
    _restart();
  }

  void _pause() {
    _held = true;
    _play.stop();
    _ripple.stop();
  }

  void _resume() {
    if (!_held) return;
    _held = false;
    if (_still) return;
    _play.forward();
    _syncRipple();
  }

  /// [_play] eased over `[startMs, startMs + lengthMs]` of the screen.
  Animation<double> _during(int startMs, int lengthMs) {
    final d = gimtelScreenDurationMs(_screen);
    return _play.drive(CurveTween(
      curve: Interval(
        (startMs / d).clamp(0.0, 1.0),
        ((startMs + lengthMs) / d).clamp(0.0, 1.0),
        curve: Curves.easeOutQuart,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_count == 0) return const SizedBox.shrink();
    final screen = _screen;
    final colors = Theme.of(context).colorScheme;
    final phoneWidth = MediaQuery.sizeOf(context).width >= 360 ? 192.0 : 168.0;
    final screenIn = _during(0, 320);
    final tap = _tapDelayMs;

    final display = LayoutBuilder(builder: (context, constraints) {
      final area = constraints.biggest;
      return Stack(
        children: [
          Positioned.fill(
            child: FadeTransition(
              opacity: screenIn,
              child: ScaleTransition(
                scale: screenIn.drive(Tween(begin: 1.025, end: 1)),
                child: Image.asset(
                  screen.asset,
                  package: _package,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  excludeFromSemantics: true,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),
          for (var i = 0; i < screen.fields.length; i++)
            _FieldChip(
              field: screen.fields[i],
              value: widget.values[screen.fields[i].value] ?? '',
              accent: widget.accent,
              appear: _during(_firstFieldMs + i * gimtelFieldStaggerMs, 520),
              area: area,
            ),
          Positioned.fill(
            child: _TapMarker(
              at: Offset(area.width * screen.tapX / 100,
                  area.height * screen.tapY / 100),
              accent: widget.accent,
              dot: _during(tap - 200, 260),
              finger: _during(tap - 450, 400),
              press: _during(tap - 65, 300),
              ripple: _ripple.drive(CurveTween(curve: Curves.easeOutQuart)),
              still: _still,
            ),
          ),
        ],
      );
    });

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: colors.onSurface.withAlpha(9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            value: '${_index + 1} / $_count',
            increasedValue: '${(_index + 1) % _count + 1} / $_count',
            decreasedValue: '${(_index - 1) % _count + 1} / $_count',
            onIncrease: () => _go(1),
            onDecrease: () => _go(-1),
            child: GestureDetector(
              key: const ValueKey('gimtel-walkthrough-phone'),
              behavior: HitTestBehavior.opaque,
              onTapUp: (d) => _go(d.localPosition.dx > phoneWidth / 2 ? 1 : -1),
              onLongPressStart: (_) => _pause(),
              onLongPressEnd: (_) => _resume(),
              onLongPressCancel: _resume,
              child: _PhoneFrame(width: phoneWidth, child: display),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: phoneWidth,
            child: _ProgressBar(
              count: _count,
              index: _index,
              progress: _play,
              accent: widget.accent,
              track: colors.onSurface.withAlpha(38),
            ),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 40, maxWidth: 336),
            child: Semantics(
              liveRegion: true,
              child: AnimatedSwitcher(
                duration: _still ? Duration.zero : _captionSwitch,
                child: _Caption(
                  key: ValueKey(_step),
                  number: _index + 1,
                  template: _index < widget.captions.length
                      ? widget.captions[_index]
                      : '',
                  accent: widget.accent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
