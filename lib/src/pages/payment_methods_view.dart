import 'dart:async';

import 'package:flutter/material.dart';
import 'package:moosyl/moosyl.dart';
import 'package:moosyl_flutter/l10n/generated/moosyl_localization.dart';
import 'package:moosyl_flutter/src/helpers/exception_handling/exception_mapper.dart';
import 'package:moosyl_flutter/src/models/payment_method_model.dart';
import 'package:moosyl_flutter/src/pages/bankily_view.dart';
import 'package:moosyl_flutter/src/pages/sedad_view.dart';
import 'package:moosyl_flutter/src/providers/get_payment_methods_provider.dart';
import 'package:moosyl_flutter/src/providers/pay_provider.dart';
import 'package:moosyl_flutter/src/widgets/buttons.dart';
import 'package:moosyl_flutter/src/widgets/container.dart';
import 'package:moosyl_flutter/src/widgets/error_widget.dart';
import 'package:moosyl_flutter/src/widgets/feedback.dart';
import 'package:moosyl_flutter/src/widgets/icons.dart';
import 'package:provider/provider.dart';

/// A widget that displays the available payment methods for selection.
///
/// This widget allows users to choose a payment method from a list of options.
/// Each row shows an icon, name, and radio indicator. A pay button at the bottom
/// confirms the selection and proceeds to payment.
class SelectPaymentMethodPage extends StatelessWidget {
  /// Creates an instance of [SelectPaymentMethodPage].
  const SelectPaymentMethodPage({
    super.key,
    this.primaryColor,
    this.onBackPress,
    this.amountToPay = 0.0,
    this.tax = 0.0,
    this.totalAmount = 0.0,
    required this.transactionId,
    this.onPaymentSuccess,
    required this.isFullPage,
  });

  /// When true, shows as full page. When false, shows as bottom sheet.
  final bool isFullPage;

  /// The primary color for the page (e.g. for radio, pay button).
  final Color? primaryColor;

  /// Callback when the back arrow is pressed.
  final VoidCallback? onBackPress;

  /// The amount to pay (displayed in summary).
  final double amountToPay;

  /// The tax amount (displayed in summary).
  final double tax;

  /// The total amount including tax (displayed on the pay button).
  final double totalAmount;

  /// The transaction ID (displayed in the payment request).
  final String transactionId;

  /// Callback when payment succeeds (for Sedad/Bankily dialogs).
  final FutureOr<void> Function()? onPaymentSuccess;

  @override
  Widget build(BuildContext context) {
    if (isFullPage) {
      return _SelectPaymentMethodContent(
        primaryColor: primaryColor,
        onBackPress: onBackPress,
        amountToPay: amountToPay,
        tax: tax,
        totalAmount: totalAmount,
        transactionId: transactionId,
        onPaymentSuccess: onPaymentSuccess,
        isFullPage: isFullPage,
      );
    } else {
      return _SelectPaymentMethodBottomSheetTrigger(
        primaryColor: primaryColor,
        onBackPress: onBackPress,
        amountToPay: amountToPay,
        tax: tax,
        totalAmount: totalAmount,
        transactionId: transactionId,
        onPaymentSuccess: onPaymentSuccess,
        isFullPage: isFullPage,
      );
    }
  }
}

/// Full page or bottom sheet content for payment method selection.
class _SelectPaymentMethodContent extends StatelessWidget {
  const _SelectPaymentMethodContent({
    required this.primaryColor,
    required this.onBackPress,
    required this.amountToPay,
    required this.tax,
    required this.totalAmount,
    required this.transactionId,
    required this.onPaymentSuccess,
    required this.isFullPage,
    this.onClose,
  });

