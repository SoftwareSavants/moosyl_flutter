import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moosyl/moosyl.dart';
import 'package:moosyl/src/payment_methods/pages/pay.dart';
import 'package:moosyl/src/payment_methods/providers/pay_provider.dart';
import 'package:moosyl/src/widgets/buttons.dart';
import 'package:moosyl/src/widgets/container.dart';
import 'package:moosyl/src/widgets/pick_image.dart';
import 'package:moosyl/src/widgets/text_input.dart';

/// The manual payment method
class ManuelPaymentPage extends StatelessWidget {
  /// The manual payment method contractor
  const ManuelPaymentPage({
    super.key,
    required this.organizationLogo,
    required this.apiKey,
    required this.transactionId,
    required this.method,
  });

  /// The payment method selected for the payment process.
  final ManualConfigModel method;

  /// A widget representing the logo of the organization.
  final Widget organizationLogo;

  /// The API key for authenticating the payment transaction.
  final String apiKey;

  /// The transaction ID associated with the current payment.
  final String transactionId;

  @override
  Widget build(BuildContext context) {
    final deviceBottomPadding = MediaQuery.of(context).padding.bottom;
    final localizationHelper = MoosylLocalization.of(context)!;

    final provider = context.watch<PayProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(method.method.title(context)),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 200),
        children: [
          InputLabel(
            label: localizationHelper.payUsing(
              method.method.title(context),
            ),
            child: Text(
              localizationHelper
                  .copyTheMerchantCodeAndHeadToSedadToPayTheAmount,
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
          PickImageCard(
            onChanged: provider.setSelectedImage,
          )
        ],
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
          disabled: provider.selectedFile == null,
          labelText: localizationHelper.sendForVerification,
          onPressed: () => provider.manualPay(context, method),
        ),
      ),
    );
  }
}
