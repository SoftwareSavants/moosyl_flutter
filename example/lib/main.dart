// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:moosyl_flutter/moosyl.dart';

import 'payment_success_dialog.dart';

const _apiKey = 'your_api_key';
const _transactionId = 'transaction_id';
const _primaryColor = Color(0xFF000000);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const colorScheme = ColorScheme.light(
    primary: _primaryColor,
    onPrimary: Color(0xFFFFFFFF),
    surface: Color(0xFFF7F7F7),
    onSurface: Color(0xFF111111),
    secondary: Color(0xFFEAF1FF),
    onSecondary: Color(0xFF000000),
    error: Color(0xFFCE2C2C),
    tertiary: Color(0xFF01D066),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moosyl Demo',
      localizationsDelegates: MoosylLocalization.localizationsDelegates,
      supportedLocales: MoosylLocalization.supportedLocales,
      locale: const Locale('en'),
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
      ),
      home: const DemoHomePage(),
    );
  }
}

enum DemoMode {
  menu,
  embeddedPlatforms,
  customPlatforms,
}

class DemoHomePage extends StatefulWidget {
  const DemoHomePage({super.key});

  @override
  State<DemoHomePage> createState() => _DemoHomePageState();
}

class _DemoHomePageState extends State<DemoHomePage> {
  final _embeddedController = MoosylPaymentMethodsController();
  final _customController = MoosylPaymentMethodsController();

  DemoMode _demoMode = DemoMode.menu;
  ConfigurationListDataInner? _selectedEmbeddedMethod;
  ConfigurationListDataInner? _selectedCustomMethod;
  bool _embeddedContinueLoading = false;
  bool _customContinueLoading = false;

  @override
  void dispose() {
    _embeddedController.dispose();
    _customController.dispose();
    super.dispose();
  }

  Future<void> _openMoosylView() async {
    final isSuccess = await MoosylFlutter.show(context,
        publishableApiKey: _apiKey,
        transactionId: _transactionId,
        isFullPage: true,
        items: [
          const MoosylPaymentSummaryItem(amount: 2000, label: 'Subtotal'),
          const MoosylPaymentSummaryItem(amount: 150, label: 'Tax')
        ]);
    if (!mounted) return;
    if (isSuccess != null) {
      await _showSuccess(isSuccess);
    }
  }

  Future<void> _showSuccess(bool isSuccess) async {
    await showPaymentSuccessDialog(context, isSuccess: isSuccess);
    print('Payment was successful! isSuccess=$isSuccess');
  }

  void _showMenu() {
    setState(() {
      _demoMode = DemoMode.menu;
    });
  }

  @override
  Widget build(BuildContext context) {
    return switch (_demoMode) {
      DemoMode.menu => _MenuScreen(
          onOpenMoosylView: _openMoosylView,
          onOpenEmbeddedPlatforms: () {
            setState(() {
              _demoMode = DemoMode.embeddedPlatforms;
            });
          },
          onOpenCustomPlatforms: () {
            setState(() {
              _demoMode = DemoMode.customPlatforms;
            });
          },
        ),
      DemoMode.embeddedPlatforms => _EmbeddedPlatformsScreen(
          controller: _embeddedController,
          selectedMethod: _selectedEmbeddedMethod,
          continueLoading: _embeddedContinueLoading,
          onBack: _showMenu,
          onSelectMethod: (method) {
            setState(() {
              _selectedEmbeddedMethod = method;
            });
          },
          onContinueLoadingChange: (loading) {
            setState(() {
              _embeddedContinueLoading = loading;
            });
          },
          onPaymentSuccess: _showSuccess,
        ),
      DemoMode.customPlatforms => _CustomPlatformsScreen(
          controller: _customController,
          selectedMethod: _selectedCustomMethod,
          continueLoading: _customContinueLoading,
          onBack: _showMenu,
          onSelectMethod: (method) {
            setState(() {
              _selectedCustomMethod = method;
            });
          },
          onContinueLoadingChange: (loading) {
            setState(() {
              _customContinueLoading = loading;
            });
          },
          onPaymentSuccess: _showSuccess,
        ),
    };
  }
}

class _MenuScreen extends StatelessWidget {
  const _MenuScreen({
    required this.onOpenMoosylView,
    required this.onOpenEmbeddedPlatforms,
    required this.onOpenCustomPlatforms,
  });

  final VoidCallback onOpenMoosylView;
  final VoidCallback onOpenEmbeddedPlatforms;
  final VoidCallback onOpenCustomPlatforms;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Moosyl Demo')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 14,
            children: [
              _DemoButton(
                label: 'Test MoosylView',
                onPressed: onOpenMoosylView,
              ),
              _DemoButton(
                label: 'Test embedded platforms',
                onPressed: onOpenEmbeddedPlatforms,
                outlined: true,
              ),
              _DemoButton(
                label: 'Test custom methods UI',
                onPressed: onOpenCustomPlatforms,
                outlined: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmbeddedPlatformsScreen extends StatelessWidget {
  const _EmbeddedPlatformsScreen({
    required this.controller,
    required this.selectedMethod,
    required this.continueLoading,
    required this.onBack,
    required this.onSelectMethod,
    required this.onContinueLoadingChange,
    required this.onPaymentSuccess,
  });

  final MoosylPaymentMethodsController controller;
  final ConfigurationListDataInner? selectedMethod;
  final bool continueLoading;
  final VoidCallback onBack;
  final ValueChanged<ConfigurationListDataInner> onSelectMethod;
  final ValueChanged<bool> onContinueLoadingChange;
  final Future<void> Function(bool isSuccess) onPaymentSuccess;

  @override
  Widget build(BuildContext context) {
    final selectedTitle = selectedMethod == null
        ? 'platform'
        : PaymentMethodTypes.fromString(selectedMethod!.type).title(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Embedded Platforms'),
        leading: IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'This screen owns the checkout UI and only uses Moosyl to load and select the platform.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          Text(
            'Payment method',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          MoosylPaymentMethods(
            controller: controller,
            publishableApiKey: _apiKey,
            transactionId: _transactionId,
            selectedMethodId: selectedMethod?.id,
            onSelectMethod: onSelectMethod,
            onContinueLoadingChange: onContinueLoadingChange,
            onPaymentSuccess: onPaymentSuccess,
            primaryColor: _primaryColor,
          ),
          const SizedBox(height: 20),
          _DemoButton(
            label:
                continueLoading ? 'Loading...' : 'Continue with $selectedTitle',
            onPressed: selectedMethod == null || continueLoading
                ? null
                : controller.continuePayment,
          ),
        ],
      ),
    );
  }
}

class _CustomPlatformsScreen extends StatelessWidget {
  const _CustomPlatformsScreen({
    required this.controller,
    required this.selectedMethod,
    required this.continueLoading,
    required this.onBack,
    required this.onSelectMethod,
    required this.onContinueLoadingChange,
    required this.onPaymentSuccess,
  });

