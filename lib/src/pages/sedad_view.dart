import 'package:flutter/material.dart';
import 'package:moosyl/moosyl.dart';
import 'package:moosyl_flutter/l10n/generated/moosyl_localization.dart';
import 'package:moosyl_flutter/src/models/payment_method_model.dart';
import 'package:moosyl_flutter/src/providers/pay_provider.dart';
import 'package:moosyl_flutter/src/widgets/buttons.dart';
import 'package:moosyl_flutter/src/widgets/container.dart';
import 'package:moosyl_flutter/src/widgets/feedback.dart';
import 'package:moosyl_flutter/src/widgets/icons.dart';

import 'package:provider/provider.dart';

/// A dialog view for Sedad/Bim Bank payment flow.
///
/// Displays payment code with copyable container, steps, and action buttons.
class SedadView extends StatelessWidget {
  /// The payment code (merchant code) to display.
  final String paymentCodeDisplay;

  /// The payment request containing amount and other details.
  final PaymentRequestGetData paymentRequest;

  /// Callback when the dialog is closed (e.g. to go back to payment method selection).
  final VoidCallback? onClose;

  /// The primary color of the app.
  final Color primaryColor;

  const SedadView({
    super.key,
    required this.paymentCodeDisplay,
    required this.paymentRequest,
    this.onClose,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final localizationHelper = MoosylLocalization.of(context)!;
    final payProvider = context.watch<PayProvider>();
    final platformIcon =
        PaymentMethodTypes.fromString(payProvider.method.type).icon;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 10),
      shadowColor: Theme.of(context).colorScheme.outline,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: payProvider.formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                localizationHelper.paymentCode,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: platformIcon.apply(size: 48),
                ),
              ),
              const SizedBox(height: 20),

              // Copyable container with payment code only
              GestureDetector(
                onTap: () => Feedbacks.copy(paymentCodeDisplay, context),
                child: AppContainer(
                  color: Colors.grey.shade200,
                  border: Border.all(color: Colors.grey.shade300),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    spacing: 8,
                    children: [
                      Text(
                        payProvider.method.config?.asMap['code']?.toString() ??
                            '',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        spacing: 4,
                        children: [
                          AppIcons.copy.apply(size: 20),
                          Text(localizationHelper.clickToCopy,
                              style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Steps
              _StepItem(text: localizationHelper.sedadStep1),
              _StepItem(text: localizationHelper.sedadStep2),
              _StepItem(text: localizationHelper.sedadStep3),
              _StepItem(text: localizationHelper.sedadStep4),
              // I've paid button
              _IvePaidButton(primaryColor: primaryColor),

              // Change payment method button
              AppButton(
                primaryColor: primaryColor,
                margin: const EdgeInsets.only(top: 0),
                minHeight: 40,
                style: AppButtonStyle.outline,
                labelText: localizationHelper.changePaymentMethod,
                onPressed: onClose ?? () => Navigator.of(context).pop(),
              ),
            ],
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

class _IvePaidButton extends StatelessWidget {
  final Color primaryColor;

  const _IvePaidButton({required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    final localizationHelper = MoosylLocalization.of(context)!;
    final payProvider = context.watch<PayProvider>();

    return AppButton(
      primaryColor: primaryColor,
      minHeight: 40,
      style: AppButtonStyle.primary,
      labelText: localizationHelper.ivePaid,
      loading: payProvider.isLoading,
      onPressed: () => payProvider.pay(context),
    );
  }
}
