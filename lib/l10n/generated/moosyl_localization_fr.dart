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
      '1- Copiez le code, BPay et dirigez-vous vers Bankily pour payer le montant';

  @override
  String get afterPayment => 'Après paiement';

  @override
  String get afterMakingThePaymentFillTheFollowingInformation =>
      '2- Après avoir effectué le paiement, téléchargez une image de la transaction';

  @override
  String
      get afterMakingThePaymentFillTheFollowingInformationWithTheBankilyPhoneNumber =>
          'Après avoir effectué le paiement, entrez le code généré par Bankily';

  @override
  String get enterYourBankilyPhoneNumber =>
      '№ téléphone avec lequel vous avez payé';

  @override
  String get bankilyPhoneNumber => 'Numéro de téléphone Bankily';

  @override
  String get paymentPassCode => 'Le code de la transaction';

  @override
  String get paymentPassCodeFromBankily =>
      'Code de passe de paiement de Bankily';

  @override
  String get sendForVerification => 'Envoyer pour vérification';

  @override
  String get codeBPay => 'Code BPay';

  @override
  String get amountToPay => 'Montant à payer';

  @override
  String get retry => 'Réessayer';

  @override
  String get upload => 'Télécharger';

  @override
  String get capture => 'Capturer';

  @override
  String copyTheMerchantCodeAndHeadToMethodToPayTheAmount(Object method) {
    return '1- Copiez le code et dirigez-vous vers $method pour payer le montant';
  }

  @override
  String copyThePhoneNumberAndHeadToMethodToPayTheAmount(Object method) {
    return '1- Copiez le numéro de téléphone et dirigez-vous vers $method pour payer le montant';
  }

  @override
  String get merchantCode => 'Code marchand';

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
  String get errorWhilePaying =>
      'Une erreur s’est produite lors du processus de paiement. Veuillez vérifier le numéro de téléphone et le code de la transaction ! Si la transaction échoue à nouveau, nous vous prions de contacter notre centre d’appel.';

  @override
  String get enterYourPaymentInformation =>
      '2- Après avoir effectué le paiement, entrez le code dans le champ ci-dessous';

  @override
  String get ourPhoneNumber => 'Notre numéro de téléphone';
}
