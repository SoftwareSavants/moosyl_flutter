import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:software_pay/src/l10n/localization_helper.dart';
import 'package:software_pay/src/payment_methods/models/payment_method_model.dart';
import 'package:software_pay/src/payment_methods/providers/pay_provider.dart';
import 'package:software_pay/src/widgets/buttons.dart';
import 'package:software_pay/src/widgets/container.dart';
import 'package:software_pay/src/widgets/error_widget.dart';
import 'package:software_pay/src/widgets/feedback.dart';
import 'package:software_pay/src/widgets/icons.dart';
import 'package:software_pay/src/widgets/text_input.dart';

/// A widget that represents the payment process.
///
/// The [Pay] widget allows users to make a payment using the provided
/// [PaymentMethod]. It manages the payment input and validation process.
class Pay extends HookWidget {
  /// Creates a [Pay] widget.
  ///
  /// Requires the [method], [apiKey], [operationId], and [organizationLogo].
  /// Optionally accepts a callback [onPaymentSuccess] to be called when
  /// payment is successful.
  const Pay({
    super.key,
    required this.method,
    required this.apiKey,
    required this.operationId,
    required this.organizationLogo,
    this.onPaymentSuccess,
  });

  /// The payment method selected for the payment process.
  final PaymentMethod method;

  /// The API key required for payment authentication.
  final String apiKey;

  /// The operation ID associated with the current payment.
  final String operationId;

  /// The logo of the organization processing the payment.
  final Widget organizationLogo;

  /// Callback to be executed upon successful payment.
  final void Function()? onPaymentSuccess;

  @override
  Widget build(BuildContext context) {
    const horizontalPadding = EdgeInsetsDirectional.symmetric(horizontal: 16);
    final localizationHelper = LocalizationsHelper();

    return ChangeNotifierProvider(
      create: (_) => PayProvider(
        apiKey: apiKey,
        method: method,
        operationId: operationId,
        onPaymentSuccess: onPaymentSuccess,
      ),
      builder: (context, child) {
        final provider = context.watch<PayProvider>();

        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.error != null) {
          return AppErrorWidget(
            message: provider.error,
            onRetry: provider.getOperation,
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(method.method.title),
          ),
          body: Form(
            key: provider.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InputLabel(
                  label: localizationHelper.msgs.payUsing(
                    method.method.title,
                  ),
                  child: Text(
                    localizationHelper
                        .msgs.copyTheCodeBPayAndHeadToBankilyToPayTheAmount,
                  ),
                ),
                const SizedBox(height: 8),
                _ModeOfPaymentInfo(
                  mode: method,
                  organizationLogo: organizationLogo,
                ),
                const SizedBox(height: 6),
                const Divider(height: 1, thickness: 4),
                const SizedBox(height: 16),
                InputLabel(
                  label: localizationHelper.msgs.afterPayment,
                  child: Text(
                    localizationHelper
                        .msgs.afterMakingThePaymentFillTheFollowingInformation,
                  ),
                ),
                const SizedBox(height: 20),
                AppTextInput(
                  margin: horizontalPadding,
                  maxLength: 8,
                  controller: provider.phoneNumberTextController,
                  hint: localizationHelper.msgs.enterYourBankilyPhoneNumber,
                  label: localizationHelper.msgs.bankilyPhoneNumber,
                ),
                AppTextInput(
                  margin: horizontalPadding,
                  controller: provider.passCodeTextController,
                  hint: localizationHelper.msgs.paymentPassCode,
                  label: localizationHelper.msgs.paymentPassCodeFromBankily,
                  maxLength: 4,
                ),
              ],
            ),
          ),
          bottomSheet: Padding(
            padding: const EdgeInsetsDirectional.all(16),
            child: AppButton(
              labelText: localizationHelper.msgs.sendForVerification,
              margin: EdgeInsetsDirectional.zero,
              disabled: provider.formKey.currentState?.validate() ?? false,
              onPressed: () => provider.pay(context),
            ),
          ),
        );
      },
    );
  }
}

/// A widget that displays information about the selected payment method.
///
/// This widget shows details specific to the payment method, such as
/// payment codes and the amount to pay.
class _ModeOfPaymentInfo extends StatelessWidget {
  /// Creates a [_ModeOfPaymentInfo] widget.
  const _ModeOfPaymentInfo({
    required this.mode,
    required this.organizationLogo,
  });

  /// The selected payment method.
  final PaymentMethod mode;

  /// The logo of the organization processing the payment.
  final Widget organizationLogo;

  @override
  Widget build(BuildContext context) {
    final localizationHelper = LocalizationsHelper();
    final provider = context.watch<PayProvider>();

    if (mode is! BankilyConfigModel) {
      return const SizedBox.shrink();
    }
    final bpayMethod = mode as BankilyConfigModel;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: organizationLogo),
              const SizedBox(width: 32),
              AppIcons.close,
              const SizedBox(width: 32),
              Expanded(child: bpayMethod.method.icon.apply(size: 80)),
            ],
          ),
          const SizedBox(height: 24),
          card(
            context,
            localizationHelper.msgs.codeBPay,
            bpayMethod.bPayNumber,
            copyableValue: bpayMethod.bPayNumber,
          ),
          card(
            context,
            localizationHelper.msgs.amountToPay,
            provider.operation!.amount.toStringAsFixed(2),
          ),
        ],
      ),
    );
  }

  /// Creates a card displaying a title and description.
  ///
  /// The [copyableValue] parameter allows the description to be copied
  /// when tapped, if provided.
  Widget card(
    BuildContext context,
    String title,
    String description, {
    String? copyableValue,
  }) {
    return AppContainer(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsetsDirectional.symmetric(
        vertical: 16,
        horizontal: 12,
      ),
      borderRadius: BorderRadius.circular(8),
      margin: const EdgeInsetsDirectional.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title),
          const Spacer(),
          Text.rich(
            TextSpan(
              text: description,
              children: [
                if (copyableValue != null)
                  WidgetSpan(
                    child: AppContainer(
                      margin: const EdgeInsetsDirectional.only(
                        start: 8,
                      ),
                      padding: EdgeInsetsDirectional.zero,
                      onTap: () => Feedbacks.copy(copyableValue, context),
                      child: AppIcons.copy.apply(size: 20),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
