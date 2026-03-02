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
  String get enterYourBankilyPhoneNumber => 'Enter phone number';

  @override
  String get bankilyPhoneNumber => 'Bankily Phone Number';

  @override
  String get paymentPassCode => 'Payment Code';

  @override
  String get codeBPay => 'Code BPay';

  @override
  String get amountToPay => 'Amount to pay';

  @override
  String get choosePaymentMethods => 'Choose payment method';

  @override
  String get tax => 'Tax';

  @override
  String get pay => 'Pay';

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

  @override
  String get totalAmount => 'Total Amount';

  @override
  String get paymentSummary => 'Payment Summary';

  @override
  String get paymentCode => 'Payment Code';

  @override
  String get ivePaid => 'I\'ve paid';

  @override
  String get usePaymentCodeAboveToComplete =>
      'Use the payment code above to complete your payment in the Sedad app, then tap the button below.';

  @override
  String get paymentRequestFullyPaid => 'This payment request has fully paid.';

  @override
  String get amountToPayShouldMatchPaymentRequest =>
      'Amount to pay should match payment request amount.';

  @override
  String get selected => 'Selected';

  @override
  String get tapToUse => 'Tap to use';

  @override
  String get chooseHowYouWouldLikeToPay => 'Choose how you would like to pay';

  @override
  String get useThisCodeToCompletePayment =>
      'Use this code to complete payment';

  @override
  String get sedadStep1 => '1. Open the Sedad app';

  @override
  String get sedadStep2 => '2. Go to payment';

  @override
  String get sedadStep3 => '3. Paste or enter the code to confirm payment';

  @override
  String get sedadStep4 => '4. Return to this page and click \"I\'ve paid\"';

  @override
  String get changePaymentMethod => 'Change payment method';

  @override
  String get clickToCopy => 'Click to copy';

  @override
  String get bankilyStep1 => '1. Open the Bankily app';

  @override
  String get bankilyStep2 => '2. Go to BPay';

  @override
  String get bankilyStep3 => '3. Enter the BPay code and amount to pay';

  @override
  String get bankilyStep4 =>
      '4. Return here, enter your phone and passcode, then click Pay';

  @override
  String get paymentNotCompleted => 'Payment not completed';

  @override
  String get paymentSuccessful => 'Payment successful';

  @override
  String get paymentId => 'Payment ID';

  @override
  String get status => 'Status';

  @override
  String get tryAgain => 'Try again';

  @override
  String get paymentFailed => 'Payment failed';

  @override
  String get paymentDeclined =>
      'Your balance may be insufficient or your account may not be active.';
}
