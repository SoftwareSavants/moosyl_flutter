import 'dart:async';

import 'package:flutter/material.dart';
import 'package:moosyl_flutter/l10n/generated/moosyl_localization.dart';
import 'package:moosyl_flutter/src/helpers/validators.dart';
import 'package:moosyl_flutter/src/models/payment_method_model.dart';
import 'package:moosyl_flutter/src/providers/pay_provider.dart';
import 'package:moosyl_flutter/src/widgets/buttons.dart';
import 'package:moosyl_flutter/src/widgets/container.dart';
import 'package:moosyl_flutter/src/widgets/feedback.dart';
import 'package:moosyl_flutter/src/widgets/icons.dart';
import 'package:moosyl_flutter/src/widgets/text_input.dart';
import 'package:provider/provider.dart';

/// A widget that represents the Bankily payment process.
class BankilyView extends StatelessWidget {
  const BankilyView({
    super.key,
    required this.method,
    required this.publishableApiKey,
    required this.transactionId,
    this.organizationLogo,
    this.onPaymentSuccess,
    this.onClose,
    required this.primaryColor,
  });

  final PaymentMethod method;
  final String publishableApiKey;
  final String transactionId;
  final Widget? organizationLogo;
  final FutureOr<void> Function()? onPaymentSuccess;
  final VoidCallback? onClose;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    return _BankilyDialogContent(
      primaryColor: primaryColor,
      method: method,
      onClose: onClose ?? () => Navigator.of(context).pop(),
    );
  }
}

/// Dialog content for Bankily payment. Expects [PayProvider] from context.
class _BankilyDialogContent extends StatelessWidget {
  const _BankilyDialogContent({
    required this.primaryColor,
    required this.method,
    required this.onClose,
  });

  final PaymentMethod method;
  final VoidCallback onClose;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    final localizationHelper = MoosylLocalization.of(context)!;
    final provider = context.watch<PayProvider>();
    final platformIcon = method.method.icon;

    return Dialog(
      shadowColor: Theme.of(context).colorScheme.outline,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 10),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: provider.formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  localizationHelper.codeBPay,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  localizationHelper.useThisCodeToCompletePayment,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Platform icon
                Center(
                  child: AppContainer(
                    width: 200,
                    border: Border.all(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: platformIcon.apply(size: 48),
                  ),
                ),
                const SizedBox(height: 20),

                // Copyable container with BPay code
                GestureDetector(
                  onTap: () => Feedbacks.copy(method.bPayNumber, context),
                  child: AppContainer(
                    color: Colors.grey.shade200,
                    border: Border.all(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      spacing: 8,
                      children: [
                        Text(
                          method.bPayNumber,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          spacing: 4,
                          children: [
                            AppIcons.copy.apply(size: 20),
                            Text(
                              localizationHelper.clickToCopy,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Steps
                _StepItem(text: localizationHelper.bankilyStep1),
                _StepItem(text: localizationHelper.bankilyStep2),
                _StepItem(text: localizationHelper.bankilyStep3),
                _StepItem(text: localizationHelper.bankilyStep4),
                const SizedBox(height: 16),

                // Phone and passcode inputs in same container
                AppContainer(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppTextInput(
                        controller: provider.phoneNumberTextController,
                        validator: (value) =>
                            Validators.validateMauritanianPhoneNumber(
                                value, context),
                        hint: localizationHelper.enterYourBankilyPhoneNumber,
                        label: localizationHelper.bankilyPhoneNumber,
                        maxLength: 8,
                      ),
                      AppTextInput(
                        controller: provider.passCodeTextController,
                        validator: (value) =>
                            Validators.validatePassCode(value, context),
                        hint: localizationHelper.paymentPassCode,
                        label: localizationHelper.paymentPassCode,
                        maxLength: 4,
                      ),
                    ],
                  ),
                ),
                // Pay button
                AppButton(
                  primaryColor: primaryColor,
                  minHeight: 40,
                  style: AppButtonStyle.primary,
                  labelText: localizationHelper.pay,
                  loading: provider.isLoading,
                  onPressed: () => provider.pay(context),
                ),

                // Change payment method button
                AppButton(
                  primaryColor: primaryColor,
                  margin: const EdgeInsets.only(top: 8),
                  minHeight: 40,
                  style: AppButtonStyle.outline,
                  labelText: localizationHelper.changePaymentMethod,
                  onPressed: onClose,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final String text;

  const _StepItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
