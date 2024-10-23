/// A model representing an  Payment Request in the payment system.
///
/// This model holds information about a specific  Payment Request, including
/// an identifier, the phone number associated with the  Payment Request,
/// and the amount involved in the  Payment Request.
class PaymentRequestModel {
  /// The unique identifier for the  Payment Request.
  final String id;

  /// The phone number associated with the  Payment Request.
  final String? phoneNumber;

  /// The amount involved in the  Payment Request.
  final double amount;

  /// Creates an instance of [PaymentRequestModel].
  ///
  /// Requires [id], [phoneNumber], and [amount] to initialize the model.
  PaymentRequestModel({
    required this.id,
    this.phoneNumber,
    required this.amount,
  });

  /// Creates an instance of [PaymentRequestModel] from a map.
  ///
  /// The [map] must contain the keys 'id', 'phone_number', and 'amount'
  /// to successfully initialize the properties of the model.
  PaymentRequestModel.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        phoneNumber = map['phoneNumber'],
        amount = map['amount'].toDouble();
}
