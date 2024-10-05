/// A model representing an operation in the payment system.
///
/// This model holds information about a specific operation, including
/// an identifier, the phone number associated with the operation,
/// and the amount involved in the operation.
class OperationModel {
  /// The unique identifier for the operation.
  final String id;

  /// The phone number associated with the operation.
  final String phoneNumber;

  /// The amount involved in the operation.
  final double amount;

  /// Creates an instance of [OperationModel].
  ///
  /// Requires [id], [phoneNumber], and [amount] to initialize the model.
  OperationModel({
    required this.id,
    required this.phoneNumber,
    required this.amount,
  });

  /// Creates an instance of [OperationModel] from a map.
  ///
  /// The [map] must contain the keys 'id', 'phone_number', and 'amount'
  /// to successfully initialize the properties of the model.
  OperationModel.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        phoneNumber = map['phone_number'],
        amount = map['amount'];
}
