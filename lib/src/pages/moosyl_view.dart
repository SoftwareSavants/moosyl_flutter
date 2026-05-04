import 'dart:async';
import 'package:flutter/material.dart';
import 'package:moosyl_flutter/l10n/generated/moosyl_localization.dart';
import 'package:moosyl_flutter/src/models/payment_summary_item.dart';
import 'package:moosyl_flutter/src/pages/masrivi_view.dart';
import 'package:moosyl_flutter/src/pages/payment_methods_view.dart';
import 'package:moosyl_flutter/src/providers/get_payment_methods_provider.dart';
import 'package:moosyl_flutter/src/widgets/buttons.dart';
import 'package:provider/provider.dart';

/// A widget that provides a payment interface for the Software Pay system.
///
/// This widget allows users to select a payment method and proceed with the payment.
/// It handles localization and manages the state of the selected payment method.
class MoosylView extends StatelessWidget {
  /// Creates an instance of [MoosylView].

  /// Requires the [publishableApiKey] and [transactionId] for the payment transaction,
  /// and optional handlers for success callbacks.
  const MoosylView({
    super.key,
    required this.publishableApiKey,
    required this.transactionId,
    this.onPaymentSuccess,
    this.onBackPress,
    this.amountToPay = 0.0,
    this.tax = 0.0,
    this.items,
    this.isFullPage = true,
    this.isMasriviInBottomSheet = true,
    this.masriviPhoneNumber,
    this.masriviBottomSheetHeight = 0.88,
  });

  /// The API key for authenticating the payment transaction.
  final String publishableApiKey;

  /// The transaction ID for the specific payment transaction.
  final String transactionId;

  /// Optional callback invoked when the payment is successful with [PaymentSuccess].
  /// The caller is responsible for closing the route (e.g. Navigator.pop).
  final FutureOr<void> Function(bool isSuccess)? onPaymentSuccess;

  /// Callback when the back arrow is pressed on the payment method selection page.
  final VoidCallback? onBackPress;

  /// Amount to pay (displayed in summary). Defaults to 0.
  final double amountToPay;

  /// Tax amount (displayed in summary). Defaults to 0.
  final double tax;

  /// Summary rows displayed under the payment methods.
  ///
  /// When supplied, the sum of all item amounts is validated against the
  /// payment request amount before continuing.
  final List<MoosylPaymentSummaryItem>? items;

  /// When true, payment method selection shows as full page. When false, shows as bottom sheet.
  final bool isFullPage;

  /// When true, Masrivi opens inside bottom-sheet content.
  final bool isMasriviInBottomSheet;

  /// Optional phone number to prefill when the selected method opens Masrivi.
  final String? masriviPhoneNumber;

  /// Height factor used when Masrivi is rendered as bottom-sheet content.
  final double masriviBottomSheetHeight;

  @override
  Widget build(BuildContext context) {
    final totalAmount = _calculateTotalAmount(
      items: items,
      amountToPay: amountToPay,
      tax: tax,
    );

    return Material(
      color: Colors.white,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => GetPaymentMethodsProvider(
              publishableApiKey: publishableApiKey,
              transactionId: transactionId,
              totalAmount: totalAmount,
            ),
          ),
        ],
        child: Builder(
          builder: (context) {
            final provider = context.watch<GetPaymentMethodsProvider>();

            final selectedModeOfPayment = provider.selected;
            // State to hold the selected payment method.

            // If no payment method is selected, show the available methods page.
            if (selectedModeOfPayment == null) {
              return SelectPaymentMethodPage(
                onBackPress: onBackPress,
                amountToPay: amountToPay,
                tax: tax,
                items: items,
                totalAmount: totalAmount,
                transactionId: transactionId,
                onPaymentSuccess: onPaymentSuccess,
                isFullPage: isFullPage,
              );
            } else {
              return MasriviView(
                publishableApiKey: publishableApiKey,
                transactionId: transactionId,
                configurationId: selectedModeOfPayment.id,
                onPaymentSuccess: onPaymentSuccess,
                onBackPress: () => context
                    .read<GetPaymentMethodsProvider>()
                    .setPaymentMethod(null),
                presentation: isMasriviInBottomSheet
                    ? MasriviWebViewPresentation.bottomSheet
                    : MasriviWebViewPresentation.fullPage,
                bottomSheetHeight: masriviBottomSheetHeight,
                phoneNumber:
                    masriviPhoneNumber ?? provider.paymentRequest?.phoneNumber,
                onPaymentDeclined: () {
                  final l10n = MoosylLocalization.of(context);
                  if (l10n != null && context.mounted) {
                    showDialog<void>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: Text(l10n.paymentFailed),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(l10n.paymentDeclined),
                            Align(
                              alignment: Alignment.centerRight,
                              child: SizedBox(
                                  height: 44,
                                  child: AppButton(
                                    style: AppButtonStyle.outline,
                                    borderRadius: BorderRadius.circular(16),
                                    labelText: l10n.tryAgain,
                                    onPressed: () => Navigator.of(ctx).pop(),
                                  )),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              );
            }
          },
        ),
      ),
    );
  }
}

double _calculateTotalAmount({
  required List<MoosylPaymentSummaryItem>? items,
  required double amountToPay,
  required double tax,
}) {
  if (items != null) {
    return items.fold<double>(
      0,
      (total, item) => total + item.amount,
    );
  }

  return amountToPay + tax;
}
