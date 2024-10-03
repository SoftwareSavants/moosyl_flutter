import 'dart:async';

import 'package:flutter/material.dart';
import 'package:software_pay/helpers/exception_handling/exception_mapper.dart';
import 'package:software_pay/widgets/feedback.dart';

class ErrorHandlers {
  static Future<ResponseHandlers<T>> catchErrors<T>(
    Future<T> Function() function, {
    BuildContext? context,
    bool showFlashBar = true,
  }) async {
    assert(!showFlashBar || context != null);
    try {
      return ResponseHandlers(result: await function());
    } catch (error) {
      String errorMsg = ExceptionMapper.getErrorMessage(error);

      if (showFlashBar) {
        Feedbacks.flushBar(
          message: errorMsg,
          context: context!,
        );
      }
      return ResponseHandlers(error: errorMsg);
    }
  }
}

class ResponseHandlers<T> {
  final String? error;
  final T? result;
  bool get isError => error != null;

  ResponseHandlers({
    this.error,
    this.result,
  });
}
