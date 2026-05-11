import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show NumberFormat;
import 'package:moosyl/moosyl.dart';
import 'package:moosyl_flutter/l10n/generated/moosyl_localization.dart';
import 'package:moosyl_flutter/src/helpers/exception_handling/exception_mapper.dart';
import 'package:moosyl_flutter/src/models/payment_method_model.dart';
import 'package:moosyl_flutter/src/models/payment_summary_item.dart';
import 'package:moosyl_flutter/src/models/selection_error.dart';
import 'package:moosyl_flutter/src/pages/bankily_view.dart';
import 'package:moosyl_flutter/src/pages/masrivi_view.dart';
import 'package:moosyl_flutter/src/pages/sedad_view.dart';
import 'package:moosyl_flutter/src/providers/get_payment_methods_provider.dart';
import 'package:moosyl_flutter/src/providers/pay_provider.dart';
import 'package:moosyl_flutter/src/widgets/buttons.dart';
import 'package:moosyl_flutter/src/widgets/container.dart';
import 'package:moosyl_flutter/src/widgets/error_widget.dart';
import 'package:moosyl_flutter/src/widgets/feedback.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

part 'payment_dialogs.dart';
part 'payment_methods.dart';
part 'payment_summary.dart';

/// A widget that displays the available payment methods for selection.
///
/// This widget allows users to choose a payment method from a list of options.
/// Each row shows an icon, name, and radio indicator. A pay button at the bottom
/// confirms the selection and proceeds to payment.
class SelectPaymentMethodPage extends StatelessWidget {
  /// Creates an instance of [SelectPaymentMethodPage].
  const SelectPaymentMethodPage({
    super.key,
    this.onBackPress,
    this.items,
    this.totalAmount = 0.0,
    required this.transactionId,
    this.onPaymentSuccess,
    required this.isFullPage,
  });

  /// When true, shows as full page. When false, shows as bottom sheet.
  final bool isFullPage;

  /// Callback when the back arrow is pressed.
  final VoidCallback? onBackPress;

  /// Summary rows displayed under the payment methods.
  final List<MoosylPaymentSummaryItem>? items;

  /// The expected total amount from [items].
  final double totalAmount;

  /// The transaction ID (displayed in the payment request).
  final String transactionId;

  /// Callback when payment succeeds (for Sedad/Bankily dialogs).
  final FutureOr<void> Function(bool isSuccess)? onPaymentSuccess;

  @override
  Widget build(BuildContext context) {
    return _SelectPaymentMethodContent(
      onBackPress: onBackPress,
      items: items,
      totalAmount: totalAmount,
      transactionId: transactionId,
      onPaymentSuccess: onPaymentSuccess,
      isFullPage: isFullPage,
    );
  }
}

class _SelectPaymentMethodContent extends StatelessWidget {
  const _SelectPaymentMethodContent({
    required this.onBackPress,
    required this.items,
    required this.totalAmount,
    required this.transactionId,
    required this.onPaymentSuccess,
    required this.isFullPage,
  });

  final VoidCallback? onBackPress;
  final List<MoosylPaymentSummaryItem>? items;
  final double totalAmount;
  final String transactionId;
  final FutureOr<void> Function(bool isSuccess)? onPaymentSuccess;
  final bool isFullPage;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GetPaymentMethodsProvider>();
    final effectivePrimary = Theme.of(context).colorScheme.primary;
    final localizationHelper = MoosylLocalization.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    if (provider.error != null) {
      final errorView = AppErrorWidget(
        message: ExceptionMapper.getErrorMessage(provider.error, context),
        onRetry: provider.getMethods,
      );
      return isFullPage
          ? errorView
          : ColoredBox(
              color: Colors.white,
              child: errorView,
            );
    }

    final selectionErrorMessage = provider.selectionError != null
        ? SelectionErrorType.fromStr(provider.selectionError!)
            .message(localizationHelper)
        : null;
    final pendingSelection = provider.pendingSelection;
    final summaryItems = items ?? const <MoosylPaymentSummaryItem>[];
    final shouldShowSummary = items != null;
    final displayTotal = provider.paymentRequest?.amount ??
        (totalAmount > 0 ? totalAmount : _calculateSummaryTotal(summaryItems));
    final displayTotalText = '${_formatAmount(displayTotal)} MRU';

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
                  MoosylPaymentMethods(
                    publishableApiKey: provider.publishableApiKey,
                    transactionId: provider.transactionId,
                    totalAmount: totalAmount,
                    showDefaultTitle: !isFullPage,
                  ),
                ],
              ),
            ),
          ),
          if (!provider.isLoading)
            SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (selectionErrorMessage != null)
                    Text(
                      selectionErrorMessage,
                      style: textTheme.bodyMedium?.copyWith(color: Colors.red),
                    ),
                  const SizedBox(height: 16),
                  if (shouldShowSummary)
                    _PaymentSummary(
                      items: summaryItems,
                      totalText: displayTotalText,
                      localization: localizationHelper,
                    ),
                  AppButton(
                    minHeight: 60,
                    borderRadius: BorderRadius.circular(18),
                    labelText: provider.isValidating
                        ? localizationHelper.sending
                        : localizationHelper.pay,
                    suffixLabelText: displayTotalText,
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
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          leadingWidth: onBackPress != null ? 48 : 0,
          titleSpacing: onBackPress != null ? 0 : 16,
          title: Text(
            localizationHelper.chooseHowYouWouldLikeToPay,
            style: textTheme.titleMedium?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
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

    return ColoredBox(
      color: Colors.white,
      child: bodyContent,
    );
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
    if (!context.mounted || methodToShow == null) {
      return;
    }

    await _showPaymentDialogForMethod(
      context,
      publishableApiKey: provider.publishableApiKey,
      transactionId: provider.transactionId,
      method: methodToShow,
      primaryColor: effectivePrimary,
      onPaymentSuccess: onPaymentSuccess,
    );
  }
}
