import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:software_pay/l10n/localization_helper.dart';
import 'package:software_pay/payment_methods/models/payment_method_model.dart';
import 'package:software_pay/payment_methods/providers/pay_provider.dart';
import 'package:software_pay/widgets/buttons.dart';
import 'package:software_pay/widgets/container.dart';
import 'package:software_pay/widgets/error_widget.dart';
import 'package:software_pay/widgets/feedback.dart';
import 'package:software_pay/widgets/icons.dart';
import 'package:software_pay/widgets/text_input.dart';

class Pay extends HookWidget {
  final PaymentMethod method;
  final String apiKey;
  final String operationId;
  final Widget organizationLogo;
  final void Function()? onPaymentSuccess;

  const Pay({
    super.key,
    required this.method,
    required this.apiKey,
    required this.operationId,
    required this.organizationLogo,
    this.onPaymentSuccess,
  });

  @override
  Widget build(BuildContext context) {
    const horizontalPadding = EdgeInsetsDirectional.symmetric(horizontal: 16);
    final localizationHelper = GetIt.I<LocalizationsHelper>();

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

class _ModeOfPaymentInfo extends StatelessWidget {
  final PaymentMethod mode;
  final Widget organizationLogo;
  const _ModeOfPaymentInfo({
    required this.mode,
    required this.organizationLogo,
  });

  @override
  Widget build(BuildContext context) {
    final localizationHelper = GetIt.I<LocalizationsHelper>();
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
