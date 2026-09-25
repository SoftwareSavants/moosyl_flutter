part of 'gimtel_sheet.dart';

const Duration _copiedFor = Duration(milliseconds: 1500);

/// A label and a large value; tapping copies [copyValue] and shows a check
/// for 1.5 s.
class _CopyTile extends StatefulWidget {
  const _CopyTile({
    required this.id,
    required this.valueKey,
    required this.label,
    required this.value,
    required this.copyValue,
  });

  /// Suffix of the tile's keys (`gimtel-copy-<id>`, `gimtel-copied-<id>`).
  final String id;
  final Key valueKey;
  final String label;

  /// What is shown, e.g. "100 MRU".
  final String value;

  /// What is copied, e.g. "100".
  final String copyValue;

  @override
  State<_CopyTile> createState() => _CopyTileState();
}

class _CopyTileState extends State<_CopyTile> {
  bool _copied = false;
  Timer? _reset;

  @override
  void dispose() {
    _reset?.cancel();
    super.dispose();
  }

  void _copy() {
    Clipboard.setData(ClipboardData(text: widget.copyValue));
    setState(() => _copied = true);
    _reset?.cancel();
    _reset = Timer(_copiedFor, () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = MoosylLocalization.of(context)!;
    return Semantics(
      button: true,
      label: '${widget.label}: ${widget.value}'
          '${_copied ? '. ${l10n.gimtelCopied}' : ''}',
      hint: l10n.gimtelTapToCopy,
      excludeSemantics: true,
      child: InkWell(
        key: ValueKey('gimtel-copy-${widget.id}'),
        onTap: _copy,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.label.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                  color: _muted,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        widget.value,
                        key: widget.valueKey,
                        maxLines: 1,
                        // Numbers stay left-to-right inside Arabic layouts.
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: _ink,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _copied
                      ? Icon(Icons.check,
                          key: ValueKey('gimtel-copied-${widget.id}'),
                          size: 16,
                          color: const Color(0xFF10B981))
                      : const Icon(Icons.copy_rounded,
                          size: 16, color: Color(0xFF8A8F98)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
