import 'app_localizations.dart';

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get unknownError => 'An unknown error occurred';

  @override
  String get copiedThisText => 'Copied this text';

  @override
  String get paymentMethod => 'Payment Method';
}
