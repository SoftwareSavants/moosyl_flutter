import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:software_pay/software_payment/pages/software_pay_page.dart';
import 'package:software_pay/widgets/container.dart';
import 'package:software_pay/payment_methods/models/payment_methode_model.dart';
import 'package:software_pay/payment_methods/models/payment_methode_types.dart';

class PaymentMethods extends HookWidget {
  final List<PaymentMethod> supportedPayments;
  final VoidCallback? onManualPayment;
  final VoidCallback? onBankily;
  final Widget Function(PaymentMethodTypes selectedPayment)?
      selectedPaymentBuilder;

  PaymentMethods(
      {required this.supportedPayments,
      this.onManualPayment,
      this.onBankily,
      this.selectedPaymentBuilder})
      : assert(onManualPayment == null || onBankily == null,
            'onManualPayment and onBankily cannot be passed together.');

  @override
  Widget build(BuildContext context) {
    final selectedModeOfPayment = useState<PaymentMethodTypes?>(null);

    if (selectedModeOfPayment.value != null) {
      if (selectedPaymentBuilder != null) {
        return selectedPaymentBuilder!(selectedModeOfPayment.value!);
      }
      return const SoftPayPage();
    }

    final validMethods = supportedPayments.where((method) {
      return PaymentMethodTypes.fromString(method.method) != null;
    }).toList();

    return AvailableMethodPage(
      validMethods: validMethods,
      onSelected: (modeOfPayment) {
        selectedModeOfPayment.value = modeOfPayment;
      },
    );
  }
}

class AvailableMethodPage extends StatelessWidget {
  final void Function(PaymentMethodTypes) onSelected;
  final List<PaymentMethod> validMethods;
  const AvailableMethodPage(
      {super.key, required this.validMethods, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'payment method',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: validMethods.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.8,
              ),
              itemBuilder: (context, index) {
                final method = validMethods[index];
                final methodType = PaymentMethodTypes.fromString(method.method);

                return InkWell(
                  onTap: () => onSelected(methodType),
                  child: card(context, methodType!),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget card(BuildContext context, PaymentMethodTypes mode) {
    return AppContainer(
      border: Border.all(),
      padding: const EdgeInsetsDirectional.all(24),
      child: mode.icon,
    );
  }
}
