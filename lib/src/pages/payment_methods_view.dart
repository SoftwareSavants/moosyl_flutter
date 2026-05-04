import 'dart:async';

import 'package:flutter/material.dart';
import 'package:moosyl/moosyl.dart';
import 'package:moosyl_flutter/l10n/generated/moosyl_localization.dart';
import 'package:moosyl_flutter/src/helpers/exception_handling/exception_mapper.dart';
import 'package:moosyl_flutter/src/models/payment_method_model.dart';
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

/// Data passed to [MoosylPaymentMethodBuilder] for each payment method row.
class MoosylPaymentMethodRenderProps {
  /// Creates render props for a payment method row.
  const MoosylPaymentMethodRenderProps({
    required this.method,
    required this.type,
    required this.title,
    required this.isSelected,
    required this.selectedMethodId,
    required this.isRTL,
    required this.onSelect,
  });

  /// Raw method from the Moosyl Dart SDK.
  final ConfigurationListDataInner method;

  /// Parsed payment method type.
  final PaymentMethodTypes type;

  /// Localized method title.
  final String title;

  /// Whether this method is selected.
  final bool isSelected;

  /// Currently selected method id, if any.
  final String? selectedMethodId;

  /// Whether the surrounding directionality is RTL.
  final bool isRTL;

  /// Selects this method.
  final VoidCallback onSelect;
}

/// Builds a custom payment method row.
typedef MoosylPaymentMethodBuilder = Widget Function(
  BuildContext context,
  MoosylPaymentMethodRenderProps props,
);

/// Controller for [MoosylPaymentMethods].
class MoosylPaymentMethodsController extends ChangeNotifier {
  _MoosylPaymentMethodsContentState? _state;

  void _attach(_MoosylPaymentMethodsContentState state) {
    _state = state;
  }

  void _detach(_MoosylPaymentMethodsContentState state) {
    if (_state == state) {
      _state = null;
    }
  }

  /// Continues with the currently selected payment method.
  Future<void> continuePayment() async {
    await _state?._continuePayment();
  }

  /// Returns the currently selected method, if mounted and selected.
  ConfigurationListDataInner? get selectedMethod => _state?._selectedMethod;

  void _selectionDidChange() {
    notifyListeners();
  }
}

/// Standalone payment method picker that can be embedded in custom checkout UI.
///
/// Use [controller] to trigger [MoosylPaymentMethodsController.continuePayment]
/// from a button owned by your screen.
class MoosylPaymentMethods extends StatelessWidget {
  /// Creates a reusable payment method picker.
  const MoosylPaymentMethods({
    super.key,
    required this.publishableApiKey,
    this.transactionId,
    this.amountToPay = 0.0,
    this.tax = 0.0,
    this.totalAmount,
    this.selectedMethodId,
    this.onSelectMethod,
    this.onPaymentSuccess,
    this.onPaymentError,
    this.onContinueLoadingChange,
    this.controller,
    this.primaryColor,
    this.renderMethod,
    this.showDefaultTitle = true,
    this.isMasriviInBottomSheet = true,
    this.masriviPresentation = MasriviWebViewPresentation.fullPage,
    this.masriviPhoneNumber,
    this.masriviBottomSheetHeight = 0.88,
  });

  /// Publishable API key used to load payment methods.
  final String publishableApiKey;

  /// Transaction id used by [MoosylPaymentMethodsController.continuePayment].
  final String? transactionId;

  /// Amount to pay, used for validation when continuing.
  final double amountToPay;

  /// Tax amount, used with [amountToPay] when [totalAmount] is not supplied.
  final double tax;

  /// Total expected amount. Defaults to [amountToPay] + [tax].
  final double? totalAmount;

  /// Controlled selected method id.
  final String? selectedMethodId;

  /// Called whenever a method is selected.
  final ValueChanged<ConfigurationListDataInner>? onSelectMethod;

  /// Called when payment succeeds.
  final FutureOr<void> Function(bool isSuccess)? onPaymentSuccess;

