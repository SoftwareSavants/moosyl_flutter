import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred'**
  String get unknownError;

  /// No description provided for @copiedThisText.
  ///
  /// In en, this message translates to:
  /// **'Copied this text'**
  String get copiedThisText;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @bankily.
  ///
  /// In en, this message translates to:
  /// **'Bankily'**
  String get bankily;

  /// No description provided for @sedad.
  ///
  /// In en, this message translates to:
  /// **'Sedad'**
  String get sedad;

  /// No description provided for @bimBank.
  ///
  /// In en, this message translates to:
  /// **'Bim Bank'**
  String get bimBank;

  /// No description provided for @masrivi.
  ///
  /// In en, this message translates to:
  /// **'Masrivi'**
  String get masrivi;

  /// No description provided for @amanty.
  ///
  /// In en, this message translates to:
  /// **'Amanty'**
  String get amanty;

  /// No description provided for @bCIpay.
  ///
  /// In en, this message translates to:
  /// **'BCI Pay'**
  String get bCIpay;

  /// No description provided for @payUsing.
  ///
  /// In en, this message translates to:
  /// **'Pay using {method}'**
  String payUsing(Object method);

  /// No description provided for @copyTheCodeBPayAndHeadToBankilyToPayTheAmount.
  ///
  /// In en, this message translates to:
  /// **'Copy the code, BPay and head to Bankily to pay the amount'**
  String get copyTheCodeBPayAndHeadToBankilyToPayTheAmount;

  /// No description provided for @afterPayment.
  ///
  /// In en, this message translates to:
  /// **'After payment'**
  String get afterPayment;

  /// No description provided for @afterMakingThePaymentFillTheFollowingInformation.
  ///
  /// In en, this message translates to:
  /// **'After making the payment, fill the following information'**
  String get afterMakingThePaymentFillTheFollowingInformation;

  /// No description provided for @enterYourBankilyPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your Bankily phone number'**
  String get enterYourBankilyPhoneNumber;

  /// No description provided for @bankilyPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Bankily Phone Number'**
  String get bankilyPhoneNumber;

  /// No description provided for @paymentPassCode.
  ///
  /// In en, this message translates to:
  /// **'Payment Pass Code'**
  String get paymentPassCode;

  /// No description provided for @paymentPassCodeFromBankily.
  ///
  /// In en, this message translates to:
  /// **'Payment Pass Code from Bankily'**
  String get paymentPassCodeFromBankily;

  /// No description provided for @sendForVerification.
  ///
  /// In en, this message translates to:
  /// **'Send for verification'**
  String get sendForVerification;

  /// No description provided for @codeBPay.
  ///
  /// In en, this message translates to:
  /// **'Code BPay'**
  String get codeBPay;

  /// No description provided for @amountToPay.
  ///
  /// In en, this message translates to:
  /// **'Amount to pay'**
  String get amountToPay;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
