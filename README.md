# Moosyl Flutter SDK

[![Pub Version](https://img.shields.io/pub/v/moosyl_flutter.svg)](https://pub.dev/packages/moosyl_flutter)  
The **Moosyl Flutter SDK** is a powerful tool for integrating payment solutions with Mauritania's popular banking apps, such as **Bankily**, **Sedad**, and **Masrivi**. Simplify the payment process in your Flutter applications with features like webhooks and an easy-to-use interface.

---

## 🌟 Features

- **Seamless Integration**: Easily connect with local banking apps.
- **Customizable**: Adapt the payment UI with flexible options.
- **Webhook Support**: Enable real-time payment status updates.
- **Localization**: Built-in support for multiple languages and locales.
- **Cross-Platform**: Fully compatible with iOS, Android, and the web.
- **Multi-Platform Readiness**: While not extensively tested, the package should theoretically work on **Linux**, **MacOS**, and **Windows** as well.

---

## 🚀 Getting Started

### Installation

Add the **Moosyl Flutter** package to your `pubspec.yaml`:

```yaml
dependencies:
  moosyl_flutter: ^latest_version
```

Fetch the package:

```bash
flutter pub get
```

### Import the Package

```dart
import 'package:moosyl_flutter/moosyl.dart';
```

---

## 📘 Usage

### Step 1: Create a Payment Request

Before displaying the payment interface in your Flutter app, you need to create a payment request from your backend using the Moosyl API. Use your **secret API key** to authenticate the request. Here's how to do it:

#### cURL Example:

```bash
curl -X POST https://api.moosyl.com/payment-request \
-H "Authorization: YOUR_SECRET_API_KEY" \
-H "Content-Type: application/json" \
-d '{
  "phoneNumber": "+22212345678",
  "transactionId": "your-unique-transaction-id",
  "amount": 5000
}'
```

---

### Step 2: Register Localization

Before displaying the payment UI, make sure your `MaterialApp` registers the Moosyl localization delegates and supported locales:

```dart
return MaterialApp(
  localizationsDelegates: MoosylLocalization.localizationsDelegates,
  supportedLocales: MoosylLocalization.supportedLocales,
  locale: const Locale('en'), // Optional: use the device locale by default.
  home: const PaymentScreen(),
);
```

---

### Step 3: Open the Full Payment View

Use `MoosylFlutter.show()` when you want Moosyl to own the checkout payment UI. It returns `bool?`: a non-null value when the payment flow finishes, or `null` when the user closes the view without completing payment.

Set `isFullPage` to `true` for a pushed route or `false` for a bottom sheet.

```dart
import 'package:flutter/material.dart';
import 'package:moosyl_flutter/moosyl.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final isSuccess = await MoosylFlutter.show(
          context,
          publishableApiKey: 'YOUR_PUBLISHABLE_API_KEY',
          transactionId: 'TRANSACTION_ID', // From your backend
          isFullPage: true, // false for bottom sheet
          items: const [
            MoosylPaymentSummaryItem(amount: 5000, label: 'amountToPay'),
            MoosylPaymentSummaryItem(amount: 0, label: 'tax'),
          ],
          isMasriviInBottomSheet: false,
          masriviPhoneNumber: '+22212345678',
        );

        if (isSuccess != null) {
          print('Payment finished. isSuccess=$isSuccess');
        }
      },
      child: const Text('Pay'),
    );
  }
}
```

#### `MoosylFlutter.show()` Options

| Option | Type | Required | Description |
| --- | --- | --- | --- |
| `publishableApiKey` | `String` | Yes | Your Moosyl publishable API key. |
| `transactionId` | `String` | Yes | The transaction ID returned by your backend payment request. |
| `items` | `List<MoosylPaymentSummaryItem>?` | No | Summary rows shown in the payment view. When supplied, their total is validated against the payment request amount. Known localized labels include `amountToPay`, `tax`, `total`, and `totalAmount`; custom labels are shown as provided. |
| `isFullPage` | `bool` | No | Defaults to `true`. Use `false` to show the flow in a bottom sheet. |
| `isMasriviInBottomSheet` | `bool` | No | Controls whether Masrivi opens as bottom-sheet content inside the payment flow. |
| `masriviPhoneNumber` | `String?` | No | Optional phone number used to prefill the Masrivi payment page. |

---

## Embedded Payment Methods

Use `MoosylPaymentMethods` when your app owns the checkout screen and you only want Moosyl to load, display, select, and continue with payment methods.

```dart
class EmbeddedPaymentScreen extends StatefulWidget {
  const EmbeddedPaymentScreen({super.key});

  @override
  State<EmbeddedPaymentScreen> createState() => _EmbeddedPaymentScreenState();
}

class _EmbeddedPaymentScreenState extends State<EmbeddedPaymentScreen> {
  final _controller = MoosylPaymentMethodsController();
  ConfigurationListDataInner? _selectedMethod;
  bool _continueLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedTitle = _selectedMethod == null
        ? 'platform'
        : PaymentMethodTypes.fromString(_selectedMethod!.type).title(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MoosylPaymentMethods(
          controller: _controller,
          publishableApiKey: 'YOUR_PUBLISHABLE_API_KEY',
          transactionId: 'TRANSACTION_ID',
          selectedMethodId: _selectedMethod?.id,
          onSelectMethod: (method) {
            setState(() => _selectedMethod = method);
          },
          onContinueLoadingChange: (loading) {
            setState(() => _continueLoading = loading);
          },
          onPaymentSuccess: (isSuccess) async {
            print('Payment finished. isSuccess=$isSuccess');
          },
          primaryColor: const Color(0xFFF55E1E),
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: _selectedMethod == null || _continueLoading
              ? null
              : _controller.continuePayment,
          child: Text(
            _continueLoading ? 'Loading...' : 'Continue with $selectedTitle',
          ),
        ),
      ],
    );
  }
}
```

---

## Custom Payment Method UI

Pass `renderMethod` to draw each payment method row with your own widgets. Call `data.onSelect()` from your custom row so Moosyl can track the selected method.

```dart
MoosylPaymentMethods(
  controller: _controller,
  publishableApiKey: 'YOUR_PUBLISHABLE_API_KEY',
  transactionId: 'TRANSACTION_ID',
  selectedMethodId: selectedMethod?.id,
  onSelectMethod: (method) {
    setState(() => selectedMethod = method);
  },
  onContinueLoadingChange: (loading) {
    setState(() => continueLoading = loading);
  },
  onPaymentSuccess: (isSuccess) async {
    print('Payment finished. isSuccess=$isSuccess');
  },
  primaryColor: const Color(0xFFF55E1E),
  renderMethod: (context, data) {
    return ListTile(
      onTap: data.onSelect,
      leading: data.type.icon.apply(size: 36),
      title: Text(data.title),
      subtitle: Text(data.method.type),
      trailing: data.isSelected ? const Icon(Icons.check_circle) : null,
    );
  },
)
```

`MoosylPaymentMethodRenderData` gives your row everything it needs:

| Property | Description |
| --- | --- |
| `method` | Raw `ConfigurationListDataInner` payment method data from Moosyl. |
| `type` | Parsed `PaymentMethodTypes` value. |
| `title` | Localized payment method title. |
| `isSelected` | Whether this row is currently selected. |
| `selectedMethodId` | Currently selected method ID, if any. |
| `isRTL` | Whether the surrounding layout direction is RTL. |
| `onSelect` | Callback your custom UI should call when the row is selected. |

---

## `MoosylPaymentMethods` Options

| Option | Type | Description |
| --- | --- | --- |
| `publishableApiKey` | `String` | Required. Your Moosyl publishable API key. |
| `transactionId` | `String?` | Transaction ID used by `controller.continuePayment()`. |
| `amountToPay` | `double` | Amount used for validation when continuing. Defaults to `0.0`. |
| `tax` | `double` | Tax amount used with `amountToPay` when `totalAmount` is not supplied. Defaults to `0.0`. |
| `totalAmount` | `double?` | Total expected amount. Defaults to `amountToPay + tax`. |
| `selectedMethodId` | `String?` | Controlled selected method ID. |
| `onSelectMethod` | `ValueChanged<ConfigurationListDataInner>?` | Called whenever a method is selected. |
| `onPaymentSuccess` | `FutureOr<void> Function(bool)?` | Called when payment succeeds or reports a final success status. |
| `onPaymentError` | `ValueChanged<Object>?` | Called when loading or continuing payment fails. |
| `onContinueLoadingChange` | `ValueChanged<bool>?` | Called when `continuePayment()` starts and finishes. |
| `controller` | `MoosylPaymentMethodsController?` | Lets your screen call `continuePayment()` and read `selectedMethod`. Dispose it from your state object. |
| `primaryColor` | `Color?` | Accent color for default rows and dialogs. Defaults to the theme primary color. |
| `renderMethod` | `MoosylPaymentMethodBuilder?` | Custom builder for each payment method row. |
| `loadingComponent` | `Widget?` | Custom widget shown while payment methods are loading. |
| `loadingBuilder` | `MoosylPaymentMethodsLoadingBuilder?` | Builder for custom loading content with locale, color, and RTL data. |
| `showDefaultTitle` | `bool` | Whether the default UI includes its section title. Defaults to `true`. |
| `isMasriviInBottomSheet` | `bool` | Whether Masrivi opens in a bottom sheet from custom platform UIs. Defaults to `true`. |
| `masriviPresentation` | `MasriviWebViewPresentation` | Presentation used when `isMasriviInBottomSheet` is `false`. Defaults to `MasriviWebViewPresentation.fullPage`. |
| `masriviPhoneNumber` | `String?` | Optional phone number used to prefill Masrivi. |
| `masriviBottomSheetHeight` | `double` | Height factor for Masrivi bottom-sheet content. Defaults to `0.88`. |

For a complete working demo with the full payment view, embedded platforms, and custom payment method rows, see [`example/lib/main.dart`](example/lib/main.dart).

For detailed API documentation, visit the [Moosyl Flutter API Documentation](https://pub.dev/documentation/moosyl_flutter/latest/moosyl_flutter/moosyl_flutter-library.html).

---

## 📚 Documentation

Complete documentation, including step-by-step guides and best practices, will soon be available at [docs.moosyl.com](https://docs.moosyl.com).

---

## 🛠️ Configuration

- **API Key**: Sign up at [moosyl.com](https://moosyl.com) to get your API key.
- **Webhook URL**: Configure your webhook endpoint in the Moosyl dashboard to receive payment status updates.

---

## 🧑‍💻 Contributing

We welcome contributions! Follow these steps to contribute:

1. Fork this repository.
2. Create a feature branch (`git checkout -b feature-name`).
3. Commit your changes (`git commit -m 'Add feature'`).
4. Push to your branch (`git push origin feature-name`).
5. Submit a pull request.

---

## 🤝 Support

For help or questions:

- Visit [moosyl.com](https://moosyl.com).
- Email support@moosyl.com.
- Open an issue on [GitHub](https://github.com/SoftwareSavants/moosyl_flutter).

---

## 📜 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

**Empower your Flutter apps with Moosyl!**  
Visit [moosyl.com](https://moosyl.com) to get started.
