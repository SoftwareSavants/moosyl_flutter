import 'dart:async';
import 'package:software_pay/src/helpers/exception_handling/exceptions.dart';
import 'package:software_pay/src/l10n/localization_helper.dart';

class ExceptionMapper {
  static String mapException(Object? e) {
    if (e is TimeoutException) {
      return "Request timed out";
    } else if (e is FormatException) {
      return "Invalid response";
    } else {
      return "An error occurred";
    }
  }

  static String getErrorMessage(error) {
    final localizationsHelper = LocalizationsHelper();
    return switch (error) {
      AppException(code: AppExceptionCode code) => switch (code) {
          AppExceptionCode.unknown => localizationsHelper.msgs.unknownError,
          _ => localizationsHelper.msgs.unknownError,
        },
      _ => localizationsHelper.msgs.unknownError,
    };
  }
}