  /// Called when continuing fails.
  final ValueChanged<Object>? onPaymentError;

  /// Called when continuePayment starts or finishes.
  final ValueChanged<bool>? onContinueLoadingChange;

  /// Controller used by host UI to continue payment.
  final MoosylPaymentMethodsController? controller;

  /// Accent color for the default rows and dialogs.
  final Color? primaryColor;

  /// Custom row builder. Call `props.onSelect()` inside the returned widget.
  final MoosylPaymentMethodBuilder? renderMethod;

  /// Whether the default UI should include the section title.
  final bool showDefaultTitle;

  /// When true, Masrivi opens inside a bottom sheet from custom platform UIs.
  final bool isMasriviInBottomSheet;

  /// How Masrivi should be presented when this picker opens the WebView.
  final MasriviWebViewPresentation masriviPresentation;

  /// Optional phone number to prefill when the selected method opens Masrivi.
  final String? masriviPhoneNumber;

  /// Height factor used when Masrivi is rendered as bottom-sheet content.
  final double masriviBottomSheetHeight;

  @override
  Widget build(BuildContext context) {
    try {
      context.read<GetPaymentMethodsProvider>();
      return _MoosylPaymentMethodsContent(
        selectedMethodId: selectedMethodId,
        onSelectMethod: onSelectMethod,
        onPaymentSuccess: onPaymentSuccess,
        onPaymentError: onPaymentError,
        onContinueLoadingChange: onContinueLoadingChange,
        controller: controller,
        primaryColor: primaryColor,
        renderMethod: renderMethod,
        showDefaultTitle: showDefaultTitle,
        isMasriviInBottomSheet: isMasriviInBottomSheet,
        masriviPresentation: masriviPresentation,
        masriviPhoneNumber: masriviPhoneNumber,
        masriviBottomSheetHeight: masriviBottomSheetHeight,
        ownsProvider: false,
      );
    } on ProviderNotFoundException catch (_) {
      return ChangeNotifierProvider(
        create: (_) => GetPaymentMethodsProvider(
          publishableApiKey: publishableApiKey,
          transactionId: transactionId ?? '',
          totalAmount: totalAmount ?? amountToPay + tax,
        ),
        child: _MoosylPaymentMethodsContent(
          selectedMethodId: selectedMethodId,
          onSelectMethod: onSelectMethod,
          onPaymentSuccess: onPaymentSuccess,
          onPaymentError: onPaymentError,
          onContinueLoadingChange: onContinueLoadingChange,
          controller: controller,
          primaryColor: primaryColor,
          renderMethod: renderMethod,
          showDefaultTitle: showDefaultTitle,
          isMasriviInBottomSheet: isMasriviInBottomSheet,
          masriviPresentation: masriviPresentation,
          masriviPhoneNumber: masriviPhoneNumber,
          masriviBottomSheetHeight: masriviBottomSheetHeight,
          ownsProvider: true,
        ),
      );
    }
  }
}

class _MoosylPaymentMethodsContent extends StatefulWidget {
  const _MoosylPaymentMethodsContent({
    required this.selectedMethodId,
    required this.onSelectMethod,
    required this.onPaymentSuccess,
    required this.onPaymentError,
    required this.onContinueLoadingChange,
    required this.controller,
    required this.primaryColor,
    required this.renderMethod,
    required this.showDefaultTitle,
    required this.isMasriviInBottomSheet,
    required this.masriviPresentation,
    required this.masriviPhoneNumber,
    required this.masriviBottomSheetHeight,
    required this.ownsProvider,
  });

  final String? selectedMethodId;
  final ValueChanged<ConfigurationListDataInner>? onSelectMethod;
  final FutureOr<void> Function(bool isSuccess)? onPaymentSuccess;
  final ValueChanged<Object>? onPaymentError;
  final ValueChanged<bool>? onContinueLoadingChange;
  final MoosylPaymentMethodsController? controller;
  final Color? primaryColor;
  final MoosylPaymentMethodBuilder? renderMethod;
  final bool showDefaultTitle;
  final bool isMasriviInBottomSheet;
  final MasriviWebViewPresentation masriviPresentation;
  final String? masriviPhoneNumber;
  final double masriviBottomSheetHeight;
  final bool ownsProvider;

