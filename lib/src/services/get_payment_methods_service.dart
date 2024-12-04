import 'package:moosyl/src/helpers/fetcher.dart';
import 'package:moosyl/src/models/payment_method_model.dart';

/// A service class for fetching available payment methods.
///
/// This class provides methods to interact with the backend and retrieve
/// a list of payment methods.
class GetPaymentMethodsService {
  /// The API key used for authentication with the backend.
  final String publishableApiKey;

  /// Constructs a [GetPaymentMethodsService] with the provided [publishableApiKey].
  GetPaymentMethodsService(this.publishableApiKey);

  /// Fetches the available payment methods from the backend.
  ///
  /// Makes an API call to retrieve the payment methods.
  /// Returns a list of [PaymentMethod] objects.
  Future<List<PaymentMethod>> get(bool isTestingMode) async {
    // Fetch the payment methods from the backend.
    final methodsResult = await Fetcher(publishableApiKey).get(
      Endpoints.paymentMethods(isTestingMode),
    );

    // Convert the result data to a list of PaymentMethod instances.
    return List.from(methodsResult.data["data"])
        .map<PaymentMethod>((e) => PaymentMethod.fromPaymentType(e))
        .toList();
  }
}
