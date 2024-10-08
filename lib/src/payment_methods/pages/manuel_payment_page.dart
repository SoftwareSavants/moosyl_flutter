import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:software_pay/software_pay.dart';
import 'package:software_pay/src/payment_methods/pages/pay.dart';
import 'package:software_pay/src/payment_methods/providers/pay_provider.dart';
import 'package:software_pay/src/widgets/buttons.dart';
import 'package:software_pay/src/widgets/container.dart';
import 'package:software_pay/src/widgets/pick_image.dart';
import 'package:software_pay/src/widgets/text_input.dart';

class ManuelPaymentPage extends StatelessWidget {
  ManuelPaymentPage({
    super.key,
    required this.organizationLogo,
    required this.apiKey,
    required this.operationId,
    required this.method,
  });

  /// The payment method selected for the payment process.
  final ManualConfigModel method;

  /// A widget representing the logo of the organization.
  final Widget organizationLogo;

  /// The API key for authenticating the payment transaction.
  final String apiKey;

  /// The operation ID associated with the current payment.
  final String operationId;

  @override
  Widget build(BuildContext context) {
    final deviceBottomPadding = MediaQuery.of(context).padding.bottom;
    final localizationHelper = SoftwarePayLocalization.of(context)!;
    return ChangeNotifierProvider(
      create: (_) => ManuelPayProvider(
        apiKey: apiKey,
        method: method,
        operationId: operationId,
        context: context,
      ),
      builder: (context, child) {
        final provider = context.watch<ManuelPayProvider>();

        return Scaffold(
          appBar: AppBar(
            title: Text(method.method.title(context)),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
              const Divider(height: 1, thickness: 4),
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
                onChanged: (selectedFiles) {
                  if (selectedFiles.isNotEmpty) {
                    provider.setSelectedImage(selectedFiles.first.file);
                  }
                },
              )
            ],
          ),
          bottomSheet: AppContainer(
            color: Theme.of(context).colorScheme.onPrimary,
            width: double.infinity,
            padding: EdgeInsets.only(
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
              disabled: provider.selectedImage == null,
              labelText: localizationHelper.sendForVerification,
              onPressed: () => provider.pay(context),
            ),
          ),
        );
      },
    );
  }
}