  @override
  State<_MoosylPaymentMethodsContent> createState() =>
      _MoosylPaymentMethodsContentState();
}

class _MoosylPaymentMethodsContentState
    extends State<_MoosylPaymentMethodsContent> {
  String? _continueError;

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(this);
  }

  @override
  void didUpdateWidget(covariant _MoosylPaymentMethodsContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach(this);
      widget.controller?._attach(this);
    }
  }

  @override
  void dispose() {
    widget.controller?._detach(this);
    super.dispose();
  }

  ConfigurationListDataInner? get _selectedMethod {
    final provider = context.read<GetPaymentMethodsProvider>();
    final selectedId = widget.selectedMethodId ?? provider.pendingSelection?.id;
    for (final method in provider.methods) {
      if (method.id == selectedId) {
        return method;
      }
    }
    return null;
  }

  Future<void> _continuePayment() async {
    final provider = context.read<GetPaymentMethodsProvider>();
    final pendingSelection = _selectedMethod;
    final transactionId = provider.transactionId;

    if (pendingSelection == null) {
      return;
    }

    if (transactionId.isEmpty) {
      setState(() {
        _continueError = 'Transaction ID is required to continue payment.';
      });
      return;
    }

    setState(() {
      _continueError = null;
    });
    widget.onContinueLoadingChange?.call(true);

    try {
      final methodToShow =
          await provider.setPaymentMethodWithValidation(pendingSelection);
      if (!mounted) return;

      if (methodToShow == null) {
        final selected = provider.selected;
        if (selected == null) {
          return;
        }

        final masriviPresentation = widget.isMasriviInBottomSheet
            ? MasriviWebViewPresentation.bottomSheet
            : widget.masriviPresentation;

        final masriviView = MasriviView(
          publishableApiKey: provider.publishableApiKey,
          transactionId: provider.transactionId,
          configurationId: selected.id,
          onPaymentSuccess: widget.onPaymentSuccess,
          onBackPress: () => Navigator.of(context).pop(),
          presentation: masriviPresentation,
          bottomSheetHeight: widget.masriviBottomSheetHeight,
          phoneNumber:
              widget.masriviPhoneNumber ?? provider.paymentRequest?.phoneNumber,
        );

        if (masriviPresentation == MasriviWebViewPresentation.bottomSheet) {
          await showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => masriviView,
          );
        } else {
          await Navigator.of(context).push<void>(
            MaterialPageRoute(builder: (_) => masriviView),
          );
        }

        if (mounted) {
          provider.setPaymentMethod(null);
        }
        return;
      }

      final primaryColor =
          widget.primaryColor ?? Theme.of(context).colorScheme.primary;
      await _showPaymentDialogForMethod(
        context,
        publishableApiKey: provider.publishableApiKey,
        transactionId: provider.transactionId,
        method: methodToShow,
        primaryColor: primaryColor,
        onPaymentSuccess: widget.onPaymentSuccess,
      );
    } catch (error) {
      widget.onPaymentError?.call(error);
      if (mounted) {
        setState(() {
          _continueError = error.toString();
        });
      }
    } finally {
      widget.onContinueLoadingChange?.call(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GetPaymentMethodsProvider>();
    final localizationHelper = MoosylLocalization.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final primaryColor =
        widget.primaryColor ?? Theme.of(context).colorScheme.primary;
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    if (provider.isLoading) {
      return AppContainer(
        padding: const EdgeInsets.all(24),
        border: widget.renderMethod == null
            ? Border.all(color: Colors.grey.shade300)
            : null,
        borderRadius: BorderRadius.circular(8),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: primaryColor),
              const SizedBox(height: 12),
              Text(localizationHelper.sending),
            ],
          ),
        ),
      );
    }

    if (provider.error != null) {
      final error = provider.error!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onPaymentError?.call(error);
      });
      return AppErrorWidget(
        message: ExceptionMapper.getErrorMessage(error, context),
        onRetry: provider.getMethods,
      );
    }

    if (provider.methods.isEmpty) {
      return AppContainer(
        padding: const EdgeInsets.all(24),
        border: widget.renderMethod == null
            ? Border.all(color: Colors.grey.shade300)
            : null,
        borderRadius: BorderRadius.circular(8),
        child: Text(
          localizationHelper.paymentMethod,
          textAlign: TextAlign.center,
        ),
      );
    }

    final selectedId = widget.selectedMethodId ?? provider.pendingSelection?.id;
    final selectionErrorMessage = provider.selectionError != null
        ? SelectionErrorType.fromStr(provider.selectionError!)
            .message(localizationHelper)
        : null;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      spacing: 10,
      children: [
        if (widget.renderMethod == null && widget.showDefaultTitle) ...[
          Text(
            localizationHelper.chooseHowYouWouldLikeToPay,
            style: textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600, fontSize: 18),
          ),
        ],
        ...provider.methods.map((method) {
          final type = PaymentMethodTypes.fromString(method.type);
          final isSelected = selectedId == method.id;
          final props = MoosylPaymentMethodRenderProps(
            method: method,
            type: type,
            title: type.title(context),
            isSelected: isSelected,
            selectedMethodId: selectedId,
            isRTL: isRTL,
            onSelect: () {
              if (widget.selectedMethodId == null) {
                provider.setPendingSelection(method);
              }
              widget.onSelectMethod?.call(method);
              widget.controller?._selectionDidChange();
            },
          );

          if (widget.renderMethod != null) {
            return widget.renderMethod!(context, props);
          }

          return _MethodRow(
            method: method,
            isSelected: isSelected,
            onTap: props.onSelect,
            primaryColor: primaryColor,
          );
        }),
        if (selectionErrorMessage != null || _continueError != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              selectionErrorMessage ?? _continueError!,
              style: textTheme.bodyMedium?.copyWith(color: Colors.red),
            ),
          ),
      ],
    );

    if (widget.renderMethod != null) {
      return content;
    }

    return AppContainer(
      // padding: const EdgeInsets.all(16),
      // border: Border.all(color: Colors.grey.shade300),
      // borderRadius: BorderRadius.circular(8),
      child: content,
    );
  }
}

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
    this.amountToPay = 0.0,
    this.tax = 0.0,
    this.totalAmount = 0.0,
    required this.transactionId,
    this.onPaymentSuccess,
    required this.isFullPage,
  });

  /// When true, shows as full page. When false, shows as bottom sheet.
  final bool isFullPage;

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
  final FutureOr<void> Function(bool isSuccess)? onPaymentSuccess;

  @override
  Widget build(BuildContext context) {
    return _SelectPaymentMethodContent(
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

/// Full page or bottom sheet content for payment method selection.
class _SelectPaymentMethodContent extends StatelessWidget {
  const _SelectPaymentMethodContent({
    required this.onBackPress,
    required this.amountToPay,
    required this.tax,
    required this.totalAmount,
    required this.transactionId,
    required this.onPaymentSuccess,
    required this.isFullPage,
  });

  final VoidCallback? onBackPress;
  final double amountToPay;
  final double tax;
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
        ? SelectionErrorType.fromStr(provider.selectionError!)
            .message(localizationHelper)
        : null;

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
                  MoosylPaymentMethods(
                    publishableApiKey: provider.publishableApiKey,
                    transactionId: provider.transactionId,
                    amountToPay: amountToPay,
                    tax: tax,
                    totalAmount: totalAmount,
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
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          leadingWidth: onBackPress != null ? 48 : 0,
          titleSpacing: onBackPress != null ? 0 : 16,
          title: Text(
            localizationHelper.choosePaymentMethods,
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
      // Masrivi etc: provider.selected is set, MoosylView will show the method's view.
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
      onPaymentSuccess: (payment) async =>
          await onPaymentSuccess?.call(payment),
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
  }) {
    final payProvider = PayProvider(
      publishableApiKey: publishableApiKey,
      transactionId: transactionId,
      method: method,
      onPaymentSuccess: (payment) async =>
          await onPaymentSuccess?.call(payment),
    );
    final getPaymentMethodsProvider = context.read<GetPaymentMethodsProvider>();

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
            builder: (_) => BankilyView(
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
        );
      },
    ).then((_) {
      getPaymentMethodsProvider.setPaymentMethod(null);
    });
  }
}

