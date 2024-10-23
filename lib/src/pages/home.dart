import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:moosyl/src/models/payment_method_model.dart';
import 'package:moosyl/src/pages/moosyl_body.dart';

/// [Moosyl] provides a widget that handles the payment process.
/// It allows you to customize the payment methods, icons, and success callbacks.
class Moosyl extends HookWidget {
  /// The API key required to authenticate the payment process.
  final String apiKey;

  /// The transaction ID associated with the current payment session.
  final String transactionId;

  /// The logo of the organization processing the payment.
  final Widget organizationLogo;

  /// Optional function to build a custom input widget for the payment process.
  /// [open] is the callback to open the payment sheet.
  final Widget Function(VoidCallback open)? inputBuilder;

  /// Optional map to override the default behavior of specific payment methods.
  /// The keys are [PaymentMethodTypes] and the values are the custom callback functions.
  final Map<PaymentMethodTypes, FutureOr<void> Function()> customHandlers;

  /// Optional map to provide custom icons for each payment method type.
  /// The keys are [PaymentMethodTypes] and the values are the paths to the custom icons.
  final Map<PaymentMethodTypes, String>? customIcons;

  /// Optional callback to be triggered upon successful payment.
  final FutureOr<void> Function()? onPaymentSuccess;

  /// manual payment

  /// The payment method selected for the payment process.
  final bool isTestingMode;

  /// Displays the [MoosylBody] modal sheet to start the payment process.
  ///
  /// * [context]: The build context.
  /// * [apiKey]: The API key to authenticate the payment.
  /// * [transactionId]: The transaction ID for the current session.
  /// * [organizationLogo]: The logo widget of the organization.
  /// * [customHandlers]: Map for custom handlers for payment methods.
  /// * [customIcons]: Map for custom icons for payment methods.
  /// * [onPaymentSuccess]: Callback for when payment is successful.
  static void show(
    BuildContext context, {
    required String apiKey,
    final Map<PaymentMethodTypes, FutureOr<void> Function()> customHandlers =
        const {},
    required String transactionId,
    required Widget organizationLogo,
    final FutureOr<void> Function()? onPaymentSuccess,
    Map<PaymentMethodTypes, String>? customIcons,
    bool isTestingMode = false,
  }) {
    showBarModalBottomSheet(
      context: context,
      builder: (context) => MoosylBody(
        apiKey: apiKey,
        customHandlers: customHandlers,
        transactionId: transactionId,
        organizationLogo: organizationLogo,
        onPaymentSuccess: onPaymentSuccess,
        customIcons: customIcons,
        isTestingMode: isTestingMode,
      ),
    );
  }

  /// Constructor for [Moosyl].
  ///
  /// * [apiKey]: The API key for payment authentication.
  /// * [transactionId]: The transaction ID for the current payment session.
  /// * [organizationLogo]: The logo of the organization handling the payment.
  /// * [customHandlers]: Optional custom handlers for specific payment methods.
  /// * [customIcons]: Optional custom icons for specific payment methods.
  /// * [inputBuilder]: A function to build a custom input widget.
  /// * [onPaymentSuccess]: Callback when the payment is successful.
  const Moosyl({
    super.key,
    required this.apiKey,
    required this.transactionId,
    required this.organizationLogo,
    this.customHandlers = const {},
    this.customIcons,
    this.inputBuilder,
    this.onPaymentSuccess,
    this.isTestingMode = false,
  });

  @override
  Widget build(BuildContext context) {
    // If an input builder is provided, use it to build the custom input UI.
    if (inputBuilder != null) {
      return inputBuilder!(
        () {
          showBarModalBottomSheet(
            context: context,
            builder: (context) => MoosylBody(
              apiKey: apiKey,
              customHandlers: customHandlers,
              transactionId: transactionId,
              organizationLogo: organizationLogo,
              onPaymentSuccess: onPaymentSuccess,
              customIcons: customIcons,
              isTestingMode: isTestingMode,
            ),
          );
        },
      );
    }

    // Otherwise, return the default MoosylBody widget.
    return MoosylBody(
      apiKey: apiKey,
      customHandlers: customHandlers,
      transactionId: transactionId,
      organizationLogo: organizationLogo,
      onPaymentSuccess: onPaymentSuccess,
      customIcons: customIcons,
      isTestingMode: isTestingMode,
    );
  }
}
