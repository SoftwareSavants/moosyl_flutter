class OperationModel {
  final String id;
  final String phoneNumber;
  final double amount;

  OperationModel({
    required this.id,
    required this.phoneNumber,
    required this.amount,
  });
  //fromMap
  OperationModel.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        phoneNumber = map['phone_number'],
        amount = map['amount'];
}
