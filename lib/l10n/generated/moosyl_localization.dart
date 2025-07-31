import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'moosyl_localization_ar.dart';
import 'moosyl_localization_en.dart';
import 'moosyl_localization_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of MoosylLocalization
/// returned by `MoosylLocalization.of(context)`.
///
/// Applications need to include `MoosylLocalization.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/moosyl_localization.dart';
///
/// return MaterialApp(
///   localizationsDelegates: MoosylLocalization.localizationsDelegates,
///   supportedLocales: MoosylLocalization.supportedLocales,
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
/// be consistent with the languages listed in the MoosylLocalization.supportedLocales
/// property.
abstract class MoosylLocalization {
  MoosylLocalization(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static MoosylLocalization? of(BuildContext context) {
    return Localizations.of<MoosylLocalization>(context, MoosylLocalization);
  }

  static const LocalizationsDelegate<MoosylLocalization> delegate =
      _MoosylLocalizationDelegate();

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
  /// **'Pay using'**
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

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @capture.
  ///
  /// In en, this message translates to:
  /// **'Capture'**
  String get capture;

  /// No description provided for @copyTheMerchantCodeAndHeadToSedadToPayTheAmount.
  ///
  /// In en, this message translates to:
  /// **'Copy the {identifier} and head to {paymentMethod} to pay the amount'**
  String copyTheMerchantCodeAndHeadToSedadToPayTheAmount(
      Object identifier, Object paymentMethod);

  /// No description provided for @merchantCode.
  ///
  /// In en, this message translates to:
  /// **'merchant code'**
  String get merchantCode;

  /// No description provided for @merchantCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Merchant Code'**
  String get merchantCodeLabel;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'phone number'**
  String get phoneNumber;

  /// No description provided for @phoneNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumberLabel;

  /// No description provided for @existingPaymentWasFound.
  ///
  /// In en, this message translates to:
  /// **'An existing pending payment was found. Please wait for the previous payment to be processed.'**
  String get existingPaymentWasFound;

  /// No description provided for @authorizationRequired.
  ///
  /// In en, this message translates to:
  /// **'API key is required'**
  String get authorizationRequired;

  /// No description provided for @invalidAuthorizationOrganizationNotFound.
  ///
  /// In en, this message translates to:
  /// **'Invalid API key, organization not found'**
  String get invalidAuthorizationOrganizationNotFound;

  /// No description provided for @fileNotFound.
  ///
  /// In en, this message translates to:
  /// **'File not found'**
  String get fileNotFound;

  /// No description provided for @authenticationBPayFailed.
  ///
  /// In en, this message translates to:
  /// **'Authentication BPay failed'**
  String get authenticationBPayFailed;

  /// No description provided for @configurationNotFound.
  ///
  /// In en, this message translates to:
  /// **'Configuration not found'**
  String get configurationNotFound;

  /// No description provided for @paymentRequestNotFound.
  ///
  /// In en, this message translates to:
  /// **'Payment request not found'**
  String get paymentRequestNotFound;

  /// No description provided for @paymentNotFound.
  ///
  /// In en, this message translates to:
  /// **'Payment not found'**
  String get paymentNotFound;

  /// No description provided for @errorWhileCreatingPayment.
  ///
  /// In en, this message translates to:
  /// **'Error while creating payment'**
  String get errorWhileCreatingPayment;

  /// No description provided for @errorWhileCreatingPaymentRequest.
  ///
  /// In en, this message translates to:
  /// **'Error while creating paymentRequest'**
  String get errorWhileCreatingPaymentRequest;

  /// No description provided for @organizationNotFound.
  ///
  /// In en, this message translates to:
  /// **'Organization not found'**
  String get organizationNotFound;

  /// No description provided for @invalidAuthorization.
  ///
  /// In en, this message translates to:
  /// **'Invalid API key'**
  String get invalidAuthorization;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sending;

  /// No description provided for @processingError.
  ///
  /// In en, this message translates to:
  /// **'processing Error'**
  String get processingError;

  /// No description provided for @nonExistentOperation.
  ///
  /// In en, this message translates to:
  /// **'Non-existent operation'**
  String get nonExistentOperation;

  /// No description provided for @phoneNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneNumberRequired;

  /// No description provided for @validMauritanianNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid Mauritanian phone number'**
  String get validMauritanianNumber;

  /// No description provided for @codeRequired.
  ///
  /// In en, this message translates to:
  /// **'Code is required'**
  String get codeRequired;

  /// No description provided for @validDigitCode.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 4-digit code'**
  String get validDigitCode;
}

class _MoosylLocalizationDelegate
    extends LocalizationsDelegate<MoosylLocalization> {
  const _MoosylLocalizationDelegate();

  @override
  Future<MoosylLocalization> load(Locale locale) {
    return SynchronousFuture<MoosylLocalization>(
        lookupMoosylLocalization(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_MoosylLocalizationDelegate old) => false;
}

MoosylLocalization lookupMoosylLocalization(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return MoosylLocalizationAr();
    case 'en':
      return MoosylLocalizationEn();
    case 'fr':
      return MoosylLocalizationFr();
  }

  throw FlutterError(
      'MoosylLocalization.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
