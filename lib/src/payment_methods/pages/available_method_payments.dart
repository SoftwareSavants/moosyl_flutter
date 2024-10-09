import 'dart:async';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:moosyl/l10n/generated/moosyl_localization.dart';

import 'package:moosyl/src/payment_methods/models/payment_method_model.dart';
import 'package:moosyl/src/payment_methods/providers/get_payment_methods_provider.dart';
import 'package:moosyl/src/widgets/container.dart';
import 'package:moosyl/src/widgets/error_widget.dart';
import 'package:moosyl/src/widgets/icons.dart';

/// A widget that displays the available payment methods for selection.
///
/// This widget allows users to choose a payment method from a grid of options.
/// It retrieves the available methods using the [GetPaymentMethodsProvider]
/// and handles loading and error states.
class AvailableMethodPage extends StatelessWidget {
  /// Creates an instance of [AvailableMethodPage].
  ///
  /// the [apiKey] for fetching available methods, and optional custom handlers
  /// and icons for different payment methods.
  const AvailableMethodPage({
    super.key,
    required this.apiKey,
    required this.enabledPayments,
    this.customHandlers = const {},
    this.customIcons,
  });

  /// The API key used for retrieving the available payment methods.
  final String apiKey;

  /// Optional custom handlers for specific payment methods.
  final Map<PaymentMethodTypes, FutureOr<void> Function()> customHandlers;

  /// Optional custom icons for different payment methods.
  final Map<PaymentMethodTypes, String>? customIcons;

  final List<PaymentMethodTypes> enabledPayments;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GetPaymentMethodsProvider>();

    // Show loading indicator while fetching payment methods.
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Display an error widget if there was an error fetching payment methods.
    if (provider.error != null) {
      return AppErrorWidget(
        message: provider.error,
        onRetry: provider.getMethods,
      );
    }

    final methods = {
      ...provider.methods.map(
        (method) => method.method,
      ),
      ...customHandlers.keys
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Display the title for payment methods.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              MoosylLocalization.of(context)!.paymentMethod,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: methods.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.8,
              ),
              itemBuilder: (context, index) {
                final method = methods.elementAt(index);

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
  }

  /// Builds a card widget for displaying a payment method.
  ///
  /// Takes the [context] and the selected [mode] of payment as parameters.
  /// Returns a card with an icon or custom icon depending on the availability.
  Widget card(BuildContext context, PaymentMethodTypes mode) {
    final withIcon = customIcons?[mode] != null;

    return AppContainer(
      border: Border.all(width: 1),
      padding: const EdgeInsetsDirectional.all(24),
      child: withIcon ? AppIcon(path: customIcons?[mode]) : mode.icon,
    );
  }
}
