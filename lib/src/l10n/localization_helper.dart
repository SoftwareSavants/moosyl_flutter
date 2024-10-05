import 'package:flutter/material.dart';
import 'package:software_pay/src/l10n/app_localizations.dart';

class LocalizationsHelper {
  static LocalizationsHelper? _instance;
  final BuildContext context;

  factory LocalizationsHelper({BuildContext? context}) {
    assert(context != null || _instance != null, 'context must not be null');

    _instance ??= LocalizationsHelper._(context!);

    return _instance!;
  }

  LocalizationsHelper._(this.context);

  AppLocalizations get msgs => AppLocalizations.of(context);

  AppLocalizations of(BuildContext context) {
    return AppLocalizations.of(context);
  }
}
