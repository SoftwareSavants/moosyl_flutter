part of 'gimtel_sheet.dart';

/// Asks which number the payer will transfer from.
class _PhoneStep extends StatefulWidget {
  const _PhoneStep({
    required this.methodLabel,
    required this.accent,
    required this.error,
    required this.onClose,
  });

  final String methodLabel;
  final Color accent;

  /// Already translated; `null` when there is nothing to show.
  final String? error;
  final VoidCallback onClose;

  @override
  State<_PhoneStep> createState() => _PhoneStepState();
}

class _PhoneStepState extends State<_PhoneStep> {
  late final TextEditingController _input =
      TextEditingController(text: context.read<GimtelController>().phone)
        ..addListener(() => setState(() {}));

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _submit(GimtelController controller) {
    final phone = _input.text.trim();
    if (controller.submitting || phone.isEmpty) return;
    controller.submitPhone(phone);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = MoosylLocalization.of(context)!;
    final controller = context.watch<GimtelController>();
    final submitting = controller.submitting;
    final error = widget.error;
    final label = l10n.gimtelPhoneLabel(widget.methodLabel);

    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: color, width: width),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w500, color: _ink)),
        const SizedBox(height: 8),
        TextField(
          key: const ValueKey('gimtel-phone-input'),
          controller: _input,
          enabled: !submitting,
          autofocus: true,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.telephoneNumber],
          // Phone numbers read left-to-right even in Arabic.
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.left,
          onSubmitted: (_) => _submit(controller),
          style: const TextStyle(
            fontSize: 18,
            letterSpacing: 1,
            color: _ink,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
          decoration: InputDecoration(
            hintText: '3X XX XX XX',
            hintTextDirection: TextDirection.ltr,
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            enabledBorder:
                border(error != null ? _danger : const Color(0xFFD1D5DB)),
            disabledBorder: border(_line),
            focusedBorder: border(error != null ? _danger : widget.accent, 1.5),
          ),
        ),
        const SizedBox(height: 8),
        Text(l10n.gimtelPhoneHint(widget.methodLabel),
            style: const TextStyle(fontSize: 12, color: _muted)),
        if (error != null) ...[
          const SizedBox(height: 8),
          Semantics(
            liveRegion: true,
            child: Text(error,
                key: const ValueKey('gimtel-phone-error'),
                style: const TextStyle(fontSize: 13, color: _danger)),
          ),
        ],
        const SizedBox(height: 16),
        _PrimaryButton(
          key: const ValueKey('gimtel-continue'),
          label: l10n.gimtelContinue,
          accent: widget.accent,
          busy: submitting,
          onPressed:
              _input.text.trim().isEmpty ? null : () => _submit(controller),
        ),
        const SizedBox(height: 8),
        Center(
          child: _LinkButton(
            key: const ValueKey('gimtel-other-method'),
            label: l10n.gimtelOtherMethod,
            onPressed: widget.onClose,
          ),
        ),
      ],
    );
  }
}
