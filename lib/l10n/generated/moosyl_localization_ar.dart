import 'moosyl_localization.dart';

/// The translations for Arabic (`ar`).
class MoosylLocalizationAr extends MoosylLocalization {
  MoosylLocalizationAr([String locale = 'ar']) : super(locale);

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
  String get upload => 'رفع';

  @override
  String get capture => 'التقاط';

  @override
  String get copyTheMerchantCodeAndHeadToSedadToPayTheAmount =>
      'انسخ رمز التاجر وتوجه إلى سداد لدفع المبلغ';

  @override
  String get merchantCode => 'رمز التاجر';

  @override
  String get existingPaymentWasFound =>
      'تم العثور على دفعة معلقة موجودة. يرجى الانتظار حتى يتم معالجة الدفعة السابقة.';

  @override
  String get authorizationRequired => 'مطلوب مفتاح API';

  @override
  String get invalidAuthorizationOrganizationNotFound =>
      'مفتاح API غير صالح، لم يتم العثور على المؤسسة';

  @override
  String get fileNotFound => 'الملف غير موجود';

  @override
  String get authenticationBPayFailed => 'فشل مصادقة BPay';

  @override
  String get configurationNotFound => 'لم يتم العثور على الإعدادات';

  @override
  String get paymentRequestNotFound => 'لم يتم العثور على طلب الدفع';

  @override
  String get paymentNotFound => 'لم يتم العثور على الدفعة';

  @override
  String get errorWhileCreatingPayment => 'حدث خطأ أثناء إنشاء الدفعة';

  @override
  String get errorWhileCreatingPaymentRequest =>
      'حدث خطأ أثناء إنشاء طلب الدفع';

  @override
  String get organizationNotFound => 'لم يتم العثور على المؤسسة';

  @override
  String get invalidAuthorization => 'مفتاح API غير صالح';

  @override
  String get change => 'تغيير';

  @override
  String get sending => 'جاري الإرسال...';

  @override
  String get processingError => 'خطأ في المعالجة';

  @override
  String get nonExistentOperation => 'العملية غير موجودة';
}
