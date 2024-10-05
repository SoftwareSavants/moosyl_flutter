import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:software_pay/src/l10n/localization_helper.dart';
import 'package:software_pay/src/payment_methods/models/payment_method_model.dart';
import 'package:software_pay/src/payment_methods/pages/available_method_payments.dart';
import 'package:software_pay/src/payment_methods/pages/pay.dart';

/// A widget that provides a payment interface for the Software Pay system.
///
/// This widget allows users to select a payment method and proceed with the payment.
/// It handles localization and manages the state of the selected payment method.
class SoftwarePayBody extends HookWidget {
  /// Creates an instance of [SoftwarePayBody].
  ///
  /// Requires the [apiKey] and [operationId] for the payment transaction,
  /// an [organizationLogo] to display, and optional handlers for custom payment methods,
  /// success callbacks, and custom icons.
  const SoftwarePayBody({
    super.key,
    required this.apiKey,
    required this.operationId,
    required this.organizationLogo,
    this.customHandlers,
    this.onPaymentSuccess,
    this.customIcons,
  });

  /// The API key for authenticating the payment transaction.
  final String apiKey;

  /// The operation ID for the specific payment transaction.
  final String operationId;

  /// A widget representing the logo of the organization.
  final Widget organizationLogo;

  /// Optional custom handlers for specific payment methods.
  final Map<PaymentMethodTypes, VoidCallback>? customHandlers;

  /// Optional callback that is invoked when the payment is successful.
  final VoidCallback? onPaymentSuccess;

  /// Optional custom icons for different payment methods.
  final Map<PaymentMethodTypes, String>? customIcons;

  @override
  Widget build(BuildContext context) {
    // Initialize localization.
    useMemoized(
      () {
        LocalizationsHelper(context: context);
      },
      [],
    );

    // State to hold the selected payment method.
    final selectedModeOfPayment = useState<PaymentMethod?>(null);

    // If no payment method is selected, show the available methods page.
    if (selectedModeOfPayment.value == null) {
      return AvailableMethodPage(
        customHandlers: customHandlers,
        apiKey: apiKey,
        onSelected: (modeOfPayment) {
          selectedModeOfPayment.value = modeOfPayment;
        },
        customIcons: customIcons,
      );
    }

    // If a payment method is selected, proceed to the payment page.
    return Pay(
      apiKey: apiKey,
      method: selectedModeOfPayment.value!,
      operationId: operationId,
      organizationLogo: organizationLogo,
      onPaymentSuccess: onPaymentSuccess,
    );
  }
}
