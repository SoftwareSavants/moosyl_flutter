import 'package:software_pay/src/l10n/localization_helper.dart';
import 'package:software_pay/src/widgets/icons.dart';

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

  String get title {
    final localizationsHelper = LocalizationsHelper();

    return switch (this) {
      PaymentMethodTypes.masrivi => localizationsHelper.msgs.masrivi,
      PaymentMethodTypes.bankily => localizationsHelper.msgs.bankily,
      PaymentMethodTypes.sedad => localizationsHelper.msgs.sedad,
      PaymentMethodTypes.bimBank => localizationsHelper.msgs.bimBank,
      PaymentMethodTypes.amanty => localizationsHelper.msgs.amanty,
      PaymentMethodTypes.bCIpay => localizationsHelper.msgs.bCIpay,
    };
  }

  String get toStr {
    return switch (this) {
      PaymentMethodTypes.masrivi => 'masrivi',
      PaymentMethodTypes.bankily => 'bankily',
      PaymentMethodTypes.sedad => 'sedad',
      PaymentMethodTypes.bimBank => 'bim_bank',
      PaymentMethodTypes.amanty => 'amanty',
      PaymentMethodTypes.bCIpay => 'bci_pay',
    };
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

  PaymentMethod.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        method = PaymentMethodTypes.fromString(map['method']);

  //from type

  static PaymentMethod fromType(Map<String, dynamic> map) {
    final type = PaymentMethodTypes.fromString(map['method']);
    switch (type) {
      case PaymentMethodTypes.bankily:
        return BankilyConfigModel.fromMap(map);
      default:
        throw UnimplementedError('This payment method is not supported');
    }
  }
}

class BankilyConfigModel extends PaymentMethod {
  final String bPayNumber;

  BankilyConfigModel({
    required super.id,
    required super.method,
    required this.bPayNumber,
  });

  BankilyConfigModel.fromMap(super.map)
      : bPayNumber = map['bpay_number'],
        super.fromMap();
}
