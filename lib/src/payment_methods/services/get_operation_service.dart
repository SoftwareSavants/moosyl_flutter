import 'package:software_pay/src/helpers/fetcher.dart';
import 'package:software_pay/src/payment_methods/models/operation_model.dart';

/// A service class for fetching operation details.
///
/// This class provides methods to interact with the backend and retrieve
/// operation information based on the operation ID.
class GetOperationService {
  /// The API key used for authentication with the backend.
  final String apiKey;

  /// Constructs a [GetOperationService] with the provided [apiKey].
  GetOperationService(this.apiKey);

  /// Fetches operation details for the specified [operationId].
  ///
  /// Makes an API call to retrieve the operation information.
  /// Returns an [OperationModel] object containing the operation details.
  Future<OperationModel> get(String operationId) async {
    // Fetch the operation details from the backend.
    final methodsResult = await Fetcher(apiKey).get(
      Endpoints.operation(operationId),
    );

    // Convert the result data to an OperationModel instance.
    return OperationModel.fromMap(methodsResult.data);
  }
}
