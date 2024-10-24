import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:moosyl/src/helpers/exception_handling/exceptions.dart';
import 'package:moosyl/l10n/generated/moosyl_localization.dart';

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
    final localizationsHelper = MoosylLocalization.of(
      context,
    )!; // Create an instance of LocalizationsHelper.

    // Switch on the type of error to determine the appropriate message.
    return switch (error) {
      AppException(code: AppExceptionCode code) => switch (code) {
          AppExceptionCode.existingPaymentWasFound => localizationsHelper
              .existingPaymentWasFound, // Localized message for existing payment found.
          AppExceptionCode.apiKeyRequired => localizationsHelper
              .apiKeyRequired, // Localized message for API key required.
          AppExceptionCode.invalidApiKeyOrganizationNotFound =>
            localizationsHelper
                .invalidApiKeyOrganizationNotFound, // Localized message for invalid API key (organization not found).
          AppExceptionCode.fileNotFound => localizationsHelper
              .fileNotFound, // Localized message for file not found.
          AppExceptionCode.authenticationBPayFailed => localizationsHelper
              .authenticationBPayFailed, // Localized message for authentication BPay failed.
          AppExceptionCode.configurationNotFound => localizationsHelper
              .configurationNotFound, // Localized message for configuration not found.
          AppExceptionCode.paymentRequestNotFound => localizationsHelper
              .paymentRequestNotFound, // Localized message for payment request not found.
          AppExceptionCode.paymentNotFound => localizationsHelper
              .paymentNotFound, // Localized message for payment not found.
          AppExceptionCode.errorWhileCreatingPayment => localizationsHelper
              .errorWhileCreatingPayment, // Localized message for error while creating payment.
          AppExceptionCode.errorWhileCreatingPaymentRequest => localizationsHelper
              .errorWhileCreatingPaymentRequest, // Localized message for error while creating payment request.
          AppExceptionCode.organizationNotFound => localizationsHelper
              .organizationNotFound, // Localized message for organization not found.
          AppExceptionCode.invalidApiKey => localizationsHelper.invalidApiKey,
          AppExceptionCode.processingError => localizationsHelper
              .processingError, // Localized message for invalid API key. // Localized message for invalid API key.
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
