import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:moosyl_flutter/src/models/payment_success.dart';
import 'package:moosyl_flutter/src/pages/moosyl_view.dart';

/// [Moosyl] provides a widget that handles the payment process.
/// It allows you to customize the payment methods, icons, and success callbacks.
class Moosyl extends HookWidget {
  /// The API key required to authenticate the payment process.
  final String publishableApiKey;

  /// The transaction ID associated with the current payment session.
  final String transactionId;

  /// Optional function to build a custom input widget for the payment process.
  /// [open] is the callback to open the payment sheet.
  final Widget Function(VoidCallback open)? inputBuilder;

  /// Optional callback to be triggered upon successful payment with [PaymentSuccess].
  final FutureOr<void> Function(PaymentSuccess payment)? onPaymentSuccess;

  /// When true, shows as full page. When false, shows as bottom sheet.
  final bool isFullPage;

  /// Displays the [MoosylView] modal sheet to start the payment process.
  ///
  /// * [context]: The build context.
  /// * [publishableApiKey]: The API key to authenticate the payment.
  /// * [transactionId]: The transaction ID for the current session.
  /// * [onPaymentSuccess]: Callback for when payment is successful.
  static void show(
    BuildContext context, {
    required String publishableApiKey,
    required String transactionId,
    final FutureOr<void> Function(PaymentSuccess payment)? onPaymentSuccess,
    bool isFullPage = false,
  }) {
    showBarModalBottomSheet(
      context: context,
      builder: (context) => MoosylView(
        publishableApiKey: publishableApiKey,
        transactionId: transactionId,
        onPaymentSuccess: onPaymentSuccess,
        isFullPage: isFullPage,
      ),
    );
  }

  /// Constructor for [Moosyl].
  ///
  /// * [publishableApiKey]: The API key for payment authentication.
  /// * [transactionId]: The transaction ID for the current payment session.
  /// * [inputBuilder]: A function to build a custom input widget.
  /// * [onPaymentSuccess]: Callback when the payment is successful.
  const Moosyl({
    super.key,
    required this.publishableApiKey,
    required this.transactionId,
    this.inputBuilder,
    this.onPaymentSuccess,
    this.isFullPage = false,
  });

  @override
  Widget build(BuildContext context) {
    // If an input builder is provided, use it to build the custom input UI.
    if (inputBuilder != null) {
      return inputBuilder!(
        () {
          showBarModalBottomSheet(
            context: context,
            builder: (context) => MoosylView(
              publishableApiKey: publishableApiKey,
              transactionId: transactionId,
              onPaymentSuccess: onPaymentSuccess,
              isFullPage: isFullPage,
            ),
          );
        },
      );
    }

    // Otherwise, return the default MoosylBody widget.
    return MoosylView(
      publishableApiKey: publishableApiKey,
      transactionId: transactionId,
      onPaymentSuccess: onPaymentSuccess,
      isFullPage: isFullPage,
    );
  }
}
