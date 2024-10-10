import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:moosyl/l10n/generated/moosyl_localization.dart';
import 'package:moosyl/src/helpers/validators.dart';

import 'package:moosyl/src/payment_methods/models/payment_method_model.dart';
import 'package:moosyl/src/payment_methods/providers/pay_provider.dart';
import 'package:moosyl/src/widgets/buttons.dart';
import 'package:moosyl/src/widgets/container.dart';
import 'package:moosyl/src/widgets/error_widget.dart';
import 'package:moosyl/src/widgets/feedback.dart';
import 'package:moosyl/src/widgets/icons.dart';
import 'package:moosyl/src/widgets/text_input.dart';

/// A widget that represents the payment process.
///
/// The [Pay] widget allows users to make a payment using the provided
/// [PaymentMethod]. It manages the payment input and validation process.
class Pay extends HookWidget {
  /// Creates a [Pay] widget.
  ///
  /// Requires the [method], [apiKey], [transactionId], and [organizationLogo].
  /// Optionally accepts a callback [onPaymentSuccess] to be called when
  /// payment is successful.
  const Pay({
    super.key,
    required this.method,
    required this.apiKey,
    required this.transactionId,
    required this.organizationLogo,
    this.onPaymentSuccess,
  });

  /// The payment method selected for the payment process.
  final PaymentMethod method;

  /// The API key required for payment authentication.
  final String apiKey;

  /// The transaction ID associated with the current payment.
  final String transactionId;

  /// The logo of the organization processing the payment.
  final Widget organizationLogo;

  /// Callback to be executed upon successful payment.
  final FutureOr<void> Function()? onPaymentSuccess;

  @override
  Widget build(BuildContext context) {
    const horizontalPadding = EdgeInsetsDirectional.symmetric(horizontal: 16);
    final localizationHelper = MoosylLocalization.of(context)!;

    final provider = context.watch<PayProvider>();

    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.error != null) {
      return AppErrorWidget(
        message: provider.error,
        onRetry: provider.getPaymentRequest,
      );
    }

    final deviceBottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: Text(method.method.title(context)),
      ),
      body: Form(
        key: provider.formKey,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 200),
          children: [
            InputLabel(
              label: localizationHelper.payUsing(
                method.method.title(context),
              ),
              child: Text(
                localizationHelper
                    .copyTheCodeBPayAndHeadToBankilyToPayTheAmount,
              ),
            ),
            const SizedBox(height: 8),
            ModeOfPaymentInfo(
              mode: method,
              organizationLogo: organizationLogo,
            ),
            const SizedBox(height: 6),
            Divider(
              height: 1,
              thickness: 4,
              color: Theme.of(context).colorScheme.surface,
            ),
            const SizedBox(height: 16),
            InputLabel(
              label: localizationHelper.afterPayment,
              child: Text(
                localizationHelper
                    .afterMakingThePaymentFillTheFollowingInformation,
              ),
            ),
            const SizedBox(height: 20),
            AppTextInput(
              margin: horizontalPadding,
              maxLength: 8,
              controller: provider.phoneNumberTextController,
              validator: Validators.validateMauritanianPhoneNumber,
              hint: localizationHelper.enterYourBankilyPhoneNumber,
              label: localizationHelper.bankilyPhoneNumber,
            ),
            AppTextInput(
              margin: horizontalPadding,
              controller: provider.passCodeTextController,
              validator: Validators.validatePassCode,
              hint: localizationHelper.paymentPassCode,
              label: localizationHelper.paymentPassCodeFromBankily,
              maxLength: 4,
            ),
          ],
        ),
      ),
      bottomSheet: AppContainer(
        color: Theme.of(context).colorScheme.onPrimary,
        width: double.infinity,
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 16).copyWith(
          bottom: deviceBottomPadding == 0 ? 20 : deviceBottomPadding,
        ),
        shadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            offset: const Offset(0, -4),
            blurRadius: 16,
          )
        ],
        borderRadius: BorderRadius.zero,
        child: AppButton(
          labelText: localizationHelper.sendForVerification,
          onPressed: () => provider.pay(
            context,
            method,
          ),
        ),
      ),
    );
  }
}

/// A widget that displays information about the selected payment method.
///
/// This widget shows details specific to the payment method, such as
/// payment codes and the amount to pay.
class ModeOfPaymentInfo extends StatelessWidget {
  /// Creates a [ModeOfPaymentInfo] widget.
  const ModeOfPaymentInfo({
    super.key,
    required this.mode,
    required this.organizationLogo,
  });

  /// The selected payment method.
  final PaymentMethod mode;

  /// The logo of the organization processing the payment.
  final Widget organizationLogo;

  @override
  Widget build(BuildContext context) {
    final localizationHelper = MoosylLocalization.of(context)!;

    final provider = context.watch<PayProvider>();

    if (provider.paymentRequest == null) {
      return const SizedBox(
          height: 100,
          child: Center(
            child: CircularProgressIndicator(),
          ));
    }

    if (mode is ManualConfigModel) {
      final manualMethod = mode as ManualConfigModel;

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
                Expanded(child: manualMethod.method.icon.apply(size: 80)),
              ],
            ),
            const SizedBox(height: 24),
            card(
              context,
              localizationHelper.merchantCode,
              manualMethod.merchantCode,
              copyableValue: manualMethod.id,
            ),
            card(
              context,
              localizationHelper.amountToPay,
              provider.paymentRequest!.amount.toStringAsFixed(2),
            ),
          ],
        ),
      );
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
            localizationHelper.codeBPay,
            bpayMethod.bPayNumber,
            copyableValue: bpayMethod.bPayNumber,
          ),
          card(
            context,
            localizationHelper.amountToPay,
            provider.paymentRequest!.amount.toStringAsFixed(2),
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
