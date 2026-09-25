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
  /// **'Enter phone number'**
  String get enterYourBankilyPhoneNumber;

  /// No description provided for @bankilyPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Bankily Phone Number'**
  String get bankilyPhoneNumber;

  /// No description provided for @paymentPassCode.
  ///
  /// In en, this message translates to:
  /// **'Payment Code'**
  String get paymentPassCode;

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

  /// No description provided for @choosePaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Choose payment method'**
  String get choosePaymentMethods;

  /// No description provided for @tax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get tax;

  /// No description provided for @pay.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get pay;

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

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// No description provided for @paymentSummary.
  ///
  /// In en, this message translates to:
  /// **'Payment Summary'**
  String get paymentSummary;

  /// No description provided for @paymentCode.
  ///
  /// In en, this message translates to:
  /// **'Payment Code'**
  String get paymentCode;

  /// No description provided for @ivePaid.
  ///
  /// In en, this message translates to:
  /// **'I\'ve paid'**
  String get ivePaid;

  /// No description provided for @usePaymentCodeAboveToComplete.
  ///
  /// In en, this message translates to:
  /// **'Use the payment code above to complete your payment in the Sedad app, then tap the button below.'**
  String get usePaymentCodeAboveToComplete;

  /// No description provided for @paymentRequestFullyPaid.
  ///
  /// In en, this message translates to:
  /// **'This payment request has fully paid.'**
  String get paymentRequestFullyPaid;

  /// No description provided for @amountToPayShouldMatchPaymentRequest.
  ///
  /// In en, this message translates to:
  /// **'Amount to pay should match payment request amount.'**
  String get amountToPayShouldMatchPaymentRequest;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @tapToUse.
  ///
  /// In en, this message translates to:
  /// **'Tap to use'**
  String get tapToUse;

  /// No description provided for @chooseHowYouWouldLikeToPay.
  ///
  /// In en, this message translates to:
  /// **'Choose how you would like to pay'**
  String get chooseHowYouWouldLikeToPay;

  /// No description provided for @useThisCodeToCompletePayment.
  ///
  /// In en, this message translates to:
  /// **'Use this code to complete payment'**
  String get useThisCodeToCompletePayment;

  /// No description provided for @sedadStep1.
  ///
  /// In en, this message translates to:
  /// **'1. Open the Sedad app'**
  String get sedadStep1;

  /// No description provided for @sedadStep2.
  ///
  /// In en, this message translates to:
  /// **'2. Go to payment'**
  String get sedadStep2;

  /// No description provided for @sedadStep3.
  ///
  /// In en, this message translates to:
  /// **'3. Paste or enter the code to confirm payment'**
  String get sedadStep3;

  /// No description provided for @sedadStep4.
  ///
  /// In en, this message translates to:
  /// **'4. Return to this page and click \"I\'ve paid\"'**
  String get sedadStep4;

  /// No description provided for @changePaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Change payment method'**
  String get changePaymentMethod;

  /// No description provided for @clickToCopy.
  ///
  /// In en, this message translates to:
  /// **'Click to copy'**
  String get clickToCopy;

  /// No description provided for @bankilyStep1.
  ///
  /// In en, this message translates to:
  /// **'1. Open the Bankily app'**
  String get bankilyStep1;

  /// No description provided for @bankilyStep2.
  ///
  /// In en, this message translates to:
  /// **'2. Go to BPay'**
  String get bankilyStep2;

  /// No description provided for @bankilyStep3.
  ///
  /// In en, this message translates to:
  /// **'3. Enter the BPay code and amount to pay'**
  String get bankilyStep3;

  /// No description provided for @bankilyStep4.
  ///
  /// In en, this message translates to:
  /// **'4. Return here, enter your phone and passcode, then click Pay'**
  String get bankilyStep4;

  /// No description provided for @paymentNotCompleted.
  ///
  /// In en, this message translates to:
  /// **'Payment not completed'**
  String get paymentNotCompleted;

  /// No description provided for @paymentSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Payment successful'**
  String get paymentSuccessful;

  /// No description provided for @paymentId.
  ///
  /// In en, this message translates to:
  /// **'Payment ID'**
  String get paymentId;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment failed'**
  String get paymentFailed;

  /// No description provided for @paymentDeclined.
  ///
  /// In en, this message translates to:
  /// **'Your balance may be insufficient or your account may not be active.'**
  String get paymentDeclined;

  /// No description provided for @gimtelPhoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Which number will you pay from?'**
  String get gimtelPhoneTitle;

  /// No description provided for @gimtelPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Your {app} phone number'**
  String gimtelPhoneLabel(String app);

  /// No description provided for @gimtelPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'The number of your {app} account. We use it to recognize your payment.'**
  String gimtelPhoneHint(String app);

  /// No description provided for @gimtelContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get gimtelContinue;

  /// No description provided for @gimtelInvalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 8-digit Mauritanian number'**
  String get gimtelInvalidPhone;

  /// No description provided for @gimtelPayTitle.
  ///
  /// In en, this message translates to:
  /// **'Pay via <g>Gimtel</g> in {app}'**
  String gimtelPayTitle(String app);

  /// No description provided for @gimtelViaGimtel.
  ///
  /// In en, this message translates to:
  /// **'Via Gimtel'**
  String get gimtelViaGimtel;

  /// No description provided for @gimtelMerchantNumber.
  ///
  /// In en, this message translates to:
  /// **'Merchant number'**
  String get gimtelMerchantNumber;

  /// No description provided for @gimtelAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get gimtelAmount;

  /// No description provided for @gimtelTapToCopy.
  ///
  /// In en, this message translates to:
  /// **'Tap to copy'**
  String get gimtelTapToCopy;

  /// No description provided for @gimtelCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get gimtelCopied;

  /// No description provided for @gimtelBankilyS1.
  ///
  /// In en, this message translates to:
  /// **'In {app}, tap <g>Gimtel</g>'**
  String gimtelBankilyS1(String app);

  /// No description provided for @gimtelBankilyS2.
  ///
  /// In en, this message translates to:
  /// **'Tap <b>Pay Merchant</b>'**
  String get gimtelBankilyS2;

  /// No description provided for @gimtelBankilyS3.
  ///
  /// In en, this message translates to:
  /// **'Fill in the highlighted fields, then tap <b>Next</b>'**
  String get gimtelBankilyS3;

  /// No description provided for @gimtelBankilyS4.
  ///
  /// In en, this message translates to:
  /// **'Tap <b>Continue</b>, then enter your PIN'**
  String get gimtelBankilyS4;

  /// No description provided for @gimtelBciPayS1.
  ///
  /// In en, this message translates to:
  /// **'In {app}, tap <b>Payments</b>'**
  String gimtelBciPayS1(String app);

  /// No description provided for @gimtelBciPayS2.
  ///
  /// In en, this message translates to:
  /// **'Switch to <g>GIMTEL</g>'**
  String get gimtelBciPayS2;

  /// No description provided for @gimtelBciPayS3.
  ///
  /// In en, this message translates to:
  /// **'Choose <b>BIMBANK</b>, enter the number, tap <b>Continue</b>'**
  String get gimtelBciPayS3;

  /// No description provided for @gimtelBciPayS4.
  ///
  /// In en, this message translates to:
  /// **'Enter the amount, then tap <b>Pay</b>'**
  String get gimtelBciPayS4;

  /// No description provided for @gimtelGenericStep1.
  ///
  /// In en, this message translates to:
  /// **'Open {app} → <g>Gimtel</g> → <b>Pay Merchant</b>'**
  String gimtelGenericStep1(String app);

  /// No description provided for @gimtelGenericStep2.
  ///
  /// In en, this message translates to:
  /// **'Choose <b>BIMBANK</b>, enter <n>{phone}</n> and <n>{amount}</n>'**
  String gimtelGenericStep2(String phone, String amount);

  /// No description provided for @gimtelGenericStep3.
  ///
  /// In en, this message translates to:
  /// **'Confirm with your PIN'**
  String get gimtelGenericStep3;

  /// No description provided for @gimtelWaitingTitle.
  ///
  /// In en, this message translates to:
  /// **'Waiting for your payment'**
  String get gimtelWaitingTitle;

  /// No description provided for @gimtelWaitingHint.
  ///
  /// In en, this message translates to:
  /// **'Pay from <n>{phone}</n>, exact amount. Keep this page open.'**
  String gimtelWaitingHint(String phone);

  /// No description provided for @gimtelSimulate.
  ///
  /// In en, this message translates to:
  /// **'Simulate transfer (sandbox)'**
  String get gimtelSimulate;

  /// No description provided for @gimtelChangeNumber.
  ///
  /// In en, this message translates to:
  /// **'Change number'**
  String get gimtelChangeNumber;

  /// No description provided for @gimtelOtherMethod.
  ///
  /// In en, this message translates to:
  /// **'Use another method'**
  String get gimtelOtherMethod;

  /// No description provided for @gimtelExpiredTitle.
  ///
  /// In en, this message translates to:
  /// **'This payment expired'**
  String get gimtelExpiredTitle;

  /// No description provided for @gimtelExpiredDescription.
  ///
  /// In en, this message translates to:
  /// **'If you already sent the money, it will be refunded.'**
  String get gimtelExpiredDescription;

  /// No description provided for @gimtelInactiveTitle.
  ///
  /// In en, this message translates to:
  /// **'This payment is no longer active'**
  String get gimtelInactiveTitle;

  /// No description provided for @gimtelInactiveDescription.
  ///
  /// In en, this message translates to:
  /// **'Start again to get new payment instructions.'**
  String get gimtelInactiveDescription;

  /// No description provided for @gimtelStartAgain.
  ///
  /// In en, this message translates to:
  /// **'Start again'**
  String get gimtelStartAgain;
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
