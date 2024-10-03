import 'package:software_pay/widgets/icons.dart';

enum PaymentMethodTypes {
  masrivi,
  bankily,
  sedad,
  bimBank,
  amanty,
  bCIpay;

  AppIcon get icon {
    return switch (this) {
      bankily => AppIcons.bankily,
      masrivi => AppIcons.masrivi,
      sedad => AppIcons.sedad,
      bimBank => AppIcons.bimBank,
      bCIpay => AppIcons.bCIpay,
      amanty => AppIcons.amanty,
    };
  }

  String get displayName {
    switch (this) {
      case PaymentMethodTypes.masrivi:
        return 'Masrivi';
      case PaymentMethodTypes.bankily:
        return 'Bankily';
      case PaymentMethodTypes.sedad:
        return 'Sedad';
      case PaymentMethodTypes.bimBank:
        return 'BIM Bank';
      case PaymentMethodTypes.amanty:
        return 'Amanty';
      case PaymentMethodTypes.bCIpay:
        return 'BCI Pay';
    }
  }

  String get toStr {
    switch (this) {
      case PaymentMethodTypes.masrivi:
        return 'Masrivi';
      case PaymentMethodTypes.bankily:
        return 'Bankily';
      case PaymentMethodTypes.sedad:
        return 'Sedad';
      case PaymentMethodTypes.bimBank:
        return 'BIM Bank';
      case PaymentMethodTypes.amanty:
        return 'Amanty';
      case PaymentMethodTypes.bCIpay:
        return 'BCI Pay';
    }
  }

  static PaymentMethodTypes fromString(String method) {
    return PaymentMethodTypes.values.firstWhere(
      (value) => value.toStr == method,
      orElse: () =>
          throw UnimplementedError('This payment method is not supported'),
    );
  }
}

abstract class PaymentMethod {
  final String id;
  final PaymentMethodTypes method;

  PaymentMethod({
    required this.id,
    required this.method,
  });
}

class BankilyConfigModel extends PaymentMethod {
  final String bPayNumber;

  BankilyConfigModel({
    required super.id,
    required super.method,
    required this.bPayNumber,
  });
}
