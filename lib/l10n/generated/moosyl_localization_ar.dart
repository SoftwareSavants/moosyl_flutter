import 'moosyl_localization.dart';

// ignore_for_file: type=lint

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
  String get bimBank => 'بيم بنك';

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
      '1- انسخ الرمز، BPay وتوجه إلى بنكيلي لدفع المبلغ';

  @override
  String get afterPayment => 'بعد الدفع';

  @override
  String get afterMakingThePaymentFillTheFollowingInformation =>
      '2- بعد اتمام عملية الدفع قم بتحميل صورة من المعاملة';

  @override
  String
      get afterMakingThePaymentFillTheFollowingInformationWithTheBankilyPhoneNumber =>
          '2- بعد اتمام عملية الدفع قم بإدخال الرمز المولد من بنكيلي';

  @override
  String get enterYourBankilyPhoneNumber => 'رقم الهاتف الذي قمت بالدفع منه';

  @override
  String get bankilyPhoneNumber => 'رقم هاتف بنكيلي';

  @override
  String get paymentPassCode => 'رمز المعاملة';

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
  String get upload => 'تحميل';

  @override
  String get capture => 'التقاط';

  @override
  String copyTheMerchantCodeAndHeadToMethodToPayTheAmount(Object method) {
    return '1- انسخ الرمز وتوجه إلى $method لدفع المبلغ';
  }

  @override
  String copyThePhoneNumberAndHeadToMethodToPayTheAmount(Object method) {
    return '1- انسخ رقم الهاتف وتوجه إلى $method لدفع المبلغ';
  }

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

  @override
  String get phoneNumberRequired => 'رقم الهاتف مطلوب';

  @override
  String get validMauritanianNumber => 'أدخل رقم هاتف موريتاني صالح';

  @override
  String get codeRequired => 'الرمز مطلوب';

  @override
  String get validDigitCode => 'أدخل رمزًا صالحًا مكونًا من 4 أرقام';

  @override
  String get errorWhilePaying =>
      'حدث خطأ ما في عملية الدفع، يرجى التحقق من رقم الهاتف و رمز المعاملة!في حالة عدم نجاح المعاملة مرة أخرى، نرجوا منك التواصل مع مركز الاتصال الخاص بنا!';

  @override
  String get enterYourPaymentInformation => '2- أدخل معلومات الدفع الخاصة بك';

  @override
  String get ourPhoneNumber => 'رقم الهاتف الخاص بنا';
}
