// ignore: unused_import
import 'package:intl/intl.dart' as intl;
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
  String get enterYourBankilyPhoneNumber => 'أدخل رقم هاتفك';

  @override
  String get bankilyPhoneNumber => 'رقم هاتف بنكيلي';

  @override
  String get paymentPassCode => 'رمز المرور للدفع';

  @override
  String get codeBPay => 'رمز BPay';

  @override
  String get amountToPay => 'المبلغ الواجب دفعه';

  @override
  String get choosePaymentMethods => 'اختر طريقة الدفع';

  @override
  String get tax => 'الضريبة';

  @override
  String get pay => 'ادفع';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get upload => 'رفع';

  @override
  String get capture => 'التقاط';

  @override
  String copyTheMerchantCodeAndHeadToSedadToPayTheAmount(
      Object identifier, Object paymentMethod) {
    return 'انسخ $identifier التاجر وتوجه إلى $paymentMethod لدفع المبلغ';
  }

  @override
  String get merchantCode => 'رمز';

  @override
  String get merchantCodeLabel => 'رمز التاجر';

  @override
  String get phoneNumber => 'رقم هاتف';

  @override
  String get phoneNumberLabel => 'رقم الهاتف';

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
  String get totalAmount => 'المبلغ الإجمالي';

  @override
  String get paymentSummary => 'ملخص الدفع';

  @override
  String get paymentCode => 'رمز الدفع';

  @override
  String get ivePaid => 'لقد دفعت';

  @override
  String get usePaymentCodeAboveToComplete =>
      'استخدم رمز الدفع أعلاه لإكمال الدفع في تطبيق سداد، ثم اضغط على الزر أدناه.';

  @override
  String get paymentRequestFullyPaid => 'تم دفع طلب الدفع هذا بالكامل.';

  @override
  String get amountToPayShouldMatchPaymentRequest =>
      'يجب أن يتطابق المبلغ المطلوب دفعه مع مبلغ طلب الدفع.';

  @override
  String get selected => 'محدد';

  @override
  String get tapToUse => 'اضغط للاستخدام';

  @override
  String get chooseHowYouWouldLikeToPay => 'اختر كيف تريد الدفع';

  @override
  String get useThisCodeToCompletePayment => 'استخدم هذا الرمز لإكمال الدفع';

  @override
  String get sedadStep1 => '1. افتح تطبيق سداد';

  @override
  String get sedadStep2 => '2. انتقل إلى الدفع';

  @override
  String get sedadStep3 => '3. الصق أو أدخل الرمز لتأكيد الدفع';

  @override
  String get sedadStep4 => '4. ارجع إلى هذه الصفحة وانقر على \"لقد دفعت\"';

  @override
  String get changePaymentMethod => 'تغيير طريقة الدفع';

  @override
  String get clickToCopy => 'انقر للنسخ';

  @override
  String get bankilyStep1 => '1. افتح تطبيق بنكيلي';

  @override
  String get bankilyStep2 => '2. انتقل إلى BPay';

  @override
  String get bankilyStep3 => '3. أدخل رمز BPay والمبلغ المطلوب دفعه';

  @override
  String get bankilyStep4 =>
      '4. ارجع هنا، أدخل رقمك ورمز المرور، ثم انقر على ادفع';

  @override
  String get paymentNotCompleted => 'لم يتم إكمال الدفع';

  @override
  String get paymentSuccessful => 'تم الدفع بنجاح';

  @override
  String get paymentId => 'معرف الدفع';

  @override
  String get status => 'الحالة';

  @override
  String get paymentFailed => 'فشل الدفع';

  @override
  String get paymentDeclined =>
      'فشل الدفع. قد يكون رصيدك غير كافٍ أو قد يكون حسابك غير نشط.';
}
