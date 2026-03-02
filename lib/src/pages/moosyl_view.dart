import 'dart:async';
import 'package:flutter/material.dart';
import 'package:moosyl_flutter/l10n/generated/moosyl_localization.dart';
import 'package:moosyl_flutter/src/models/payment_success.dart';
import 'package:moosyl_flutter/src/pages/masrivi_view.dart';
import 'package:moosyl_flutter/src/pages/payment_methods_view.dart';
import 'package:moosyl_flutter/src/providers/get_payment_methods_provider.dart';
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
    this.isFullPage = true,
  });

  /// The API key for authenticating the payment transaction.
  final String publishableApiKey;

  /// The transaction ID for the specific payment transaction.
  final String transactionId;

  /// Optional callback invoked when the payment is successful with [PaymentSuccess].
  /// The caller is responsible for closing the route (e.g. Navigator.pop).
  final FutureOr<void> Function(PaymentSuccess payment)? onPaymentSuccess;

  /// Callback when the back arrow is pressed on the payment method selection page.
  final VoidCallback? onBackPress;

  /// Amount to pay (displayed in summary). Defaults to 0.
  final double amountToPay;

  /// Tax amount (displayed in summary). Defaults to 0.
  final double tax;

  /// When true, payment method selection shows as full page. When false, shows as bottom sheet.
  final bool isFullPage;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => GetPaymentMethodsProvider(
              publishableApiKey: publishableApiKey,
              transactionId: transactionId,
              totalAmount: amountToPay + tax,
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
                totalAmount: amountToPay + tax,
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
                onPaymentDeclined: () {
                  final l10n = MoosylLocalization.of(context);
                  if (l10n != null && context.mounted) {
                    showDialog<void>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: Text(
                          l10n.paymentFailed,
                          style:
                              Theme.of(context).textTheme.titleLarge!.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                        ),
                        content: Text(l10n.paymentDeclined),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: Text(
                                MaterialLocalizations.of(ctx).okButtonLabel),
                          ),
                        ],
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
