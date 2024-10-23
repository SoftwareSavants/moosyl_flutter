import 'dart:async';

import 'package:flutter/material.dart';
import 'package:moosyl/src/helpers/exception_handling/exception_mapper.dart';
import 'package:moosyl/src/providers/get_payment_methods_provider.dart';
import 'package:moosyl/src/providers/manual_pay_provider.dart';
import 'package:moosyl/src/widgets/error_widget.dart';
import 'package:provider/provider.dart';
import 'package:moosyl/moosyl.dart';
import 'package:moosyl/src/pages/automatic_pay_page.dart';
import 'package:moosyl/src/widgets/buttons.dart';
import 'package:moosyl/src/widgets/container.dart';
import 'package:moosyl/src/widgets/pick_image.dart';
import 'package:moosyl/src/widgets/text_input.dart';

/// The manual payment method
class ManualPaymentPage extends StatelessWidget {
  /// The manual payment method contractor
  const ManualPaymentPage({
    super.key,
    required this.organizationLogo,
    required this.apiKey,
    required this.transactionId,
    required this.method,
    this.fullPage = true,
    this.onPaymentSuccess,
  });

  /// The payment method selected for the payment process.
  final ManualConfigModel method;

  /// A widget representing the logo of the organization.
  final Widget organizationLogo;

  /// The API key for authenticating the payment transaction.
  final String apiKey;

  /// The transaction ID associated with the current payment.
  final String transactionId;

  /// A flag to indicate whether the widget is in full page mode.
  final bool fullPage;

  /// Callback to be executed upon successful payment.
  final FutureOr<void> Function()? onPaymentSuccess;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ManualPayProvider(
        apiKey: apiKey,
        transactionId: transactionId,
        method: method,
        onPaymentSuccess: onPaymentSuccess,
      ),
      child: _ManualPaymentPageBody(
        organizationLogo: organizationLogo,
        fullPage: fullPage,
      ),
    );
  }
}

class _ManualPaymentPageBody extends StatelessWidget {
  final bool fullPage;
  final Widget organizationLogo;
  const _ManualPaymentPageBody({
    required this.organizationLogo,
    this.fullPage = true,
  });

  @override
  Widget build(BuildContext context) {
    final localizationHelper = MoosylLocalization.of(context)!;

    final provider = context.watch<ManualPayProvider>();

    final getPaymentMethodsProvider = context.read<GetPaymentMethodsProvider>();

    if (provider.isLoading && provider.paymentRequest == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.error != null && provider.paymentRequest == null) {
      return AppErrorWidget(
        message: ExceptionMapper.getErrorMessage(provider.error, context),
        onRetry: provider.getPaymentRequest,
        withScaffold: fullPage,
      );
    }

    final method = provider.method;

    return Scaffold(
      appBar: fullPage
          ? AppBar(
              title: Text(method.method.title(context)),
              leading: BackButton(
                onPressed: () {
                  getPaymentMethodsProvider.setPaymentMethod(null);
                },
              ),
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.only(bottom: 200),
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
                      style: Theme.of(context).textTheme.headlineMedium,
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
                      .copyTheMerchantCodeAndHeadToSedadToPayTheAmount,
                ),
              ],
            ),
          ),
          ModeOfPaymentInfo(
            mode: method,
            paymentRequest: provider.paymentRequest!,
            organizationLogo: organizationLogo,
          ),
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
          PickImageCard(onChanged: provider.setSelectedImage),
        ],
      ),
      bottomSheet: BottomSheetButton(
        disabled: provider.selectedFile == null,
        error: provider.error != null
            ? ExceptionMapper.getErrorMessage(provider.error, context)
            : null,
        loading: provider.isLoading,
        onTap: () => provider.manualPay(context, method),
      ),
    );
  }
}

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

  /// A widget that displays the mode of payment information.

  /// Constructor for [BottomSheetButton].
  const BottomSheetButton({
    super.key,
    required this.loading,
    required this.disabled,
    required this.onTap,
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
