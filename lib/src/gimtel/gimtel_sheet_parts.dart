part of 'gimtel_sheet.dart';

/// "Waiting for your payment" with a pulsing dot, shown while polling.
class _StatusBlock extends StatefulWidget {
  const _StatusBlock({
    required this.title,
    required this.hint,
    required this.accent,
  });

  final String title;

  /// Translated `waitingHint` template, placeholders already filled.
  final String hint;
  final Color accent;

  @override
  State<_StatusBlock> createState() => _StatusBlockState();
}

class _StatusBlockState extends State<_StatusBlock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (still) {
      _pulse.stop();
      _pulse.value = 0;
    } else if (!_pulse.isAnimating) {
      _pulse.repeat();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent;
    final ping = CurvedAnimation(parent: _pulse, curve: Curves.easeOutCubic);
    const hint = TextStyle(fontSize: 12, color: _muted);
    Widget dot() => Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
        );
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: accent.withAlpha(0x0D),
          border: Border.all(color: accent.withAlpha(0x40)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 10,
              height: 10,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  FadeTransition(
                    opacity: ping.drive(Tween(begin: 0.6, end: 0)),
                    child: ScaleTransition(
                      scale: ping.drive(Tween(begin: 1, end: 2.4)),
                      child: dot(),
                    ),
                  ),
                  dot(),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _ink)),
                  const SizedBox(height: 2),
                  Text.rich(
                    TextSpan(
                      children: gimtelRichSpans(
                        widget.hint,
                        base: hint,
                        bold: hint.copyWith(
                            color: _ink, fontWeight: FontWeight.w600),
                        gimtelBadge: (text) => GimtelBadge(text, size: 12),
                      ),
                    ),
                    key: const ValueKey('gimtel-waiting-hint'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sandbox only: pretends the payer sent the transfer.
class _SimulateButton extends StatefulWidget {
  const _SimulateButton({required this.label});

  final String label;

  @override
  State<_SimulateButton> createState() => _SimulateButtonState();
}

class _SimulateButtonState extends State<_SimulateButton> {
  bool _busy = false;

  Future<void> _simulate() async {
    setState(() => _busy = true);
    try {
      await context.read<GimtelController>().simulate();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: TextButton(
        key: const ValueKey('gimtel-simulate'),
        onPressed: _busy ? null : _simulate,
        style: TextButton.styleFrom(
          backgroundColor: const Color(0xFFF3F4F6),
          foregroundColor: _ink,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        child: Text(widget.label),
      ),
    );
  }
}

/// The accent-filled main action, with a spinner while [busy].
class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    super.key,
    required this.label,
    required this.accent,
    required this.busy,
    required this.onPressed,
  });

  final String label;
  final Color accent;
  final bool busy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: FilledButton(
        onPressed: busy ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: accent.withAlpha(0x80),
          disabledForegroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (busy) ...[
              const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }
}

/// A quiet text action ("Change number", "Use another method").
class _LinkButton extends StatelessWidget {
  const _LinkButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: _muted,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      child: Text(label),
    );
  }
}
