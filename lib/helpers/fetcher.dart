import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:software_pay/helpers/exception_handling/exceptions.dart';

class Fetcher {
  Fetcher(this.apiKey);

  String apiKey;

  Map<String, String> get headers {
    final headers = <String, String>{
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    headers['api_key'] = apiKey;

    return headers;
  }

  Future<FetcherResponse> get(String url, {bool bytes = false}) async {
    final response = await http
        .get(Uri.parse(url), headers: headers)
        .timeout(const Duration(minutes: 1));

    final res = FetcherResponse.fromHttpResponse(response, bytes: bytes);

    if (!res.success) throw res.toException;

    return res;
  }

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

class FetcherResponse<T> {
  final String url;
  final int status;
  final T? data;

  bool get success => status >= 200 && status <= 299;

  static dynamic httpResponseBodyConvertor(String body) {
    dynamic result = body;

    try {
      result = json.decode(body);
    } catch (error) {/* ignored */}

    return result;
  }

  const FetcherResponse({
    required this.url,
    required this.status,
    required this.data,
  });

  FetcherResponse.fromHttpResponse(http.Response response, {bool bytes = false})
      : url = response.request?.url.toString() ?? '',
        status = response.statusCode,
        data = bytes
            ? response.bodyBytes
            : httpResponseBodyConvertor(response.body);

  String stripHtmlIfNeeded(String text) {
    return text.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ');
  }

  AppException get toException {
    Map<String, dynamic> body = data as Map<String, dynamic>;

    //TODO: translate this
    String message = "LocalizationsHelper.msgs.unknownErrorMsg";

    if (body['_server_messages'] != null) {
      final dynamic parsedJson = jsonDecode(body['_server_messages']);
      message = stripHtmlIfNeeded(jsonDecode(parsedJson.first)['message']);
    }

    return AppException(code: AppExceptionCode.unknown, message: message);
  }
}

class Endpoints {
  static const String baseUrl = 'http://localhost:3000';

  static const String paymentMethods = '$baseUrl/configuration';
  static String pay(String id) => '$baseUrl/payment';
  static String operation(String id) => '$baseUrl/operation/$id';
}
