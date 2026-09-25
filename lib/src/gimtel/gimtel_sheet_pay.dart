part of 'gimtel_sheet.dart';

/// How to pay: the values to copy, the bank app's steps and the live status;
/// or, once the payment expired or stopped, a way to start again.
class _PayStep extends StatelessWidget {
  const _PayStep({
    required this.instructions,
    required this.method,
    required this.methodLabel,
    required this.accent,
    required this.error,
    required this.onClose,
  });

  final GimtelInstructions instructions;
  final ConfigurationListDataInner method;
  final String methodLabel;
  final Color accent;
  final String? error;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = MoosylLocalization.of(context)!;
    final controller = context.watch<GimtelController>();
    final status = controller.status;
    final terminal = status == GimtelStatus.expired ||
        status == GimtelStatus.cancelled ||
        status == GimtelStatus.failed;

    final errorText = error == null
        ? null
        : Text(error!,
            key: const ValueKey('gimtel-error'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: _danger));

    if (terminal) {
      final expired = status == GimtelStatus.expired;
      return Column(
        key: const ValueKey('gimtel-terminal'),
        children: [
          const Icon(Icons.error_outline, size: 40, color: Color(0xFFF59E0B)),
          const SizedBox(height: 12),
          Text(
            expired ? l10n.gimtelExpiredTitle : l10n.gimtelInactiveTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600, color: _ink),
          ),
          const SizedBox(height: 8),
          Text(
            expired
                ? l10n.gimtelExpiredDescription
                : l10n.gimtelInactiveDescription,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: _muted),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: _PrimaryButton(
              key: const ValueKey('gimtel-start-again'),
              label: l10n.gimtelStartAgain,
              accent: accent,
              busy: controller.submitting,
              onPressed: controller.startAgain,
            ),
          ),
          if (errorText != null) ...[const SizedBox(height: 8), errorText],
          const SizedBox(height: 8),
          _LinkButton(
            key: const ValueKey('gimtel-other-method'),
            label: l10n.gimtelOtherMethod,
            onPressed: onClose,
          ),
        ],
      );
    }

    final merchant = instructions.receivingPhone;
    final amount = formatMru(instructions.amount);
    final screens = gimtelWalkthroughs[method.type];
    final captions = switch (method.type) {
      'bankily' => [
          l10n.gimtelBankilyS1(methodLabel),
          l10n.gimtelBankilyS2,
          l10n.gimtelBankilyS3,
          l10n.gimtelBankilyS4,
        ],
      'bci_pay' => [
          l10n.gimtelBciPayS1(methodLabel),
          l10n.gimtelBciPayS2,
          l10n.gimtelBciPayS3,
          l10n.gimtelBciPayS4,
        ],
      _ => const <String>[],
    };

    return Column(
      key: const ValueKey('gimtel-pay-step'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: _line),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _CopyTile(
                      id: 'merchant',
                      valueKey: const ValueKey('gimtel-merchant-number'),
                      label: l10n.gimtelMerchantNumber,
                      value: merchant,
                      copyValue: merchant,
                    ),
                  ),
                  const VerticalDivider(width: 1, thickness: 1, color: _line),
                  Expanded(
                    child: _CopyTile(
                      id: 'amount',
                      valueKey: const ValueKey('gimtel-amount'),
                      label: l10n.gimtelAmount,
                      value: amount,
                      copyValue: _plainAmount(instructions.amount),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (screens != null && captions.length == screens.length)
          Center(
            child: GimtelWalkthrough(
              screens: screens,
              captions: captions,
              values: {
                GimtelFieldValue.bank: 'BIMBANK',
                GimtelFieldValue.phone: merchant,
                GimtelFieldValue.amount: amount,
              },
              accent: accent,
            ),
          )
        else
          _TextSteps(accent: accent, steps: [
            l10n.gimtelGenericStep1(methodLabel),
            l10n.gimtelGenericStep2(merchant, amount),
            l10n.gimtelGenericStep3,
          ]),
        const SizedBox(height: 20),
        _StatusBlock(
          title: l10n.gimtelWaitingTitle,
          hint:
              l10n.gimtelWaitingHint(groupPhonePairs(instructions.payerPhone)),
          accent: accent,
        ),
        if (method.isTestingMode) ...[
          const SizedBox(height: 12),
          _SimulateButton(label: l10n.gimtelSimulate),
        ],
        if (errorText != null) ...[const SizedBox(height: 12), errorText],
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          children: [
            _LinkButton(
              key: const ValueKey('gimtel-change-number'),
              label: l10n.gimtelChangeNumber,
              onPressed: controller.changeNumber,
            ),
            _LinkButton(
              key: const ValueKey('gimtel-other-method'),
              label: l10n.gimtelOtherMethod,
              onPressed: onClose,
            ),
          ],
        ),
      ],
    );
  }
}

/// Numbered text instructions, for banks without a screen walkthrough.
class _TextSteps extends StatelessWidget {
  const _TextSteps({required this.steps, required this.accent});

  /// Translated step templates, placeholders already filled.
  final List<String> steps;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    const base = TextStyle(fontSize: 14, height: 1.43, color: _muted);
    const bold = TextStyle(
        fontSize: 14, height: 1.43, color: _ink, fontWeight: FontWeight.w600);
    return Column(
      key: const ValueKey('gimtel-text-steps'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < steps.length; i++)
          Padding(
            padding: EdgeInsets.only(top: i == 0 ? 0 : 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.only(top: 1),
                  alignment: Alignment.center,
                  decoration:
                      BoxDecoration(color: accent, shape: BoxShape.circle),
                  child: Text('${i + 1}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: gimtelRichSpans(steps[i],
                          base: base,
                          bold: bold,
                          gimtelBadge: (text) =>
                              GimtelBadge(text, style: bold, size: 14)),
                    ),
                    key: ValueKey('gimtel-text-step-$i'),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
