import 'software_pay_localization.dart';

/// The translations for Arabic (`ar`).
class SoftwarePayLocalizationAr extends SoftwarePayLocalization {
  SoftwarePayLocalizationAr([String locale = 'ar']) : super(locale);

  @override
  String get unknownError => 'حدث خطأ غير معروف';

  @override
  String get copiedThisText => 'تم نسخ هذا النص';

  @override
  String get paymentMethod => 'طريقة الدفع';

  @override
  String get bankily => 'بنكيلي';

  @override
  String get sedad => 'سداد';

  @override
  String get bimBank => 'بنك BIM';

  @override
  String get masrivi => 'مصريفي';

  @override
  String get amanty => 'أمانتي';

  @override
  String get bCIpay => 'BCI Pay';

  @override
  String payUsing(Object method) {
    return 'ادفع باستخدام $method';
  }

  @override
  String get copyTheCodeBPayAndHeadToBankilyToPayTheAmount =>
      'انسخ الرمز، BPay وتوجه إلى بنكيلي لدفع المبلغ';

  @override
  String get afterPayment => 'بعد الدفع';

  @override
  String get afterMakingThePaymentFillTheFollowingInformation =>
      'بعد إتمام الدفع، املأ المعلومات التالية';

  @override
  String get enterYourBankilyPhoneNumber => 'أدخل رقم هاتفك الخاص ببنكيلي';

  @override
  String get bankilyPhoneNumber => 'رقم هاتف بنكيلي';

  @override
  String get paymentPassCode => 'رمز المرور للدفع';

  @override
  String get paymentPassCodeFromBankily => 'رمز المرور للدفع من بنكيلي';

  @override
  String get sendForVerification => 'أرسل للتحقق';

  @override
  String get codeBPay => 'رمز BPay';

  @override
  String get amountToPay => 'المبلغ الواجب دفعه';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get merchantCode => 'رمز التاجر';

  @override
  String get copyTheMerchantCodeAndHeadToSedadToPayTheAmount =>
      'انسخ كود التاجر وتوجه إلى سداد لدفع المبلغ وخذ لقطة شاشة';
}
