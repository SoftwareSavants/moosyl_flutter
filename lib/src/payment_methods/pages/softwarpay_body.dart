import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:software_pay/src/l10n/localization_helper.dart';
import 'package:software_pay/src/payment_methods/models/payment_method_model.dart';
import 'package:software_pay/src/payment_methods/pages/available_methode_payments.dart';
import 'package:software_pay/src/payment_methods/pages/pay.dart';

class SoftwarePayBody extends HookWidget {
  final String apiKey, operationId;
  final Widget organizationLogo;
  final Map<PaymentMethodTypes, VoidCallback>? customHandlers;
  final VoidCallback? onPaymentSuccess;
  final Map<PaymentMethodTypes, String>? customIcons;

  const SoftwarePayBody({
    super.key,
    required this.apiKey,
    required this.operationId,
    required this.organizationLogo,
    this.customHandlers,
    this.onPaymentSuccess,
    this.customIcons,
  });

  @override
  Widget build(BuildContext context) {
    useMemoized(
      () {
        GetIt.I.registerSingleton(LocalizationsHelper(context));
      },
      [],
    );

    final selectedModeOfPayment = useState<PaymentMethod?>(null);

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

    return Pay(
      apiKey: apiKey,
      method: selectedModeOfPayment.value!,
      operationId: operationId,
      organizationLogo: organizationLogo,
      onPaymentSuccess: onPaymentSuccess,
    );
  }
}
