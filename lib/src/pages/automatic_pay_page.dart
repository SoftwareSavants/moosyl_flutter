import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:moosyl/src/models/payment_request_model.dart';
import 'package:moosyl/src/helpers/exception_handling/exception_mapper.dart';
import 'package:moosyl/src/providers/get_payment_methods_provider.dart';
import 'package:moosyl/src/widgets/buttons.dart';
import 'package:provider/provider.dart';
import 'package:moosyl/l10n/generated/moosyl_localization.dart';
import 'package:moosyl/src/helpers/validators.dart';

import 'package:moosyl/src/models/payment_method_model.dart';
import 'package:moosyl/src/providers/pay_provider.dart';
import 'package:moosyl/src/widgets/container.dart';
import 'package:moosyl/src/widgets/error_widget.dart';
import 'package:moosyl/src/widgets/feedback.dart';
import 'package:moosyl/src/widgets/icons.dart';
import 'package:moosyl/src/widgets/text_input.dart';

/// A widget that displays the mode of payment information.
class BottomSheetButton extends StatelessWidget {
  /// Loading state of the button.
  final bool loading;

  /// Disabled state of the button.
  final bool disabled;

  /// Callback function for the button.
  final VoidCallback onTap;

  /// Error message to display.
  final String? error;

  /// Flag to indicate whether the button should have a shadow.
  final bool withShadow;

  /// A widget that displays the mode of payment information.

  /// Constructor for [BottomSheetButton].
  const BottomSheetButton({
    super.key,
    required this.loading,
    required this.disabled,
    required this.onTap,
    required this.withShadow,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final deviceBottomPadding = MediaQuery.of(context).padding.bottom;
    final localizationHelper = MoosylLocalization.of(context)!;

    return AppContainer(
      color: Theme.of(context).colorScheme.onPrimary,
      width: double.infinity,
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16).copyWith(
        bottom: deviceBottomPadding == 0 ? 20 : deviceBottomPadding,
      ),
      shadows: [
        if (withShadow)
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            offset: const Offset(0, -4),
            blurRadius: 16,
          )
      ],
      borderRadius: BorderRadius.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (error != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 16),
              child: AppErrorWidget(
                message: error,
                horizontalAxis: true,
              ),
            ),
          AppButton(
            loading: loading,
            disabled: disabled,
            labelText: loading
                ? localizationHelper.sending
                : error != null
                    ? localizationHelper.retry
                    : localizationHelper.sendForVerification,
            background:
                error != null ? Theme.of(context).colorScheme.error : null,
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}

/// A widget that represents the payment process.
///
/// The [AutomaticPayPage] widget allows users to make a payment using the provided
/// [PaymentMethod]. It manages the payment input and validation process.
class AutomaticPayPage extends HookWidget {
  /// Creates a [AutomaticPayPage] widget.
  ///
  /// Requires the [method], [publishableApiKey], [transactionId], and [organizationLogo].
  /// Optionally accepts a callback [onPaymentSuccess] to be called when
  /// payment is successful.

  const AutomaticPayPage({
    super.key,
    required this.method,
    required this.publishableApiKey,
    required this.transactionId,
    this.organizationLogo,
    this.onPaymentSuccess,
    this.fullPage = true,
  });

  /// The payment method selected for the payment process.
  final PaymentMethod method;

  /// The API key required for payment authentication.
  final String publishableApiKey;

  /// The transaction ID associated with the current payment.
  final String transactionId;

  /// The logo of the organization processing the payment.
  final Widget? organizationLogo;

  /// Callback to be executed upon successful payment.
  final FutureOr<void> Function()? onPaymentSuccess;

  /// Builds the [AutomaticPayPage] widget.
  final bool fullPage;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AutomaticPayProvider(
        publishableApiKey: publishableApiKey,
        transactionId: transactionId,
        method: method,
        onPaymentSuccess: onPaymentSuccess,
      ),
      child: _AutomaticPayBody(organizationLogo, fullPage),
    );
  }
}

class _AutomaticPayBody extends StatelessWidget {
  final Widget? organizationLogo;
  final bool fullPage;
  const _AutomaticPayBody(this.organizationLogo, this.fullPage);

