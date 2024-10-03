import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:software_pay/helpers/exception_handling/exceptions.dart';

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

  static String getErrorMessage(BuildContext context, error) {
    return switch (error) {
      AppException(code: AppExceptionCode code) => switch (code) {
          AppExceptionCode.unknown => ln10.,
        },
      _ => context.l10n.unknownError,
    };
  }
}
