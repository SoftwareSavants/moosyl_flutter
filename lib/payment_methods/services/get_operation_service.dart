import 'package:software_pay/helpers/fetcher.dart';
import 'package:software_pay/payment_methods/models/operation_model.dart';

class GetOperationService {
  final String apiKey;

  GetOperationService(this.apiKey);

  Future<OperationModel> get(String operationId) async {
    final methodsResult = await Fetcher(apiKey).get(
      Endpoints.operation(operationId),
    );

    return OperationModel.fromMap(methodsResult.data);
  }
}
