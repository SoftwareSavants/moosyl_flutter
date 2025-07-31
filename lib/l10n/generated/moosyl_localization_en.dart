// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'moosyl_localization.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class MoosylLocalizationEn extends MoosylLocalization {
  MoosylLocalizationEn([String locale = 'en']) : super(locale);

  @override
  String get unknownError => 'An unknown error occurred';

  @override
  String get copiedThisText => 'Copied this text';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get bankily => 'Bankily';

  @override
  String get sedad => 'Sedad';

  @override
  String get bimBank => 'Bim Bank';

  @override
  String get masrivi => 'Masrivi';

  @override
  String get amanty => 'Amanty';

  @override
  String get bCIpay => 'BCI Pay';

  @override
  String payUsing(Object method) {
    return 'Pay using';
  }

  @override
  String get copyTheCodeBPayAndHeadToBankilyToPayTheAmount =>
      'Copy the code, BPay and head to Bankily to pay the amount';

  @override
  String get afterPayment => 'After payment';

  @override
  String get afterMakingThePaymentFillTheFollowingInformation =>
      'After making the payment, fill the following information';

  @override
  String get enterYourBankilyPhoneNumber => 'Enter your Bankily phone number';

  @override
  String get bankilyPhoneNumber => 'Bankily Phone Number';

  @override
  String get paymentPassCode => 'Payment Pass Code';

  @override
  String get paymentPassCodeFromBankily => 'Payment Pass Code from Bankily';

  @override
  String get sendForVerification => 'Send for verification';

  @override
  String get codeBPay => 'Code BPay';

  @override
  String get amountToPay => 'Amount to pay';

  @override
  String get retry => 'Retry';

  @override
  String get upload => 'Upload';

  @override
  String get capture => 'Capture';

  @override
  String copyTheMerchantCodeAndHeadToSedadToPayTheAmount(
      Object identifier, Object paymentMethod) {
    return 'Copy the $identifier and head to $paymentMethod to pay the amount';
  }

  @override
  String get merchantCode => 'merchant code';

  @override
  String get merchantCodeLabel => 'Merchant Code';

  @override
  String get phoneNumber => 'phone number';

  @override
  String get phoneNumberLabel => 'Phone Number';

  @override
  String get existingPaymentWasFound =>
      'An existing pending payment was found. Please wait for the previous payment to be processed.';

  @override
  String get authorizationRequired => 'API key is required';

  @override
  String get invalidAuthorizationOrganizationNotFound =>
      'Invalid API key, organization not found';

  @override
  String get fileNotFound => 'File not found';

  @override
  String get authenticationBPayFailed => 'Authentication BPay failed';

  @override
  String get configurationNotFound => 'Configuration not found';

  @override
  String get paymentRequestNotFound => 'Payment request not found';

  @override
  String get paymentNotFound => 'Payment not found';

  @override
  String get errorWhileCreatingPayment => 'Error while creating payment';

  @override
  String get errorWhileCreatingPaymentRequest =>
      'Error while creating paymentRequest';

  @override
  String get organizationNotFound => 'Organization not found';

  @override
  String get invalidAuthorization => 'Invalid API key';

  @override
  String get change => 'Change';

  @override
  String get sending => 'Sending...';

  @override
  String get processingError => 'processing Error';

  @override
  String get nonExistentOperation => 'Non-existent operation';

  @override
  String get phoneNumberRequired => 'Phone number is required';

  @override
  String get validMauritanianNumber => 'Enter a valid Mauritanian phone number';

  @override
  String get codeRequired => 'Code is required';

  @override
  String get validDigitCode => 'Enter a valid 4-digit code';
}
