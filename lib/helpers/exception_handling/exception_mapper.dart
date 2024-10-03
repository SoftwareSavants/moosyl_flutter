import 'dart:async';
import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:software_pay/helpers/exception_handling/exceptions.dart';
import 'package:software_pay/l10n/localization_helper.dart';

class ExceptionMapper {
  static String mapException(Object? e) {
    if (e is SocketException) {
      return "No internet connection";
    } else if (e is TimeoutException) {
      return "Request timed out";
    } else if (e is HttpException) {
      return "Failed to load data";
    } else if (e is FormatException) {
      return "Invalid response";
    } else {
      return "An error occurred";
    }
  }

  static String getErrorMessage(error) {
    final localizationsHelper = GetIt.I.get<LocalizationsHelper>();
    return switch (error) {
      AppException(code: AppExceptionCode code) => switch (code) {
          AppExceptionCode.unknown => localizationsHelper.msgs.unknownError,
          _ => localizationsHelper.msgs.unknownError,
        },
      _ => localizationsHelper.msgs.unknownError,
    };
  }
}
