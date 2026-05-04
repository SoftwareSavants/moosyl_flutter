import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Base URL for Masrivi payment web view.
const String _masriviPayBaseUrl = 'https://payments.moosyl.com/masrivi/pay';

/// How the Masrivi WebView should be presented.
enum MasriviWebViewPresentation {
  /// Display as a regular full page with an app bar.
  fullPage,

  /// Display as bottom-sheet content with a grab handle.
  bottomSheet,
}

/// Returns an 8-digit local Masrivi phone number, or an empty string if invalid.
String normalizeMasriviPhoneNumberForPrefill(String? phoneNumber) {
  final compactPhoneNumber = phoneNumber
      ?.trim()
      .replaceAll(RegExp(r'[\s().-]'), '')
      .replaceFirst(RegExp(r'^00'), '+');

  if (compactPhoneNumber == null || compactPhoneNumber.isEmpty) return '';

  final localPhoneNumber = compactPhoneNumber.startsWith('+222')
      ? compactPhoneNumber.substring(4)
      : compactPhoneNumber;

  return RegExp(r'^\d{8}$').hasMatch(localPhoneNumber) ? localPhoneNumber : '';
}

/// A view that displays Masrivi payment in a WebView.
///
/// Loads the Masrivi pay URL and listens for navigation to success/decline URLs.
/// When the URL contains "/success", [onPaymentSuccess] is invoked.
/// When the URL contains "/decline", [onPaymentDeclined] is invoked and the view goes back.
class MasriviView extends StatelessWidget {
  /// Creates a new [MasriviView] instance.
  ///
  /// * [publishableApiKey]: The API key for authenticating the payment.
  /// * [transactionId]: The transaction ID for the payment.
  /// * [configurationId]: The configuration ID (payment method ID) from [PaymentMethod.id].
  /// * [onPaymentSuccess]: The callback to call when the payment is successful.
  /// * [onBackPress]: The callback to call when the back button is pressed.
  /// * [onPaymentDeclined]: The callback to call when the payment is declined.
  /// * [presentation]: Whether to render as a full page or bottom sheet.
  /// * [phoneNumber]: Optional phone number to prefill in the Masrivi page.
  const MasriviView({
    super.key,
    required this.publishableApiKey,
    required this.transactionId,
    required this.configurationId,
    this.onPaymentSuccess,
    this.onBackPress,
    this.onPaymentDeclined,
    this.presentation = MasriviWebViewPresentation.fullPage,
    this.bottomSheetHeight = 0.88,
    this.phoneNumber,
  });

  /// The API key for authenticating the payment.
  final String publishableApiKey;

  /// The transaction ID for the payment.
  final String transactionId;

  /// The configuration ID (payment method ID) from [PaymentMethod.id].
  final String configurationId;

  /// Callback when payment is successful (URL contains "/success").
  final FutureOr<void> Function(bool isSuccess)? onPaymentSuccess;

  /// Callback when the back button is pressed.
  final VoidCallback? onBackPress;

  /// Callback when payment is declined (URL contains "/decline").
  /// Called after going back to the payment method list. Use to show an error message.
  final VoidCallback? onPaymentDeclined;

  /// Display as a full page or bottom-sheet content.
  final MasriviWebViewPresentation presentation;

  /// Height factor used by hosts that size the Masrivi bottom sheet.
  final double bottomSheetHeight;

  /// Phone number to prefill in the Masrivi page when a matching input is found.
  final String? phoneNumber;

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
      presentation: presentation,
      bottomSheetHeight: bottomSheetHeight,
      phoneNumber: phoneNumber,
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
    required this.presentation,
    required this.bottomSheetHeight,
    this.phoneNumber,
  });

  final String payUrl;
  final String publishableApiKey;
  final String transactionId;
  final FutureOr<void> Function(bool isSuccess)? onPaymentSuccess;
  final VoidCallback onBackPress;
  final VoidCallback? onPaymentDeclined;
  final MasriviWebViewPresentation presentation;
  final double bottomSheetHeight;
  final String? phoneNumber;

  @override
  State<_MasriviWebView> createState() => _MasriviWebViewState();
}

class _MasriviWebViewState extends State<_MasriviWebView> {
  late final WebViewController _controller;
  bool _outcomeHandled = false;
  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if (_outcomeHandled) return NavigationDecision.prevent;

            if (request.url.contains('/success')) {
              _outcomeHandled = true;
              widget.onBackPress();
              unawaited(_fetchPaymentAndNotify());
              return NavigationDecision.prevent;
            } else if (request.url.contains('/decline')) {
              _outcomeHandled = true;
              widget.onBackPress();
              widget.onPaymentDeclined?.call();
              return NavigationDecision.prevent;
            } else if (request.url.contains('/cancel')) {
              _outcomeHandled = true;
              widget.onBackPress();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageFinished: (_) {
            unawaited(_injectInputScript());
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.payUrl));
  }

  String _buildMasriviInputScript() {
    final phoneValue =
        normalizeMasriviPhoneNumberForPrefill(widget.phoneNumber);

    return '''
    (function () {
  var phoneNumber = ${jsonEncode(phoneValue)};

  function setNativeValue(input, value) {
    var descriptor = Object.getOwnPropertyDescriptor(Object.getPrototypeOf(input), 'value');
    if (descriptor && descriptor.set) {
      descriptor.set.call(input, value);
    } else {
      input.value = value;
    }
    input.dispatchEvent(new Event('input', { bubbles: true }));
    input.dispatchEvent(new Event('change', { bubbles: true }));
  }

  function tryFocus() {
    var input = document.querySelector('input[name="client[number]"]');
    if (!input) return false;
    if (input.readOnly || input.disabled) return false;

    if (phoneNumber && input.value !== phoneNumber) {
      setNativeValue(input, phoneNumber);
    }

    input.click();
    input.focus();
    if (input.setSelectionRange && input.value) {
      var end = input.value.length;
      input.setSelectionRange(end, end);
    }
    return true;
  }

  if (tryFocus()) return;

  var observer = new MutationObserver(function () {
    if (tryFocus()) observer.disconnect();
  });
  observer.observe(document.body, {
    childList: true,
    subtree: true,
    attributes: true,
    attributeFilter: ['readonly', 'disabled']
  });
})();
true;
    ''';
  }

  Future<void> _injectInputScript() async {
    try {
      await _controller.runJavaScript(_buildMasriviInputScript());
    } catch (_) {
      // The page may navigate away before the delayed injection finishes.
    }
  }

  Future<void> _fetchPaymentAndNotify() async {
    final onSuccess = widget.onPaymentSuccess;
    if (onSuccess == null) return;
    try {
      final isSuccess = true;
      await onSuccess(isSuccess);
    } catch (_) {
      await onSuccess(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final webView = WebViewWidget(controller: _controller);

    if (widget.presentation == MasriviWebViewPresentation.bottomSheet) {
      final heightFactor = widget.bottomSheetHeight.clamp(0.2, 1.0).toDouble();

      return LayoutBuilder(
        builder: (context, constraints) {
          final targetHeight =
              MediaQuery.of(context).size.height * heightFactor;
          final maxHeight = constraints.hasBoundedHeight
              ? constraints.maxHeight
              : targetHeight;
          final height = targetHeight.clamp(0.0, maxHeight).toDouble();

          return Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: height,
              width: double.infinity,
              child: Material(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(18)),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD6D6D6),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Expanded(child: webView),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: widget.onBackPress),
      ),
      body: webView,
    );
  }
}
