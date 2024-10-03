import 'package:flutter/material.dart';
import 'package:software_pay/l10n/app_localizations.dart';

class LocalizationsHelper {
  final BuildContext context;

  LocalizationsHelper(this.context);

  AppLocalizations get msgs => AppLocalizations.of(context);

  AppLocalizations of(BuildContext context) {
    return AppLocalizations.of(context);
  }
}
