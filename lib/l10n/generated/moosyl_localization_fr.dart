// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'moosyl_localization.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class MoosylLocalizationFr extends MoosylLocalization {
  MoosylLocalizationFr([String locale = 'fr']) : super(locale);

  @override
  String get unknownError => 'Une erreur inconnue s\'\'est produite';

  @override
  String get copiedThisText => 'Texte copié';

  @override
  String get paymentMethod => 'Méthode de paiement';

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
    return 'Payer avec $method';
  }

  @override
  String get copyTheCodeBPayAndHeadToBankilyToPayTheAmount =>
      'Copiez le code, BPay et dirigez-vous vers Bankily pour payer le montant';

  @override
  String get afterPayment => 'Après paiement';

  @override
  String get afterMakingThePaymentFillTheFollowingInformation =>
      'Après avoir effectué le paiement, remplissez les informations suivantes';

  @override
  String get enterYourBankilyPhoneNumber => 'Entrez votre numéro';

  @override
  String get bankilyPhoneNumber => 'Numéro de téléphone Bankily';

  @override
  String get paymentPassCode => 'Code de passe de paiement';

  @override
  String get codeBPay => 'Code BPay';

  @override
  String get amountToPay => 'Montant à payer';

  @override
  String get choosePaymentMethods => 'Choisir le mode de paiement';

  @override
  String get tax => 'Taxe';

  @override
  String get pay => 'Payer';

  @override
  String get retry => 'Réessayer';

  @override
  String get upload => 'Télécharger';

  @override
  String get capture => 'Capturer';

  @override
  String copyTheMerchantCodeAndHeadToSedadToPayTheAmount(
      Object identifier, Object paymentMethod) {
    return 'Copiez le $identifier et dirigez-vous vers $paymentMethod pour payer le montant';
  }

  @override
  String get merchantCode => 'code marchand';

  @override
  String get merchantCodeLabel => 'Code Marchand';

  @override
  String get phoneNumber => 'numéro de téléphone';

  @override
  String get phoneNumberLabel => 'Numéro de Téléphone';

  @override
  String get existingPaymentWasFound =>
      'Un paiement en attente a été trouvé. Veuillez attendre que le paiement précédent soit traité.';

  @override
  String get authorizationRequired => 'Clé API requise';

  @override
  String get invalidAuthorizationOrganizationNotFound =>
      'Clé API invalide, organisation non trouvée';

  @override
  String get fileNotFound => 'Fichier introuvable';

  @override
  String get authenticationBPayFailed => 'Échec de l\'authentification BPay';

  @override
  String get configurationNotFound => 'Configuration introuvable';

  @override
  String get paymentRequestNotFound => 'Demande de paiement introuvable';

  @override
  String get paymentNotFound => 'Paiement introuvable';

  @override
  String get errorWhileCreatingPayment =>
      'Erreur lors de la création du paiement';

  @override
  String get errorWhileCreatingPaymentRequest =>
      'Erreur lors de la création de la demande de paiement';

  @override
  String get organizationNotFound => 'Organisation introuvable';

  @override
  String get invalidAuthorization => 'Clé API invalide';

  @override
  String get change => 'Changer';

  @override
  String get sending => 'Envoi...';

  @override
  String get processingError => 'Erreur de Traitments';

  @override
  String get nonExistentOperation => 'Opération inexistante';

  @override
  String get phoneNumberRequired => 'Le numéro de téléphone est obligatoire';

  @override
  String get validMauritanianNumber =>
      'Entrez un numéro de téléphone mauritanien valide';

  @override
  String get codeRequired => 'Le code est obligatoire';

  @override
  String get validDigitCode => 'Entrez un code à 4 chiffres valide';

  @override
  String get totalAmount => 'Montant total';

  @override
  String get paymentSummary => 'Résumé du paiement';

  @override
  String get paymentCode => 'Code de paiement';

  @override
  String get ivePaid => 'J\'ai payé';

  @override
  String get usePaymentCodeAboveToComplete =>
      'Utilisez le code de paiement ci-dessus pour finaliser votre paiement dans l\'application Sedad, puis appuyez sur le bouton ci-dessous.';

  @override
  String get paymentRequestFullyPaid =>
      'Cette demande de paiement est entièrement payée.';

  @override
  String get amountToPayShouldMatchPaymentRequest =>
      'Le montant à payer doit correspondre au montant de la demande de paiement.';

  @override
  String get selected => 'Sélectionné';

  @override
  String get tapToUse => 'Appuyez pour utiliser';

  @override
  String get chooseHowYouWouldLikeToPay =>
      'Choisissez comment vous souhaitez payer';

  @override
  String get useThisCodeToCompletePayment =>
      'Utilisez ce code pour finaliser le paiement';

  @override
  String get sedadStep1 => '1. Ouvrez l\'application Sedad';

  @override
  String get sedadStep2 => '2. Allez dans paiement';

  @override
  String get sedadStep3 =>
      '3. Collez ou saisissez le code pour confirmer le paiement';

  @override
  String get sedadStep4 =>
      '4. Revenez sur cette page et cliquez sur \"J\'ai payé\"';

  @override
  String get changePaymentMethod => 'Changer de méthode de paiement';

  @override
  String get clickToCopy => 'Cliquez pour copier';

  @override
  String get bankilyStep1 => '1. Ouvrez l\'application Bankily';

  @override
  String get bankilyStep2 => '2. Allez dans BPay';

  @override
  String get bankilyStep3 => '3. Saisissez le code BPay et le montant à payer';

  @override
  String get bankilyStep4 =>
      '4. Revenez ici, entrez votre numéro et code, puis cliquez sur Payer';

  @override
  String get paymentNotCompleted => 'Paiement non terminé';

  @override
  String get paymentSuccessful => 'Paiement réussi';

  @override
  String get paymentId => 'ID de paiement';

  @override
  String get status => 'Statut';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get paymentFailed => 'Échec du paiement';

  @override
  String get paymentDeclined =>
      'Votre solde est peut-être insuffisant ou votre compte n\'est peut-être pas actif.';

  @override
  String get gimtelPhoneTitle => 'Depuis quel numéro allez-vous payer ?';

  @override
  String gimtelPhoneLabel(String app) {
    return 'Votre numéro $app';
  }

  @override
  String gimtelPhoneHint(String app) {
    return 'Le numéro de votre compte $app. Il nous permet de reconnaître votre paiement.';
  }

  @override
  String get gimtelContinue => 'Continuer';

  @override
  String get gimtelInvalidPhone =>
      'Saisissez un numéro mauritanien valide à 8 chiffres';

  @override
  String gimtelPayTitle(String app) {
    return 'Payez via <g>Gimtel</g> dans $app';
  }

  @override
  String get gimtelViaGimtel => 'Via Gimtel';

  @override
  String get gimtelMerchantNumber => 'Numéro marchand';

  @override
  String get gimtelAmount => 'Montant';

  @override
  String get gimtelTapToCopy => 'Touchez pour copier';

  @override
  String get gimtelCopied => 'Copié';

  @override
  String gimtelBankilyS1(String app) {
    return 'Dans $app, touchez <g>Gimtel</g>';
  }

  @override
  String get gimtelBankilyS2 => 'Touchez <b>Pay Merchant</b>';

  @override
  String get gimtelBankilyS3 =>
      'Remplissez les champs en surbrillance, puis <b>Next</b>';

  @override
  String get gimtelBankilyS4 =>
      'Touchez <b>Continue</b>, puis saisissez votre PIN';

  @override
  String gimtelBciPayS1(String app) {
    return 'Dans $app, touchez <b>Payments</b>';
  }

  @override
  String get gimtelBciPayS2 => 'Passez à <g>GIMTEL</g>';

  @override
  String get gimtelBciPayS3 =>
      'Choisissez <b>BIMBANK</b>, saisissez le numéro, puis <b>Continue</b>';

  @override
  String get gimtelBciPayS4 => 'Saisissez le montant, puis <b>Pay</b>';

  @override
  String gimtelGenericStep1(String app) {
    return 'Ouvrez $app → <g>Gimtel</g> → <b>Pay Merchant</b>';
  }

  @override
  String gimtelGenericStep2(String phone, String amount) {
    return 'Choisissez <b>BIMBANK</b>, saisissez <n>$phone</n> et <n>$amount</n>';
  }

  @override
  String get gimtelGenericStep3 => 'Confirmez avec votre code PIN';

  @override
  String get gimtelWaitingTitle => 'En attente de votre paiement';

  @override
  String gimtelWaitingHint(String phone) {
    return 'Payez depuis le <n>$phone</n>, montant exact. Gardez cette page ouverte.';
  }

  @override
  String get gimtelSimulate => 'Simuler le virement (sandbox)';

  @override
  String get gimtelChangeNumber => 'Changer de numéro';

  @override
  String get gimtelOtherMethod => 'Autre moyen de paiement';

  @override
  String get gimtelExpiredTitle => 'Ce paiement a expiré';

  @override
  String get gimtelExpiredDescription =>
      'Si vous avez déjà envoyé l\'argent, il vous sera remboursé.';

  @override
  String get gimtelInactiveTitle => 'Ce paiement n\'est plus actif';

  @override
  String get gimtelInactiveDescription =>
      'Recommencez pour obtenir de nouvelles instructions de paiement.';

  @override
  String get gimtelStartAgain => 'Recommencer';
}
