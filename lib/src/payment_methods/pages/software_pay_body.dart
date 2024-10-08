import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:software_pay/src/payment_methods/models/payment_method_model.dart';
import 'package:software_pay/src/payment_methods/pages/available_method_payments.dart';
import 'package:software_pay/src/payment_methods/pages/manuel_payment_page.dart';
import 'package:software_pay/src/payment_methods/pages/pay.dart';
import 'package:software_pay/src/payment_methods/providers/get_payment_methods_provider.dart';

/// A widget that provides a payment interface for the Software Pay system.
///
/// This widget allows users to select a payment method and proceed with the payment.
/// It handles localization and manages the state of the selected payment method.
class SoftwarePayBody extends HookWidget {
  /// Creates an instance of [SoftwarePayBody].
  ///
  /// Requires the [apiKey] and [transactionId] for the payment transaction,
  /// an [organizationLogo] to display, and optional handlers for custom payment methods,
  /// success callbacks, and custom icons.
  const SoftwarePayBody({
    super.key,
    required this.apiKey,
    required this.transactionId,
    required this.organizationLogo,
    this.customHandlers,
    this.onPaymentSuccess,
    this.customIcons,
    this.enabledPayments = const [],
  });

  /// The API key for authenticating the payment transaction.
  final String apiKey;

  /// The transaction ID for the specific payment transaction.
  final String transactionId;

  /// A widget representing the logo of the organization.
  final Widget organizationLogo;

  /// Optional custom handlers for specific payment methods.
  final Map<PaymentMethodTypes, FutureOr<void> Function()>? customHandlers;

  /// Optional callback that is invoked when the payment is successful.
  final FutureOr<void> Function()? onPaymentSuccess;

  /// Optional custom icons for different payment methods.
  final Map<PaymentMethodTypes, String>? customIcons;

  /// manuel pay
  final List<PaymentMethodTypes> enabledPayments;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ChangeNotifierProvider(
        create: (_) => GetPaymentMethodsProvider(
          apiKey,
          customHandlers,
          context,
        ),
        builder: (context, __) {
          final provider = context.watch<GetPaymentMethodsProvider>();

          final selectedModeOfPayment = provider.selected;
          // State to hold the selected payment method.

          // If no payment method is selected, show the available methods page.
          if (selectedModeOfPayment == null) {
            return AvailableMethodPage(
              customHandlers: customHandlers,
              apiKey: apiKey,
              customIcons: customIcons,
              enabledPayments: enabledPayments.where((payment) {
                return PaymentMethodTypes.values.contains(payment);
              }).toList(),
            );
          }

          if (provider.selected!.type.isManual) {
            return ManuelPaymentPage(
              organizationLogo: organizationLogo,
              apiKey: apiKey,
              operationId: transactionId,
              method: selectedModeOfPayment as ManualConfigModel,
            );
          }

          // If a payment method is selected, proceed to the payment page.
          return Pay(
            apiKey: apiKey,
            method: selectedModeOfPayment,
            transactionId: transactionId,
            organizationLogo: organizationLogo,
            onPaymentSuccess: onPaymentSuccess,
          );
        },
      ),
    );
  }
}
