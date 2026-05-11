part of 'payment_methods_view.dart';

Future<void> _showPaymentDialogForMethod(
  BuildContext context, {
  required String publishableApiKey,
  required String transactionId,
  required ConfigurationListDataInner method,
  required Color primaryColor,
  required FutureOr<void> Function(bool isSuccess)? onPaymentSuccess,
}) async {
  final type = PaymentMethodTypes.fromString(method.type);

  if (type == PaymentMethodTypes.bankily) {
    _showBankilyDialog(
      context,
      publishableApiKey: publishableApiKey,
      transactionId: transactionId,
      method: method,
      onPaymentSuccess: onPaymentSuccess,
    );
  } else if (type == PaymentMethodTypes.sedad ||
      type == PaymentMethodTypes.bimBank) {
    await _showSedadDialog(
      context,
      publishableApiKey: publishableApiKey,
      transactionId: transactionId,
      method: method,
      onPaymentSuccess: onPaymentSuccess,
    );
  }
}

Future<void> _showSedadDialog(
  BuildContext context, {
  required String publishableApiKey,
  required String transactionId,
  required ConfigurationListDataInner method,
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
    builder: (_) => const Center(
      child: CircularProgressIndicator(),
    ),
  );

  final paymentCode = await payProvider.getPaymentCodeForSedad();

  if (context.mounted) {
    Navigator.of(context).pop();
  }
  if (!context.mounted) return;

  if (paymentCode == null || paymentCode.isEmpty) {
    if (payProvider.error != null) {
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
                      child:
                          Text(MoosylLocalization.of(context)?.retry ?? ''),
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
