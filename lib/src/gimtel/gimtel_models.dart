/// Lifecycle of a Gimtel payment as reported by `GET /payment/{id}/status`.
enum GimtelStatus {
  /// The payer has not completed the transfer yet (or the status is unknown).
  pending,

  /// The payer's transfer matched and the payment is complete.
  completed,

  /// The claim window elapsed before the payer completed the transfer.
  expired,

  /// The payment was cancelled.
  cancelled,

  /// The payment failed.
  failed,
}

/// Unknown or missing values keep the payment pending (keep polling).
GimtelStatus gimtelStatusFrom(String? value) => GimtelStatus.values
    .firstWhere((s) => s.name == value, orElse: () => GimtelStatus.pending);

/// What the payer needs to make the transfer.
class GimtelInstructions {
  /// Creates the payer-facing instructions for a Gimtel payment.
  const GimtelInstructions({
    required this.receivingPhone,
    required this.receivingBank,
    required this.amount,
    required this.payerPhone,
    required this.paymentId,
    required this.claimExpiresAt,
  });

  /// The phone number the payer must transfer to.
  final String receivingPhone;

  /// The bank the [receivingPhone] belongs to (e.g. `bankily`, `bci_pay`).
  final String receivingBank;

  /// The exact amount the payer must transfer.
  final num amount;

  /// The phone number the payer is transferring from.
  final String payerPhone;

  /// The identifier of the created payment.
  final String paymentId;

  /// ISO-8601 timestamp after which the payment stops being claimable.
  final String claimExpiresAt;
}
