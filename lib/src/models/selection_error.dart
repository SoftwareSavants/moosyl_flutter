import 'package:moosyl_flutter/l10n/generated/moosyl_localization.dart';

/// Enum representing validation errors when selecting a payment method.
enum SelectionErrorType {
  /// The payment request has already been fully paid.
  paymentRequestFullyPaid,

  /// The amount to pay does not match the payment request amount.
  amountToPayShouldMatchPaymentRequest;

  /// Creates a [SelectionErrorType] from its string representation.
  static SelectionErrorType fromStr(String value) {
    return switch (value) {
      'paymentRequestFullyPaid' => SelectionErrorType.paymentRequestFullyPaid,
      'amountToPayShouldMatchPaymentRequest' =>
        SelectionErrorType.amountToPayShouldMatchPaymentRequest,
      _ => throw Exception('Invalid selection error type: $value'),
    };
  }
}

extension SelectionErrorTypeExtension on SelectionErrorType {
  String message(MoosylLocalization l10n) {
    switch (this) {
      case SelectionErrorType.paymentRequestFullyPaid:
        return l10n.paymentRequestFullyPaid;
      case SelectionErrorType.amountToPayShouldMatchPaymentRequest:
        return l10n.amountToPayShouldMatchPaymentRequest;
    }
  }
}
