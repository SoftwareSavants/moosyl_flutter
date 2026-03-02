import 'package:flutter/material.dart';
import 'package:moosyl_flutter/src/models/payment_success.dart';
import 'package:moosyl_flutter/src/pages/moosyl_view.dart';

/// Convenience class to open the payment flow.
///
/// When [isFullPage] is true, pushes [MoosylView] as a full page.
/// When [isFullPage] is false, shows [MoosylView] as a bottom sheet.
///
/// Returns [PaymentSuccess] when payment completes, or `null` when the user
/// closes without completing payment (e.g. back press).
class MoosylFlutter {
  MoosylFlutter._();

  /// Opens the payment flow. Returns [PaymentSuccess] on success, `null` when closed without payment.
  static Future<PaymentSuccess?> show(
    BuildContext context, {
    required String publishableApiKey,
    required String transactionId,
    double amountToPay = 0.0,
    double tax = 0.0,
    bool isFullPage = true,
  }) async {
    if (isFullPage) {
      return Navigator.push<PaymentSuccess?>(
        context,
        MaterialPageRoute<PaymentSuccess?>(
          builder: (ctx) => MoosylView(
            publishableApiKey: publishableApiKey,
            transactionId: transactionId,
            amountToPay: amountToPay,
            tax: tax,
            isFullPage: true,
            onBackPress: () => Navigator.pop(ctx, null),
            onPaymentSuccess: (payment) async {
              Navigator.pop(ctx, payment);
            },
          ),
        ),
      );
    } else {
      return showModalBottomSheet<PaymentSuccess?>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 1,
          builder: (ctx, scrollController) => Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: MoosylView(
              publishableApiKey: publishableApiKey,
              transactionId: transactionId,
              amountToPay: amountToPay,
              tax: tax,
              isFullPage: false,
              onBackPress: () => Navigator.pop(ctx, null),
              onPaymentSuccess: (payment) async {
                Navigator.pop(ctx, payment);
              },
            ),
          ),
        ),
      );
    }
  }
}
