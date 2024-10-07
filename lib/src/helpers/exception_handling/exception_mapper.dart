import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:software_pay/src/helpers/exception_handling/exceptions.dart';
import 'package:software_pay/l10n/generated/software_pay_localization.dart';

/// A utility class for mapping exceptions to user-friendly error messages.
class ExceptionMapper {
  /// Maps a given exception to a user-friendly error message.
  ///
  /// This method checks the type of the exception and returns an appropriate message.
  static String mapException(Object? e) {
    if (e is TimeoutException) {
      return "Request timed out"; // Return a message for a timeout exception.
    } else if (e is FormatException) {
      return "Invalid response"; // Return a message for an invalid response format.
    } else {
      return "An error occurred"; // Return a generic error message for other exceptions.
    }
  }

  /// Gets a localized error message based on the type of error.
  ///
  /// This method uses [LocalizationsHelper] to fetch localized messages for known app exceptions.
  static String getErrorMessage(error, BuildContext context) {
    final localizationsHelper = SoftwarePayLocalization.of(
        context)!; // Create an instance of LocalizationsHelper.

    // Switch on the type of error to determine the appropriate message.
    return switch (error) {
      AppException(code: AppExceptionCode code) => switch (code) {
          AppExceptionCode.unknown => localizationsHelper
              .unknownError, // Localized message for unknown error.
          _ => localizationsHelper
              .unknownError, // Fallback to unknown error message for other codes.
        },
      _ => localizationsHelper
          .unknownError, // Fallback to unknown error message for other types of errors.
    };
  }
}
