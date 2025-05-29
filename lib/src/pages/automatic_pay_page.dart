import 'dart:async';

import 'package:flutter/material.dart';
import 'package:moosyl/src/widgets/video_player.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:moosyl/src/models/payment_request_model.dart';
import 'package:moosyl/src/pages/manual_payment_page.dart';

import 'package:moosyl/src/helpers/exception_handling/exception_mapper.dart';
import 'package:moosyl/src/providers/get_payment_methods_provider.dart';
import 'package:moosyl/src/widgets/error_message_card.dart';
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
    required this.tutorialVideoPath,
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

  /// The path of the explain video.
  final String? tutorialVideoPath;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AutomaticPayProvider(
        publishableApiKey: publishableApiKey,
        transactionId: transactionId,
        method: method,
        onPaymentSuccess: onPaymentSuccess,
      ),
      child: _AutomaticPayBody(
        organizationLogo,
        fullPage,
        tutorialVideoPath,
      ),
    );
  }
}

class _AutomaticPayBody extends StatelessWidget {
  final Widget? organizationLogo;
  final bool fullPage;
  final String? tutorialVideoPath;
  const _AutomaticPayBody(
      this.organizationLogo, this.fullPage, this.tutorialVideoPath);

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
          if (tutorialVideoPath != null)
            VideoPlayer(
              videoPath: tutorialVideoPath!,
              autoPlay: true,
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
            label: localizationHelper.enterYourPaymentInformation,
          ),
          AppTextInput(
            margin: horizontalPadding,
            maxLength: 8,
            controller: provider.phoneNumberTextController,
            validator: (value) =>
                Validators.validateMauritanianPhoneNumber(value, context),
            hint: localizationHelper.enterYourBankilyPhoneNumber,
          ),
          AppTextInput(
            margin: horizontalPadding,
            controller: provider.passCodeTextController,
            validator: (value) => Validators.validatePassCode(value, context),
            hint: localizationHelper.paymentPassCode,
            errorText: provider.error != null
                ? ExceptionMapper.getErrorMessage(
                    provider.error,
                    context,
                  )
                : null,
            maxLength: 4,
          ),
          if (provider.error != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ErrorMessageCard(
                message: localizationHelper.errorWhilePaying,
              ),
            ),
        ],
      ),
    );

    if (!fullPage) {
      return Column(
        children: [children, paymentButton],
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
    final getPaymentMethodsProvider = context.read<GetPaymentMethodsProvider>();
    final merchantCode = (mode is ManualConfigModel)
        ? (mode as ManualConfigModel).merchantCode
        : (mode as BankilyConfigModel).bPayNumber;
    final isPhoneNumber = merchantCode.length == 8;

    return Padding(
      padding: const EdgeInsets.all(6),
      child: Column(
        children: [
          if (mode.type.isManual)
            Stack(
              alignment: Alignment.topRight,
              children: [
                mode.method.icon.apply(
                  size: 200,
                ),
                Positioned(
                  child: InkWell(
                    onTap: () =>
                        getPaymentMethodsProvider.setPaymentMethod(null),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.close,
                          size: 30,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (mode is BankilyConfigModel)
                  Text(
                    localizationHelper
                        .copyTheCodeBPayAndHeadToBankilyToPayTheAmount,
                  )
                else if (isPhoneNumber)
                  Text(
                    localizationHelper
                        .copyThePhoneNumberAndHeadToMethodToPayTheAmount(
                      mode.method.title(context),
                    ),
                  )
                else
                  Text(
                    localizationHelper
                        .copyTheMerchantCodeAndHeadToMethodToPayTheAmount(
                      mode.method.title(context),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (mode is ManualConfigModel) ...[
            if (isPhoneNumber)
              card(
                context,
                localizationHelper.ourPhoneNumber,
                merchantCode,
                copyableValue: merchantCode,
              )
            else
              card(
                context,
                localizationHelper.merchantCode,
                merchantCode,
                copyableValue: merchantCode,
              ),
          ] else if (mode is BankilyConfigModel)
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
