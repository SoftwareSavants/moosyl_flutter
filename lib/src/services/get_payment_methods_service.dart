import 'package:moosyl/moosyl.dart';

/// Base URL for the Moosyl API (matches the original fetcher endpoint).
const String _defaultBaseUrl = 'https://moosyl.moosyl.workers.dev';

/// A service class for fetching available payment methods.
///
/// This class provides methods to interact with the backend and retrieve
/// a list of payment methods using the Moosyl Dart SDK [ConfigurationApi].
class GetPaymentMethodsService {
  /// The API key used for authentication with the backend.
  final String publishableApiKey;

  /// Optional base URL override (defaults to [_defaultBaseUrl]).
  final String? baseUrlOverride;

  /// Constructs a [GetPaymentMethodsService] with the provided [publishableApiKey].
  GetPaymentMethodsService(
    this.publishableApiKey, {
    this.baseUrlOverride,
  });

  /// Fetches the available payment methods from the backend.
  ///
  /// Makes an API call via [ConfigurationApi] to retrieve the payment methods.
  /// Returns a list of [PaymentMethod] objects.
  Future<List<ConfigurationListDataInner>> get() async {
    final client = Moosyl(
      basePathOverride: baseUrlOverride ?? _defaultBaseUrl,
    );

    client.setApiKey('ApiKey', publishableApiKey);

    final config = client.getConfigurationApi();
    final response = await config.getConfiguration();

    final data = response.data;
    if (data == null) {
      return [];
    }

    return data.data.toList();
  }
}
