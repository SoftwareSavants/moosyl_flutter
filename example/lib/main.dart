// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:moosyl/moosyl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static const colorScheme = ColorScheme.light(
    primary: Color(0xFF4445F4),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: MoosylView(
        publishableApiKey: 'unQq7nRs+A6c962o/piAfv3weq1Sx/reCamIxKqlj1U=',
        transactionId: '123456789',
        organizationLogo: const Text('Moosyl'),
        fullPage: false,
        onPaymentSuccess: () {
          print('Payment was successful!');
        },
      ),
    );
  }
}
