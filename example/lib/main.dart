// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:moosyl_flutter/moosyl.dart';

import 'payment_success_dialog.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static const colorScheme = ColorScheme.light(
    primary: Color.fromARGB(255, 244, 68, 147),
    onPrimary: Color(0xFFFFFFFF),
    surface: Color(0xFFF0F0F0),
    onSurface: Color(0xFF000000),
    secondary: Color(0xFFEAF1FF),
    onSecondary: Color(0xFF000000),
    error: Color(0xFFCE2C2C),
    tertiary: Color(0xFF01D066),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moosyl  Demo',
      localizationsDelegates: MoosylLocalization.localizationsDelegates,
      supportedLocales: MoosylLocalization.supportedLocales,
      locale: const Locale('en'),
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Moosyl Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _openPaymentFlow() async {
    final payment = await MoosylFlutter.show(
      context,
      publishableApiKey: 'your publishable api key',
      transactionId: 'your transaction id',
      isFullPage: false,
    );
    if (!mounted) return;
    if (payment != null) {
      await showPaymentSuccessDialog(context, payment: payment);
      print(
          'Payment was successful! id=${payment.id} amount=${payment.amount} status=${payment.status}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontSize: 16,
                ),
          ),
          onPressed: _openPaymentFlow,
          child: const Text('Test payment flow'),
        ),
      ),
    );
  }
}
