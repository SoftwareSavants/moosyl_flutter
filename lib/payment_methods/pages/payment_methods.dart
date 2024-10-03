import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:software_pay/helpers/fetcher.dart';
import 'package:software_pay/l10n/localization_helper.dart';
import 'package:software_pay/payment_methods/providers/get_payment_methods_provider.dart';

import 'package:software_pay/widgets/container.dart';
import 'package:software_pay/payment_methods/models/payment_method_model.dart';
import 'package:software_pay/widgets/state_renderer.dart';

class SoftwarePay extends HookWidget {
  final String apiKey;
  final Map<PaymentMethodTypes, VoidCallback>? customHandlers;

  const SoftwarePay({
    super.key,
    required this.apiKey,
    this.customHandlers,
  });

  @override
  Widget build(BuildContext context) {
    useMemoized(
      () {
        GetIt.I.registerSingleton(Fetcher(apiKey));
        GetIt.I.registerSingleton(LocalizationsHelper(context));
      },
      [apiKey],
    );

    final selectedModeOfPayment = useState<PaymentMethod?>(null);

    if (selectedModeOfPayment.value == null) {
      return AvailableMethodPage(
        customHandlers: customHandlers,
        onSelected: (modeOfPayment) {
          selectedModeOfPayment.value = modeOfPayment;
        },
      );
    }

    return const SizedBox.shrink();
  }
}

class AvailableMethodPage extends ConsumerWidget {
  final void Function(PaymentMethod) onSelected;
  final Map<PaymentMethodTypes, void Function()>? customHandlers;

  const AvailableMethodPage({
    super.key,
    required this.onSelected,
    this.customHandlers,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final validMethodsState = ref.watch(getPaymentMethodProvider);

    return AsyncValueRenderer(
      state: validMethodsState,
      onRetry: () => ref.refresh(getPaymentMethodProvider),
      builder: (configuredMethods) {
        final validMethods = [
          ...configuredMethods.map((e) => e.method),
          if (customHandlers != null) ...customHandlers!.keys
        ];

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

                    return InkWell(
                      onTap: () {
                        if (customHandlers?[validMethods[index]] != null) {
                          customHandlers![validMethods[index]]!();
                          return Navigator.pop(context);
                        }

                        onSelected(configuredMethods.firstWhere(
                          (element) => element.method == method,
                        ));
                      },
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
    return AppContainer(
      border: Border.all(),
      padding: const EdgeInsetsDirectional.all(24),
      child: mode.icon,
    );
  }
}
