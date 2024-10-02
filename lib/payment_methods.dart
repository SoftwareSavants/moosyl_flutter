import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:software_pay/container.dart';
import 'package:software_pay/icons.dart';

enum PaymentMethodTypes {
  masrivi,
  bankily,
  sedad,
  bimBank,
  amanty,
  bCIpay;

  AppIcon get icon {
    return switch (this) {
      bankily => AppIcons.bankily,
      masrivi => AppIcons.masrivi,
      sedad => AppIcons.sedad,
      bimBank => AppIcons.bimBank,
      bCIpay => AppIcons.bCIpay,
      amanty => AppIcons.amanty,
    };
  }

  String get displayName {
    switch (this) {
      case PaymentMethodTypes.masrivi:
        return 'Masrivi';
      case PaymentMethodTypes.bankily:
        return 'Bankily';
      case PaymentMethodTypes.sedad:
        return 'Sedad';
      case PaymentMethodTypes.bimBank:
        return 'BIM Bank';
      case PaymentMethodTypes.amanty:
        return 'Amanty';
      case PaymentMethodTypes.bCIpay:
        return 'BCI Pay';
    }
  }

  String get toStr {
    switch (this) {
      case PaymentMethodTypes.masrivi:
        return 'masrivi';
      case PaymentMethodTypes.bankily:
        return 'bankily';
      case PaymentMethodTypes.sedad:
        return 'Sedad';
      case PaymentMethodTypes.bimBank:
        return 'bim_bank';
      case PaymentMethodTypes.amanty:
        return 'amanty';
      case PaymentMethodTypes.bCIpay:
        return 'bci_pay';
    }
  }

  static PaymentMethodTypes fromString(String method) {
    return PaymentMethodTypes.values.firstWhere(
      (value) => value.toStr == method,
      orElse: () =>
          throw UnimplementedError('This payment method is not supported'),
    );
  }
}

class PaymentMethod {
  final String id;
  final String method;

  PaymentMethod({
    required this.id,
    required this.method,
  });
}

class PaymentMethods extends HookWidget {
  final List<PaymentMethod> supportedPayments;
  final VoidCallback? onManualPayment;
  final VoidCallback? onBankily;

  PaymentMethods({
    required this.supportedPayments,
    this.onManualPayment,
    this.onBankily,
  }) : assert(onManualPayment == null || onBankily == null,
            'onManualPayment and onBankily cannot be passed together.');

  @override
  Widget build(BuildContext context) {
    // final selectedModeOfPayment = useState<PaymentMethodTypes?>(null);

    // if (selectedModeOfPayment.value == null) {
    //   return const SizedBox();
    // }

    // if (selectedModeOfPayment.value == PaymentMethodTypes.bankily) {
    //   return Container();
    // }
    final validMethods = supportedPayments.where((method) {
      return PaymentMethodTypes.fromString(method.method) != null;
    }).toList();

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
                  onTap: () {},
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
