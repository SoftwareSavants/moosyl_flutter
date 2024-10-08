import 'software_pay_localization.dart';

/// The translations for French (`fr`).
class SoftwarePayLocalizationFr extends SoftwarePayLocalization {
  SoftwarePayLocalizationFr([String locale = 'fr']) : super(locale);

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
  String get enterYourBankilyPhoneNumber =>
      'Entrez votre numéro de téléphone Bankily';

  @override
  String get bankilyPhoneNumber => 'Numéro de téléphone Bankily';

  @override
  String get paymentPassCode => 'Code de passe de paiement';

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
  String get merchantCode => 'Code marchand';

  @override
  String get copyTheMerchantCodeAndHeadToSedadToPayTheAmount =>
      'Copiez le code marchand et rendez-vous sur Sedad pour payer le montant et faire une capture d'
      'écran';
}
