# Moosyl Flutter SDK

[![Pub Version](https://img.shields.io/pub/v/moosyl.svg)](https://pub.dev/packages/moosyl)  
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

Add the **Moosyl** package to your `pubspec.yaml`:

```yaml
dependencies:
  moosyl: ^latest_version
```

Fetch the package:

```bash
flutter pub get
```

### Import the Package

```dart
import 'package:moosyl/moosyl.dart';
```

---

## 📘 Usage

### Step 1: Create a Payment Request

Before displaying the payment interface in your Flutter app, you need to create a payment request from your backend using the Moosyl API. Use your **secret API key** to authenticate the request. Here's how to do it:

#### cURL Example:

```bash
curl -X POST https://api.moosyl.com/payment-request \
-H "Authorization: Bearer YOUR_SECRET_API_KEY" \
-H "Content-Type: application/json" \
-d '{
  "phoneNumber": "+22212345678",
  "transactionId": "your-unique-transaction-id",
  "amount": 5000
}'
```

#### Node.js Example:

```javascript
const axios = require('axios');

async function createPaymentRequest() {
  try {
    const response = await axios.post('https://api.moosyl.com/payment-request', {
      phoneNumber: '+22212345678', // Optional
      transactionId: 'your-unique-transaction-id',
      amount: 5000, // Amount in the smallest currency unit
    }, {
      headers: {
        'Authorization': 'Bearer YOUR_SECRET_API_KEY',
        'Content-Type': 'application/json',
      },
    });

    console.log('Payment Request Created:', response.data);
  } catch (error) {
    console.error('Error creating payment request:', error.response.data);
  }
}

createPaymentRequest();
```

Once the payment request is created, the backend will return details including the **transactionId**, which you will pass to the Flutter app for further processing.

---

### Step 2: Display the Payment View

Here’s how you can use the **MoosylView** widget in your Flutter app:

```dart
import 'package:flutter/material.dart';
import 'package:moosyl/moosyl.dart';

class PaymentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MoosylView(
      authorization: 'YOUR_PUBLISHABLE_API_KEY',
      transactionId: 'TRANSACTION_ID', // Retrieved from your backend
      organizationLogo: const Text('Your Logo Here'),
      customHandlers: {
        PaymentMethodTypes.bimBank: () {
          print('Custom handler for BIM Bank payment method');
        },
      },
      onPaymentSuccess: () {
        print('Payment was successful!');
      },
    );
  }
}
```

This example showcases the essential **MoosylView** widget, where you can configure:

- **`authorization`**: Your Moosyl authorization token.
- **`transactionId`**: The unique transaction identifier returned by your backend.
- **`customHandlers`**: Define custom actions for specific payment methods.
- **`onPaymentSuccess`**: Handle successful payment events.

For detailed API documentation, visit the [Moosyl API Documentation](https://pub.dev/documentation/moosyl/latest/moosyl/moosyl-library.html).

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
- Open an issue on [GitHub](https://github.com/moosyl/flutter-sdk).

---

## 📜 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

**Empower your Flutter apps with Moosyl!**  
Visit [moosyl.com](https://moosyl.com) to get started.
