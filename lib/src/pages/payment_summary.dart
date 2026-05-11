part of 'payment_methods_view.dart';

class _PaymentSummary extends StatelessWidget {
  const _PaymentSummary({
    required this.items,
    required this.totalText,
    required this.localization,
  });

  final List<MoosylPaymentSummaryItem> items;
  final String totalText;
  final MoosylLocalization localization;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final labelStyle = textTheme.bodyLarge?.copyWith(
      color: Colors.grey.shade700,
    );
    final valueStyle = textTheme.bodyLarge?.copyWith(
      color: const Color(0xFF111111),
    );
    final totalStyle = textTheme.bodyLarge?.copyWith(
      color: const Color(0xFF111111),
      fontWeight: FontWeight.w600,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _PaymentSummaryRow(
                label: _localizedSummaryLabel(item.label, localization),
                value: '${_formatAmount(item.amount)} MRU',
                labelStyle: labelStyle,
                valueStyle: valueStyle,
              ),
            ),
          ),
          if (items.isNotEmpty)
            Divider(
              height: 18,
              thickness: 2,
              color: Colors.grey.shade300,
            ),
          _PaymentSummaryRow(
            label: localization.totalAmount,
            value: totalText,
            labelStyle: totalStyle,
            valueStyle: totalStyle,
          ),
        ],
      ),
    );
  }
}

class _PaymentSummaryRow extends StatelessWidget {
  const _PaymentSummaryRow({
    required this.label,
    required this.value,
    required this.labelStyle,
    required this.valueStyle,
  });

  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: labelStyle),
        ),
        const SizedBox(width: 8),
        Text(value, style: valueStyle),
      ],
    );
  }
}

double _calculateSummaryTotal(List<MoosylPaymentSummaryItem> items) {
  return items.fold<double>(
    0,
    (total, item) => total + item.amount,
  );
}

String _formatAmount(num value) {
  return NumberFormat.decimalPattern('fr_FR').format(value.round());
}

String _localizedSummaryLabel(
  String label,
  MoosylLocalization localization,
) {
  switch (label) {
    case 'amountToPay':
      return localization.amountToPay;
    case 'tax':
      return localization.tax;
    case 'total':
    case 'totalAmount':
      return localization.totalAmount;
    default:
      return label;
  }
}