  @override
  Widget build(BuildContext context) {
    const horizontalPadding = EdgeInsetsDirectional.symmetric(horizontal: 16);
    final localizationHelper = MoosylLocalization.of(context)!;

    final getPaymentMethodsProvider = context.read<GetPaymentMethodsProvider>();

    final provider = context.watch<AutomaticPayProvider>();

    if (provider.isLoading && provider.paymentRequest == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.error != null && provider.paymentRequest == null) {
      return AppErrorWidget(
        message: ExceptionMapper.getErrorMessage(provider.error, context),
        onRetry: provider.getPaymentRequest,
      );
    }

    final method = provider.method;

    final paymentButton = BottomSheetButton(
      disabled: false,
      loading: provider.isLoading,
      onTap: () => provider.pay(context),
      withShadow: fullPage,
    );

    final children = Form(
      key: provider.formKey,
      child: ListView(
        padding: EdgeInsets.only(bottom: fullPage ? 200 : 20, top: 16),
        shrinkWrap: !fullPage,
        physics: !fullPage ? const NeverScrollableScrollPhysics() : null,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      localizationHelper.payUsing(
                        method.method.title(context),
                      ),
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium!
                          .copyWith(fontSize: 20),
                    ),
                    if (!fullPage)
                      AppButton(
                        minHeight: 0,
                        background: Theme.of(context).colorScheme.onPrimary,
                        textColor: Theme.of(context).colorScheme.onSurface,
                        margin: EdgeInsets.zero,
                        border: BorderSide(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        labelText: localizationHelper.change,
                        onPressed: () =>
                            getPaymentMethodsProvider.setPaymentMethod(null),
                      ),
                  ],
                ),
                Text(
                  localizationHelper
                      .copyTheCodeBPayAndHeadToBankilyToPayTheAmount,
                ),
              ],
            ),
          ),
          ModeOfPaymentInfo(
            mode: method,
            organizationLogo: organizationLogo,
            paymentRequest: provider.paymentRequest!,
          ),
          Divider(
            height: 1,
            thickness: 4,
            color: Theme.of(context).colorScheme.surface,
          ),
          const SizedBox(height: 16),
          InputLabel(
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontSize: 18,
                ),
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
            validator: (value) =>
                Validators.validateMauritanianPhoneNumber(value, context),
            hint: localizationHelper.enterYourBankilyPhoneNumber,
            label: localizationHelper.bankilyPhoneNumber,
          ),
          AppTextInput(
            margin: horizontalPadding,
            controller: provider.passCodeTextController,
            validator: (value) => Validators.validatePassCode(value, context),
            hint: localizationHelper.paymentPassCode,
            label: localizationHelper.paymentPassCodeFromBankily,
            errorText: provider.error != null
                ? ExceptionMapper.getErrorMessage(
                    provider.error,
                    context,
                  )
                : null,
            maxLength: 4,
          ),
        ],
      ),
    );

    if (!fullPage) {
      return Column(
        children: [
          Expanded(child: SingleChildScrollView(child: children)),
          paymentButton
        ],
      );
    }

    return Scaffold(
      appBar: fullPage
          ? AppBar(
              title: Text(method.method.title(context)),
              leading: BackButton(
                onPressed: () =>
                    getPaymentMethodsProvider.setPaymentMethod(null),
              ),
            )
          : null,
      body: children,
      bottomSheet: paymentButton,
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
    this.organizationLogo,
    required this.paymentRequest,
  });

  /// The selected payment method.
  final PaymentMethod mode;

  /// The logo of the organization processing the payment.
  final Widget? organizationLogo;

  ///
  final PaymentRequestModel paymentRequest;

  @override
  Widget build(BuildContext context) {
    final localizationHelper = MoosylLocalization.of(context)!;

    final isManual = mode is ManualConfigModel;

    final merchantCode =
        isManual ? (mode as ManualConfigModel).merchantCode : '';

    final identifierLabel = isManual && merchantCode.length < 8
        ? localizationHelper.merchantCodeLabel
        : localizationHelper.phoneNumberLabel;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: organizationLogo != null
                ? [
                    Expanded(
                      child: organizationLogo!,
                    ),
                    const SizedBox(width: 32),
                    AppIcons.close,
                    const SizedBox(width: 32),
                    Expanded(
                      child: mode.method.icon.apply(size: 80),
                    ),
                  ]
                : [
                    Expanded(
                      child: mode.method.icon.apply(size: 120),
                    ),
                  ],
          ),
          const SizedBox(height: 12),
          if (mode is ManualConfigModel) ...[
            card(
              context,
              identifierLabel,
              (mode as ManualConfigModel).merchantCode,
              copyableValue: mode.id,
            ),
            card(
              context,
              localizationHelper.amountToPay,
              paymentRequest.amount.toStringAsFixed(2),
            ),
          ] else if (mode is BankilyConfigModel) ...[
            card(
              context,
              localizationHelper.codeBPay,
              (mode as BankilyConfigModel).bPayNumber,
              copyableValue: (mode as BankilyConfigModel).bPayNumber,
            ),
            card(
              context,
              localizationHelper.amountToPay,
              paymentRequest.amount.toStringAsFixed(2),
            ),
          ]
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
