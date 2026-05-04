import 'package:flutter/material.dart';
import 'package:moosyl_flutter/src/models/payment_summary_item.dart';
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
  ///
  /// When [items] is supplied, the summary total is validated against the
  /// payment request amount.
  static Future<bool?> show(
    BuildContext context, {
    required String publishableApiKey,
    required String transactionId,
    double amountToPay = 0.0,
    double tax = 0.0,
    List<MoosylPaymentSummaryItem>? items,
    bool isFullPage = true,
    bool isMasriviInBottomSheet = false,
    String? masriviPhoneNumber,
    double masriviBottomSheetHeight = 0.88,
  }) async {
    if (isFullPage) {
      return Navigator.push<bool?>(
        context,
        MaterialPageRoute<bool?>(
          builder: (ctx) => MoosylView(
            publishableApiKey: publishableApiKey,
            transactionId: transactionId,
            amountToPay: amountToPay,
            tax: tax,
            items: items,
            isFullPage: true,
            isMasriviInBottomSheet: isMasriviInBottomSheet,
            masriviPhoneNumber: masriviPhoneNumber,
            masriviBottomSheetHeight: masriviBottomSheetHeight,
            onBackPress: () => Navigator.pop(ctx, null),
            onPaymentSuccess: (payment) async {
              Navigator.pop(ctx, payment);
            },
          ),
        ),
      );
    } else {
      return showModalBottomSheet<bool?>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 1,
          builder: (ctx, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            clipBehavior: Clip.antiAlias,
            child: MoosylView(
              publishableApiKey: publishableApiKey,
              transactionId: transactionId,
              amountToPay: amountToPay,
              tax: tax,
              items: items,
              isFullPage: false,
              isMasriviInBottomSheet: isMasriviInBottomSheet,
              masriviPhoneNumber: masriviPhoneNumber,
              masriviBottomSheetHeight: masriviBottomSheetHeight,
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
