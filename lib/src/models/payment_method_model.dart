import 'package:flutter/widgets.dart';
import 'package:moosyl/moosyl.dart' show ConfigurationListDataInner;
import 'package:moosyl_flutter/l10n/generated/moosyl_localization.dart';

import 'package:moosyl_flutter/src/widgets/icons.dart';

/// Enum representing the different types of payment methods available.
///
/// Each enum value corresponds to a specific payment method
/// and provides access to its associated icon, title, and string representation.
enum PaymentMethodTypes {
  /// Represents the Masrivi payment method.
  masrivi,

  /// Represents the Bankily payment method.
  bankily,

  /// Represents the Sedad payment method.
  sedad,

  /// Represents the Bim Bank payment method.
  bimBank,

  /// Represents the Amanty payment method.
  amanty,

  /// Represents the BCIpay payment method.
  bCIpay;

  /// Gets the icon associated with the payment method type.
  ///
  /// Returns an instance of [AppIcon] based on the payment method.
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

  /// Gets the localized title for the payment method type.
  ///
  /// Uses [LocalizationsHelper] to retrieve the appropriate localized string
  /// for each payment method.
  String title(BuildContext context) {
    final localizationsHelper = MoosylLocalization.of(context)!;

    return switch (this) {
      PaymentMethodTypes.masrivi => localizationsHelper.masrivi,
      PaymentMethodTypes.bankily => localizationsHelper.bankily,
      PaymentMethodTypes.sedad => localizationsHelper.sedad,
      PaymentMethodTypes.bimBank => localizationsHelper.bimBank,
      PaymentMethodTypes.amanty => localizationsHelper.amanty,
      PaymentMethodTypes.bCIpay => localizationsHelper.bCIpay,
    };
  }

  /// Gets the string representation of the payment method type.
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

  /// Parses the API's method type (e.g. `bci_pay`); `null` when this SDK
  /// version does not know the type, so callers can skip it.
  static PaymentMethodTypes? tryParse(String method) {
    for (final value in PaymentMethodTypes.values) {
      if (value.toStr == method) return value;
    }
    return null;
  }

  /// Creates a [PaymentMethodTypes] instance from its string representation.
  ///
  /// Throws an [UnimplementedError] if the provided method is not supported;
  /// prefer [tryParse].
  static PaymentMethodTypes fromString(String method) {
    return tryParse(method) ??
        (throw UnimplementedError('This payment method is not supported'));
  }
}

/// Whether [method] is paid through a Gimtel transfer (the Gimtel sheet)
/// rather than the method's native flow. BCI Pay and Amanty are only offered
/// through Gimtel; Bankily is when its integration is `gimtel`.
bool isGimtelMethod(ConfigurationListDataInner method) =>
    method.integration == 'gimtel' ||
    method.type == PaymentMethodTypes.bCIpay.toStr ||
    method.type == PaymentMethodTypes.amanty.toStr;