Future<void> _showPaymentDialogForMethod(
  BuildContext context, {
  required String publishableApiKey,
  required String transactionId,
  required ConfigurationListDataInner method,
  required Color primaryColor,
  required FutureOr<void> Function(bool isSuccess)? onPaymentSuccess,
}) async {
  if (PaymentMethodTypes.fromString(method.type) ==
      PaymentMethodTypes.bankily) {
    _showBankilyPaymentDialog(
      context,
      publishableApiKey: publishableApiKey,
      transactionId: transactionId,
      method: method,
      onPaymentSuccess: onPaymentSuccess,
    );
  } else if (PaymentMethodTypes.fromString(method.type) ==
          PaymentMethodTypes.sedad ||
      PaymentMethodTypes.fromString(method.type) ==
          PaymentMethodTypes.bimBank) {
    await _showSedadPaymentDialog(
      context,
      publishableApiKey: publishableApiKey,
      transactionId: transactionId,
      method: method,
      primaryColor: primaryColor,
      onPaymentSuccess: onPaymentSuccess,
    );
  }
}

Future<void> _showSedadPaymentDialog(
  BuildContext context, {
  required String publishableApiKey,
  required String transactionId,
  required ConfigurationListDataInner method,
  required Color primaryColor,
  required FutureOr<void> Function(bool isSuccess)? onPaymentSuccess,
}) async {
  final payProvider = PayProvider(
    publishableApiKey: publishableApiKey,
    transactionId: transactionId,
    method: method,
    onPaymentSuccess: (payment) async => await onPaymentSuccess?.call(payment),
  );
  final getPaymentMethodsProvider = context.read<GetPaymentMethodsProvider>();

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => const Center(
      child: CircularProgressIndicator(),
    ),
  );

  final paymentCode = await payProvider.getPaymentCodeForSedad();

  if (context.mounted) {
    Navigator.of(context).pop();
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

void _showBankilyPaymentDialog(
  BuildContext context, {
  required String publishableApiKey,
  required String transactionId,
  required ConfigurationListDataInner method,
  required FutureOr<void> Function(bool isSuccess)? onPaymentSuccess,
}) {
  final payProvider = PayProvider(
    publishableApiKey: publishableApiKey,
    transactionId: transactionId,
    method: method,
    onPaymentSuccess: (payment) async => await onPaymentSuccess?.call(payment),
  );
  final getPaymentMethodsProvider = context.read<GetPaymentMethodsProvider>();

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
          builder: (_) => BankilyView(
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
      );
    },
  ).then((_) {
    getPaymentMethodsProvider.setPaymentMethod(null);
  });
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
    required this.onTap,
    this.primaryColor,
  });

  final ConfigurationListDataInner method;
  final bool isSelected;

  final VoidCallback onTap;
  final Color? primaryColor;

  @override
  Widget build(BuildContext context) {
    final localizationHelper = MoosylLocalization.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final effectivePrimary =
        primaryColor ?? Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: onTap,
      child: AppContainer(
        padding: const EdgeInsetsDirectional.all(10),
        border: Border.all(
          color: isSelected ? effectivePrimary : Colors.grey.shade300,
        ),
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
                child: PaymentMethodTypes.fromString(method.type)
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
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: effectivePrimary,
                  width: isSelected ? 2 : 1.5,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: effectivePrimary,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
