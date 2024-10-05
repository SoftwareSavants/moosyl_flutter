import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:software_pay/src/payment_methods/models/payment_method_model.dart';
import 'package:software_pay/src/payment_methods/pages/softwarpay_body.dart';

class SoftwarePay extends HookWidget {
  final String apiKey;
  final String operationId;
  final Widget organizationLogo;

  final Widget Function(VoidCallback open)? inputBuilder;
  final Map<PaymentMethodTypes, VoidCallback>? customHandlers;
  final Map<PaymentMethodTypes, String>? customIcons;

  final VoidCallback? onPaymentSuccess;

  static void show(
    BuildContext context, {
    required String apiKey,
    Map<PaymentMethodTypes, VoidCallback>? customHandlers,
    required String operationId,
    required Widget organizationLogo,
    VoidCallback? onPaymentSuccess,
    Map<PaymentMethodTypes, String>? customIcons,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SoftwarePayBody(
        apiKey: apiKey,
        customHandlers: customHandlers,
        operationId: operationId,
        organizationLogo: organizationLogo,
        onPaymentSuccess: onPaymentSuccess,
        customIcons: customIcons,
      ),
    );
  }

  const SoftwarePay({
    super.key,
    required this.apiKey,
    required this.operationId,
    required this.organizationLogo,
    this.customHandlers,
    this.customIcons,
    this.inputBuilder,
    this.onPaymentSuccess,
  });

  @override
  Widget build(BuildContext context) {
    if (inputBuilder != null) {
      return inputBuilder!(
        () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SoftwarePayBody(
                apiKey: apiKey,
                customHandlers: customHandlers,
                operationId: operationId,
                organizationLogo: organizationLogo,
                onPaymentSuccess: onPaymentSuccess,
                customIcons: customIcons,
              ),
            ),
          );
        },
      );
    }

    return SoftwarePayBody(
      apiKey: apiKey,
      customHandlers: customHandlers,
      operationId: operationId,
      organizationLogo: organizationLogo,
      onPaymentSuccess: onPaymentSuccess,
      customIcons: customIcons,
    );
  }
}
