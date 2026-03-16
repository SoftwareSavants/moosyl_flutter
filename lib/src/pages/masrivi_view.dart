import 'dart:async';

import 'package:flutter/material.dart';
import 'package:moosyl_flutter/src/models/payment_success.dart';
import 'package:moosyl_flutter/src/services/get_payment_request_service.dart';
import 'package:moosyl_flutter/src/services/pay_service.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Base URL for Masrivi payment web view.
const String _masriviPayBaseUrl = 'https://payments.moosyl.com/masrivi/pay';

/// A view that displays Masrivi payment in a WebView.
///
/// Loads the Masrivi pay URL and listens for navigation to success/decline URLs.
/// When the URL contains "/success", [onPaymentSuccess] is invoked.
/// When the URL contains "/decline", [onPaymentDeclined] is invoked and the view goes back.
class MasriviView extends StatelessWidget {
  const MasriviView({
    super.key,
    required this.publishableApiKey,
    required this.transactionId,
    required this.configurationId,
    this.onPaymentSuccess,
    this.onBackPress,
    this.onPaymentDeclined,
  });

  /// The API key for authenticating the payment.
  final String publishableApiKey;

  /// The transaction ID for the payment.
  final String transactionId;

  /// The configuration ID (payment method ID) from [PaymentMethod.id].
  final String configurationId;

  /// Callback when payment is successful (URL contains "/success").
  final FutureOr<void> Function(PaymentSuccess payment)? onPaymentSuccess;

  /// Callback when the back button is pressed.
  final VoidCallback? onBackPress;

  /// Callback when payment is declined (URL contains "/decline").
  /// Called after going back to the payment method list. Use to show an error message.
  final VoidCallback? onPaymentDeclined;

  /// Builds the Masrivi pay URL with query parameters.
  String get _payUrl {
    final uri = Uri.parse(_masriviPayBaseUrl).replace(
      queryParameters: {
        'apiKey': publishableApiKey,
        'transactionId': transactionId,
        'configurationId': configurationId,
      },
    );
    return uri.toString();
  }

  @override
  Widget build(BuildContext context) {
    return _MasriviWebView(
      payUrl: _payUrl,
      publishableApiKey: publishableApiKey,
      transactionId: transactionId,
      onPaymentSuccess: onPaymentSuccess,
      onBackPress: onBackPress ?? () => Navigator.of(context).pop(),
      onPaymentDeclined: onPaymentDeclined,
    );
  }
}

class _MasriviWebView extends StatefulWidget {
  const _MasriviWebView({
    required this.payUrl,
    required this.publishableApiKey,
    required this.transactionId,
    this.onPaymentSuccess,
    required this.onBackPress,
    this.onPaymentDeclined,
  });

  final String payUrl;
  final String publishableApiKey;
  final String transactionId;
  final FutureOr<void> Function(PaymentSuccess payment)? onPaymentSuccess;
  final VoidCallback onBackPress;
  final VoidCallback? onPaymentDeclined;

  @override
  State<_MasriviWebView> createState() => _MasriviWebViewState();
}

class _MasriviWebViewState extends State<_MasriviWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.contains('/success')) {
              widget.onBackPress();
              _fetchPaymentAndNotify();
              return NavigationDecision.prevent;
            } else if (request.url.contains('/decline')) {
              widget.onBackPress();
              widget.onPaymentDeclined?.call();
              return NavigationDecision.prevent;
            } else if (request.url.contains('/cancel')) {
              widget.onBackPress();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.payUrl));
  }

  Future<void> _fetchPaymentAndNotify() async {
    final onSuccess = widget.onPaymentSuccess;
    if (onSuccess == null) return;
    try {
      final paymentData =
          await GetPaymentRequestService(widget.publishableApiKey)
              .get(widget.transactionId);
      final payment = PaymentSuccess.fromPaymentRequestGetData(paymentData);
      await onSuccess(payment);
    } catch (_) {
      await onSuccess(PaymentSuccess(
        id: widget.transactionId,
        amount: 0,
        status: 'completed',
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: widget.onBackPress),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