  final MoosylPaymentMethodsController controller;
  final ConfigurationListDataInner? selectedMethod;
  final bool continueLoading;
  final VoidCallback onBack;
  final ValueChanged<ConfigurationListDataInner> onSelectMethod;
  final ValueChanged<bool> onContinueLoadingChange;
  final Future<void> Function(bool isSuccess) onPaymentSuccess;

  @override
  Widget build(BuildContext context) {
    final selectedTitle = selectedMethod == null
        ? 'payment method'
        : PaymentMethodTypes.fromString(selectedMethod!.type).title(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F0E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F0E8),
        title: const Text('Custom Checkout'),
        leading: IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        children: [
          const _CheckoutSectionTitle(step: '1', title: 'Delivery address'),
          _CheckoutCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.location_on_outlined),
              title: const Text('Mohamed Ahmed'),
              subtitle:
                  const Text('Tevragh Zeina, Nouakchott\n+222 47 12 34 56'),
              trailing: TextButton(
                onPressed: () {},
                child: const Text('Change'),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const _CheckoutSectionTitle(step: '2', title: 'Products'),
          const _CheckoutCard(
            child: Column(
              children: [
                _ProductRow(
                  title: 'Floral Midi Dress',
                  subtitle: 'Pink • M • 1 x 520 MRU',
                  price: '520 MRU',
                ),
                Divider(height: 28),
                _ProductRow(
                  title: 'Cargo Wide-Leg Pants',
                  subtitle: 'Beige • L • 1 x 680 MRU',
                  price: '680 MRU',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const _CheckoutSectionTitle(step: '3', title: 'Payment method'),
          MoosylPaymentMethods(
            controller: controller,
            publishableApiKey: _apiKey,
            transactionId: _transactionId,
            selectedMethodId: selectedMethod?.id,
            onSelectMethod: onSelectMethod,
            onContinueLoadingChange: onContinueLoadingChange,
            onPaymentSuccess: onPaymentSuccess,
            primaryColor: _primaryColor,
            renderMethod: (context, data) => _CustomMethodRow(data: data),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: SizedBox(
          height: 64,
          child: FilledButton.icon(
            onPressed: selectedMethod == null || continueLoading
                ? null
                : controller.continuePayment,
            icon: selectedMethod == null
                ? const Icon(Icons.payments_outlined)
                : PaymentMethodTypes.fromString(selectedMethod!.type)
                    .icon
                    .apply(size: 32),
            label: Text(
              continueLoading
                  ? 'Loading...'
                  : 'Pay 2,470 MRU with $selectedTitle',
              textAlign: TextAlign.center,
            ),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF171713),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFF171713).withValues(
                alpha: 0.45,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomMethodRow extends StatelessWidget {
  const _CustomMethodRow({required this.data});

  final MoosylPaymentMethodRenderData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: data.onSelect,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          constraints: const BoxConstraints(minHeight: 78),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: data.isSelected
                  ? const Color(0xFF171713)
                  : const Color(0xFFEEE9E2),
              width: data.isSelected ? 2 : 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color:
                      data.isSelected ? const Color(0xFF171713) : Colors.white,
                  border: Border.all(color: const Color(0xFFD1D1CD)),
                  shape: BoxShape.circle,
                ),
                child: data.isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      data.title,
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.type == PaymentMethodTypes.bankily
                          ? 'Confirm with passcode'
                          : data.type == PaymentMethodTypes.masrivi
                              ? 'Mauritel Money'
                              : 'Payment wallet',
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F4F1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(child: data.type.icon.apply(size: 46)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DemoButton extends StatelessWidget {
  const _DemoButton({
    required this.label,
    required this.onPressed,
    this.outlined = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    );

    if (outlined) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryColor,
          side: const BorderSide(color: _primaryColor, width: 2),
          shape: shape,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
        child: Text(label),
      );
    }

    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        shape: shape,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
      child: Text(label),
    );
  }
}

class _CheckoutSectionTitle extends StatelessWidget {
  const _CheckoutSectionTitle({
    required this.step,
    required this.title,
  });

  final String step;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 30,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFEBE5DC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              step,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckoutCard extends StatelessWidget {
  const _CheckoutCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({
    required this.title,
    required this.subtitle,
    required this.price,
  });

  final String title;
  final String subtitle;
  final String price;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          price,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 6),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const SizedBox(width: 14),
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: const Color(0xFFF2CDD8),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ],
    );
  }
}
