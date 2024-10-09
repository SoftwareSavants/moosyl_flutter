import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:moosyl/l10n/generated/software_pay_localization.dart';

import 'package:moosyl/src/helpers/exception_handling/exceptions.dart';

/// A class responsible for making HTTP requests to the server.
/// It allows for sending GET and POST requests with predefined headers.
class Fetcher {
  /// Constructs a [Fetcher] with the provided [apiKey].
  Fetcher(this.apiKey);

  /// The API key used to authenticate the requests.
  String apiKey;

  /// Returns the HTTP headers including the `api_key`.
  Map<String, String> get headers {
    final headers = <String, String>{
      'content-type': 'application/json',
    };

    headers['api_key'] = apiKey;

    return headers;
  }

  /// Sends a GET request to the given [url] and returns a [FetcherResponse].
  ///
  /// The optional [bytes] parameter specifies if the response should return
  /// bytes instead of a decoded response body. Throws an exception if the
  /// response is unsuccessful.
  Future<FetcherResponse> get(String url, {bool bytes = false}) async {
    final response = await http
        .get(Uri.parse(url), headers: headers)
        .timeout(const Duration(minutes: 1));

    final res = FetcherResponse.fromHttpResponse(response, bytes: bytes);

    if (!res.success) throw res.toException;

    return res;
  }

  /// Sends a POST request to the given [url] with an optional [body].
  ///
  /// The body should be a [Map] that will be encoded to JSON. Throws an
  /// exception if the response is unsuccessful.
  Future<FetcherResponse> post(String url, {Map<String, dynamic>? body}) async {
    final response = await http
        .post(
          Uri.parse(url),
          body: json.encode(body),
          headers: headers,
        )
        .timeout(const Duration(minutes: 1));

    final res = FetcherResponse.fromHttpResponse(response);

    if (!res.success) throw res.toException;

    return res;
  }
}

/// A class that represents the response returned from the [Fetcher].
///
/// Contains the [url], [status], and the [data] of the response.
class FetcherResponse<T> {
  /// The URL that was used in the request.
  final String url;

  /// The HTTP status code returned by the server.
  final int status;

  /// The response body data, can be of any type [T].
  final T? data;

  /// A boolean indicating if the response was successful (status code between 200 and 299).
  bool get success => status >= 200 && status <= 299;

  /// Converts the raw HTTP response body [String] to a dynamic object.
  ///
  /// Attempts to parse the body as JSON. If parsing fails, it returns the original body as-is.
  static dynamic httpResponseBodyConvertor(String body) {
    dynamic result = body;

    try {
      result = json.decode(body);
    } catch (error) {/* ignored */}

    return result;
  }

  /// Constructs a [FetcherResponse] with the given [url], [status], and [data].
  const FetcherResponse({
    required this.url,
    required this.status,
    required this.data,
  });

  /// Factory constructor that creates a [FetcherResponse] from an [http.Response].
  ///
  /// The optional [bytes] parameter specifies if the response should return
  /// bytes instead of a decoded response body.
  FetcherResponse.fromHttpResponse(http.Response response, {bool bytes = false})
      : url = response.request?.url.toString() ?? '',
        status = response.statusCode,
        data = bytes
            ? response.bodyBytes
            : httpResponseBodyConvertor(response.body);

  /// Strips HTML tags and special characters from the given [text].
  ///
  /// This is useful for cleaning up error messages returned by the server.
  String stripHtmlIfNeeded(String text) {
    return text.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ');
  }

  /// Converts the response to an [AppException].
  ///
  /// This method extracts the error message from the server response and returns
  /// a properly formatted exception.
  AppException toException(BuildContext context) {
    Map<String, dynamic> body = data as Map<String, dynamic>;

    String message = SoftwarePayLocalization.of(context)!.unknownError;

    if (body['_server_messages'] != null) {
      final dynamic parsedJson = jsonDecode(body['_server_messages']);
      message = stripHtmlIfNeeded(jsonDecode(parsedJson.first)['message']);
    }

    return AppException(code: AppExceptionCode.unknown, message: message);
  }
}

/// A static class containing the URLs for various API endpoints.
class Endpoints {
  /// The base URL of the API.
  static const String baseUrl = 'http://localhost:3000';

  /// The URL for retrieving payment method configurations.
  static const String paymentMethods = '$baseUrl/configuration';

  /// Returns the URL for processing payment for the given [id].
  static String get pay => '$baseUrl/payment';

  /// Returns the URL for retrieving details of a specific transaction with the given [id].
  static String paymentRequest(String id) => '$baseUrl/payment_request/$id';
}
