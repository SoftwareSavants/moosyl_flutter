/// A summary row shown in the Moosyl payment flow.
class MoosylPaymentSummaryItem {
  /// Creates a payment summary item.
  const MoosylPaymentSummaryItem({
    required this.label,
    required this.amount,
  });

  /// Label shown for this row.
  ///
  /// Known keys are localized: `amountToPay`, `tax`, `total`, and
  /// `totalAmount`. Other values are shown as provided.
  final String label;

  /// Amount for this row in MRU.
  final double amount;
}
