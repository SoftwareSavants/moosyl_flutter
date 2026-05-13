part of 'payment_methods_view.dart';

/// Data passed to [MoosylPaymentMethodBuilder] for each payment method row.
class MoosylPaymentMethodRenderData {
  /// Creates render data for a payment method row.
  const MoosylPaymentMethodRenderData({
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
  MoosylPaymentMethodRenderData data,
);

/// Data passed to [MoosylPaymentMethodsLoadingBuilder].
class MoosylPaymentMethodsLoadingData {
  /// Creates render data for the payment methods loading state.
  const MoosylPaymentMethodsLoadingData({
    required this.primaryColor,
    required this.locale,
    required this.isRTL,
  });

  /// Accent color used by the default UI.
  final Color primaryColor;

  /// Active locale from the surrounding localization.
  final Locale locale;

  /// Whether the surrounding directionality is RTL.
  final bool isRTL;
}

/// Builds custom loading content for [MoosylPaymentMethods].
typedef MoosylPaymentMethodsLoadingBuilder = Widget Function(
  BuildContext context,
  MoosylPaymentMethodsLoadingData data,
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
    this.loadingComponent,
    this.loadingBuilder,
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

  /// Custom row builder. Call `data.onSelect()` inside the returned widget.
  final MoosylPaymentMethodBuilder? renderMethod;

  /// Custom loading widget shown while payment methods are loading.
  final Widget? loadingComponent;

  /// Custom loading builder shown while payment methods are loading.
  final MoosylPaymentMethodsLoadingBuilder? loadingBuilder;

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
        loadingComponent: loadingComponent,
        loadingBuilder: loadingBuilder,
        showDefaultTitle: showDefaultTitle,
        isMasriviInBottomSheet: isMasriviInBottomSheet,
        masriviPresentation: masriviPresentation,
        masriviPhoneNumber: masriviPhoneNumber,
        masriviBottomSheetHeight: masriviBottomSheetHeight,
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
          loadingComponent: loadingComponent,
          loadingBuilder: loadingBuilder,
          showDefaultTitle: showDefaultTitle,
          isMasriviInBottomSheet: isMasriviInBottomSheet,
          masriviPresentation: masriviPresentation,
          masriviPhoneNumber: masriviPhoneNumber,
          masriviBottomSheetHeight: masriviBottomSheetHeight,
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
    required this.loadingComponent,
    required this.loadingBuilder,
    required this.showDefaultTitle,
    required this.isMasriviInBottomSheet,
    required this.masriviPresentation,
    required this.masriviPhoneNumber,
    required this.masriviBottomSheetHeight,
  });

  final String? selectedMethodId;
  final ValueChanged<ConfigurationListDataInner>? onSelectMethod;
  final FutureOr<void> Function(bool isSuccess)? onPaymentSuccess;
  final ValueChanged<Object>? onPaymentError;
  final ValueChanged<bool>? onContinueLoadingChange;
  final MoosylPaymentMethodsController? controller;
  final Color? primaryColor;
  final MoosylPaymentMethodBuilder? renderMethod;
  final Widget? loadingComponent;
  final MoosylPaymentMethodsLoadingBuilder? loadingBuilder;
  final bool showDefaultTitle;
  final bool isMasriviInBottomSheet;
  final MasriviWebViewPresentation masriviPresentation;
  final String? masriviPhoneNumber;
  final double masriviBottomSheetHeight;

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
      final loadingData = MoosylPaymentMethodsLoadingData(
        primaryColor: primaryColor,
        locale: Localizations.localeOf(context),
        isRTL: isRTL,
      );
      final loadingContent = widget.loadingBuilder?.call(
            context,
            loadingData,
          ) ??
          widget.loadingComponent ??
          _PaymentMethodsLoadingSkeleton(
            isRTL: isRTL,
            showTitle: widget.showDefaultTitle,
          );

      return widget.renderMethod == null
          ? AppContainer(child: loadingContent)
          : loadingContent;
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
      children: [
        if (widget.renderMethod == null && widget.showDefaultTitle) ...[
          Text(
            localizationHelper.chooseHowYouWouldLikeToPay,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
        ],
        ...provider.methods.map((method) {
          final type = PaymentMethodTypes.fromString(method.type);
          final isSelected = selectedId == method.id;
          final methodData = MoosylPaymentMethodRenderData(
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
            return widget.renderMethod!(context, methodData);
          }

          return _MethodRow(
            method: method,
            isSelected: isSelected,
            onTap: methodData.onSelect,
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

    return widget.renderMethod == null ? AppContainer(child: content) : content;
  }
}

class _PaymentMethodsLoadingSkeleton extends StatelessWidget {
  const _PaymentMethodsLoadingSkeleton({
    required this.isRTL,
    required this.showTitle,
  });

  final bool isRTL;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final localizationHelper = MoosylLocalization.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showTitle && localizationHelper != null) ...[
            Text(
              localizationHelper.chooseHowYouWouldLikeToPay,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
          ],
          ...List.generate(
            3,
            (_) => const _PaymentMethodsLoadingSkeletonRow(),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodsLoadingSkeletonRow extends StatelessWidget {
  const _PaymentMethodsLoadingSkeletonRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFEDF3FF)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            _LoadingShimmerBlock(
              width: 48,
              height: 48,
              borderRadius: BorderRadius.circular(6),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: FractionallySizedBox(
                  widthFactor: 0.68,
                  alignment: AlignmentDirectional.centerStart,
                  child: _LoadingShimmerBlock(
                    height: 18,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            _LoadingShimmerBlock(
              width: 20,
              height: 20,
              borderRadius: BorderRadius.circular(9),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingShimmerBlock extends StatelessWidget {
  const _LoadingShimmerBlock({
    required this.height,
    required this.borderRadius,
    this.width,
  });

  final double? width;
  final double height;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Shimmer.fromColors(
        baseColor: const Color(0xFFECEFF1),
        highlightColor: const Color.fromRGBO(255, 255, 255, 0.55),
        child: ColoredBox(
          color: Colors.white,
          child: SizedBox(width: width, height: height),
        ),
      ),
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
    final textTheme = Theme.of(context).textTheme;
    final effectivePrimary =
        primaryColor ?? Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(end: isSelected ? 1 : 0),
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                top: -2,
                right: -2,
                bottom: -2,
                left: -2,
                child: IgnorePointer(
                  child: Transform.scale(
                    scale: 0.98 + (0.02 * value),
                    child: Opacity(
                      opacity: value,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: effectivePrimary,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Transform.scale(
                scale: 1 - (0.0005 * value),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    splashColor: Colors.transparent,
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFFEDF3FF)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F8FB),
                              border: Border.all(
                                color: const Color(0xFFEDF3FF),
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Center(
                              child: PaymentMethodTypes.fromString(method.type)
                                  .icon
                                  .apply(size: 40),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: Text(
                                PaymentMethodTypes.fromString(method.type)
                                    .title(context),
                                style: textTheme.titleMedium?.copyWith(
                                  color: const Color(0xFF111111),
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Padding(
                            padding: const EdgeInsetsDirectional.only(end: 12),
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: effectivePrimary,
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Transform.scale(
                                  scale: 0.4 + (0.6 * value),
                                  child: Opacity(
                                    opacity: value,
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: effectivePrimary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