  final Color? primaryColor;
  final VoidCallback? onBackPress;
  final double amountToPay;
  final double tax;
  final double totalAmount;
  final String transactionId;
  final FutureOr<void> Function()? onPaymentSuccess;
  final bool isFullPage;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GetPaymentMethodsProvider>();
    final effectivePrimary =
        primaryColor ?? Theme.of(context).colorScheme.primary;
    final localizationHelper = MoosylLocalization.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return AppErrorWidget(
        message: ExceptionMapper.getErrorMessage(provider.error, context),
        onRetry: provider.getMethods,
      );
    }

    final selectionErrorMessage = provider.selectionError != null
        ? (provider.selectionError == 'paymentRequestFullyPaid'
            ? localizationHelper.paymentRequestFullyPaid
            : provider.selectionError == 'amountToPayShouldMatchPaymentRequest'
                ? localizationHelper.amountToPayShouldMatchPaymentRequest
                : provider.selectionError)
        : null;

    final methods = provider.methods;
    final pendingSelection = provider.pendingSelection;

    final bodyContent = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  AppContainer(
                    padding: const EdgeInsets.all(16),
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      spacing: 8,
                      children: [
                        Text(localizationHelper.chooseHowYouWouldLikeToPay,
                            style: textTheme.titleMedium),
                        const SizedBox(height: 10),
                        ...methods.asMap().entries.map((e) {
                          final method = e.value;
                          return _MethodRow(
                            method: method,
                            isSelected: pendingSelection?.id == method.id,
                            primaryColor: effectivePrimary,
                            onTap: () => provider.setPendingSelection(method),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (selectionErrorMessage != null)
                  Text(selectionErrorMessage,
                      style: textTheme.bodyMedium?.copyWith(color: Colors.red)),
                const SizedBox(height: 16),
                AppContainer(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    color: Colors.grey.shade100,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (amountToPay > 0 && tax > 0)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(localizationHelper.amountToPay,
                                  style: textTheme.bodyLarge),
                              Text(
                                  '${amountToPay > 0 ? amountToPay.toStringAsFixed(0) : (provider.paymentRequest?.amount.toStringAsFixed(0) ?? '0')} MRU',
                                  style: textTheme.bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        if (tax > 0) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(localizationHelper.tax,
                                  style: textTheme.bodyLarge),
                              Text('${tax.toStringAsFixed(0)} MRU',
                                  style: textTheme.bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Divider(color: Colors.grey.shade300),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(localizationHelper.totalAmount,
                                style: textTheme.bodyLarge),
                            Text(
                                '${totalAmount > 0 ? totalAmount.toStringAsFixed(0) : (provider.paymentRequest?.amount.toStringAsFixed(0) ?? '0')} MRU',
                                style: textTheme.bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    )),
                AppButton(
                  primaryColor: effectivePrimary,
                  minHeight: 50,
                  labelText: provider.isValidating
                      ? localizationHelper.sending
                      : localizationHelper.pay,
                  onPressed: pendingSelection == null || provider.isValidating
                      ? null
                      : () => _onPayPressed(
                            context,
                            provider,
                            pendingSelection,
                            effectivePrimary,
                          ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (isFullPage) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(localizationHelper.choosePaymentMethods),
          leading: onBackPress != null
              ? IconButton(
                  onPressed: onBackPress,
                  icon: const Icon(Icons.arrow_back),
                  color: effectivePrimary,
                )
              : null,
        ),
        body: bodyContent,
      );
    }

    return bodyContent;
  }

  Future<void> _onPayPressed(
    BuildContext context,
    GetPaymentMethodsProvider provider,
    ConfigurationListDataInner pendingSelection,
    Color effectivePrimary,
  ) async {
    final methodToShow = await provider.setPaymentMethodWithValidation(
      pendingSelection,
    );
    if (!context.mounted) return;

    if (methodToShow == null) {
      if (provider.selected != null) {
        onClose?.call();
      }
      return;
    }

    final publishableApiKey = provider.publishableApiKey;
    final transactionId = provider.transactionId;

    if (PaymentMethodTypes.fromString(methodToShow.type) ==
        PaymentMethodTypes.bankily) {
      _showBankilyDialog(
        context,
        publishableApiKey: publishableApiKey,
        transactionId: transactionId,
        method: methodToShow,
        primaryColor: effectivePrimary,
      );
    } else if (PaymentMethodTypes.fromString(methodToShow.type) ==
            PaymentMethodTypes.sedad ||
        PaymentMethodTypes.fromString(methodToShow.type) ==
            PaymentMethodTypes.bimBank) {
      await _showSedadDialog(
        context,
        publishableApiKey: publishableApiKey,
        transactionId: transactionId,
        method: methodToShow,
        primaryColor: effectivePrimary,
      );
    }
  }

  Future<void> _showSedadDialog(
    BuildContext context, {
    required String publishableApiKey,
    required String transactionId,
    required ConfigurationListDataInner method,
    required Color primaryColor,
  }) async {
    final payProvider = PayProvider(
      publishableApiKey: publishableApiKey,
      transactionId: transactionId,
      method: method,
      onPaymentSuccess: () async => await onPaymentSuccess?.call(),
    );
    final getPaymentMethodsProvider = context.read<GetPaymentMethodsProvider>();

    // Show loading while fetching payment code.
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Call pay() to get the payment code before showing the Sedad dialog.
    final paymentCode = await payProvider.getPaymentCodeForSedad();

    if (context.mounted) {
      Navigator.of(context).pop(); // Dismiss loading dialog
    }
    if (!context.mounted) return;
    if (paymentCode == null || paymentCode.isEmpty) {
      if (context.mounted && payProvider.error != null) {
        Feedbacks.flushBar(
          context: context,
          message: ExceptionMapper.getErrorMessage(payProvider.error, context),
          error: true,
        );
      }
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        payProvider.onBeforePaymentSuccess = () {
          Navigator.of(dialogContext).pop();
          getPaymentMethodsProvider.setPaymentMethod(null);
        };
        return ChangeNotifierProvider<PayProvider>.value(
          value: payProvider,
          child: _DialogWithPayProvider(
            payProvider: payProvider,
            builder: (paymentRequest) => SedadView(
              primaryColor: primaryColor,
              paymentCodeDisplay: paymentCode,
              paymentRequest: paymentRequest,
              onClose: () {
                Navigator.of(dialogContext).pop();
                getPaymentMethodsProvider.setPaymentMethod(null);
              },
            ),
          ),
        );
      },
    ).then((_) {
      getPaymentMethodsProvider.setPaymentMethod(null);
    });
  }

  void _showBankilyDialog(
    BuildContext context, {
    required String publishableApiKey,
    required String transactionId,
    required ConfigurationListDataInner method,
    required Color primaryColor,
  }) {
    final payProvider = PayProvider(
      publishableApiKey: publishableApiKey,
      transactionId: transactionId,
      method: method,
      onPaymentSuccess: () async => await onPaymentSuccess?.call(),
    );
    final getPaymentMethodsProvider = context.read<GetPaymentMethodsProvider>();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => ChangeNotifierProvider<PayProvider>.value(
        value: payProvider,
        child: _DialogWithPayProvider(
          payProvider: payProvider,
          builder: (_) => BankilyView(
            primaryColor: primaryColor,
            method: method,
            publishableApiKey: publishableApiKey,
            transactionId: transactionId,
            paymentCodeDisplay: payProvider.paymentCode,
            onClose: () {
              Navigator.of(dialogContext).pop();
              getPaymentMethodsProvider.setPaymentMethod(null);
            },
          ),
        ),
      ),
    ).then((_) {
      getPaymentMethodsProvider.setPaymentMethod(null);
    });
  }
}

/// Triggers the payment method selection bottom sheet on mount.
class _SelectPaymentMethodBottomSheetTrigger extends StatefulWidget {
  const _SelectPaymentMethodBottomSheetTrigger({
    required this.primaryColor,
    required this.onBackPress,
    required this.amountToPay,
    required this.tax,
    required this.totalAmount,
    required this.transactionId,
    required this.onPaymentSuccess,
    required this.isFullPage,
  });

  final Color? primaryColor;
  final VoidCallback? onBackPress;
  final double amountToPay;
  final double tax;
  final double totalAmount;
  final String transactionId;
  final FutureOr<void> Function()? onPaymentSuccess;
  final bool isFullPage;
  @override
  State<_SelectPaymentMethodBottomSheetTrigger> createState() =>
      _SelectPaymentMethodBottomSheetTriggerState();
}

class _SelectPaymentMethodBottomSheetTriggerState
    extends State<_SelectPaymentMethodBottomSheetTrigger> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showBottomSheet());
  }

  void _showBottomSheet() {
    if (!mounted) return;
    final getPaymentMethodsProvider = context.read<GetPaymentMethodsProvider>();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) =>
          ChangeNotifierProvider<GetPaymentMethodsProvider>.value(
        value: getPaymentMethodsProvider,
        child: DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 1,
          builder: (_, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(sheetContext).pop();
                        widget.onBackPress?.call();
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: _SelectPaymentMethodContent(
                    primaryColor: widget.primaryColor,
                    onBackPress: () {
                      Navigator.of(sheetContext).pop();
                      widget.onBackPress?.call();
                    },
                    amountToPay: widget.amountToPay,
                    tax: widget.tax,
                    totalAmount: widget.totalAmount,
                    transactionId: widget.transactionId,
                    onPaymentSuccess: widget.onPaymentSuccess,
                    isFullPage: widget.isFullPage,
                    onClose: () {
                      Navigator.of(sheetContext).pop();
                      widget.onBackPress?.call();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).then((_) {
      widget.onBackPress?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

/// Shows loading until [PayProvider] has payment request, then builds content.
class _DialogWithPayProvider extends StatelessWidget {
  const _DialogWithPayProvider({
    required this.payProvider,
    required this.builder,
  });

  final PayProvider payProvider;
  final Widget Function(dynamic paymentRequest) builder;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final provider = context.watch<PayProvider>();

        if (provider.paymentRequest == null) {
          if (provider.isLoading) {
            return Dialog(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(MoosylLocalization.of(context)?.sending ?? ''),
                  ],
                ),
              ),
            );
          }
          if (provider.error != null) {
            return Dialog(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(provider.error.toString()),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: provider.getPaymentRequest,
                      child: Text(
                          MoosylLocalization.of(context)?.retry ?? 'Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
        }

        return provider.paymentRequest != null
            ? builder(provider.paymentRequest!)
            : const SizedBox.shrink();
      },
    );
  }
}

class _MethodRow extends StatelessWidget {
  const _MethodRow({
    required this.method,
    required this.isSelected,
    required this.primaryColor,
    required this.onTap,
  });

  final ConfigurationListDataInner method;
  final bool isSelected;
  final Color primaryColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GetPaymentMethodsProvider>();
    final localizationHelper = MoosylLocalization.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: AppContainer(
        padding: const EdgeInsetsDirectional.all(10),
        border:
            Border.all(color: isSelected ? primaryColor : Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            // Icon - square bordered
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAlias,
              child: Center(
                child: provider.customIcons?[
                            PaymentMethodTypes.fromString(method.type)] !=
                        null
                    ? AppIcon(
                        path: provider.customIcons?[
                            PaymentMethodTypes.fromString(method.type)],
                        size: 52,
                      )
                    : PaymentMethodTypes.fromString(method.type)
                        .icon
                        .apply(size: 40),
              ),
            ),
            const SizedBox(width: 16),
            // Name + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    PaymentMethodTypes.fromString(method.type).title(context),
                    style: textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isSelected
                        ? localizationHelper.selected
                        : localizationHelper.tapToUse,
                    style: textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            // Radio
            Radio<ConfigurationListDataInner>(
              value: method,
              groupValue: provider.pendingSelection,
              onChanged: (_) => onTap(),
              fillColor: MaterialStateProperty.all(primaryColor),
              activeColor: primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
