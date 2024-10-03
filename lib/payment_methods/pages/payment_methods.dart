import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:software_pay/l10n/localization_helper.dart';
import 'package:software_pay/payment_methods/pages/pay.dart';
import 'package:software_pay/payment_methods/providers/get_payment_methods_provider.dart';

import 'package:software_pay/widgets/container.dart';
import 'package:software_pay/payment_methods/models/payment_method_model.dart';
import 'package:software_pay/widgets/error_widget.dart';
import 'package:software_pay/widgets/icons.dart';

class SoftwarePay extends HookWidget {
  final String apiKey;
  final String operationId;
  final Widget organizationLogo;

  final Widget Function(VoidCallback open)? inputBuilder;
  final Map<PaymentMethodTypes, VoidCallback>? customHandlers;
  final Map<PaymentMethodTypes, String>? customIcons;

  final VoidCallback? onPaymentSuccess;

  static void show(
    BuildContext context,
    String apiKey,
    Map<PaymentMethodTypes, VoidCallback>? customHandlers,
    String operationId,
    Widget organizationLogo,
    VoidCallback? onPaymentSuccess,
    Map<PaymentMethodTypes, String>? customIcons,
  ) {
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

class AvailableMethodPage extends StatelessWidget {
  final void Function(PaymentMethod) onSelected;
  final String apiKey;
  final Map<PaymentMethodTypes, void Function()>? customHandlers;
  final Map<PaymentMethodTypes, String>? customIcons;

  const AvailableMethodPage({
    super.key,
    required this.onSelected,
    required this.apiKey,
    this.customHandlers,
    this.customIcons,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GetPaymentMethodsProvider(
        apiKey,
        customHandlers,
        onSelected,
      ),
      builder: (context, __) {
        final provider = context.watch<GetPaymentMethodsProvider>();
        final localizationsHelper = GetIt.I.get<LocalizationsHelper>();

        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.error != null) {
          return AppErrorWidget(
            message: provider.error,
            onRetry: provider.getMethods,
          );
        }

        final validMethods = provider.validMethods;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  localizationsHelper.msgs.paymentMethod,
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

                    return InkWell(
                      onTap: () => provider.onTap(method, context),
                      child: card(context, method),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget card(BuildContext context, PaymentMethodTypes mode) {
    final withIcon = customIcons?[mode] == null;

    return AppContainer(
      border: Border.all(),
      padding: const EdgeInsetsDirectional.all(24),
      child: withIcon ? AppIcon(path: customIcons?[mode]) : mode.icon,
    );
  }
}
