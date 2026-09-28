import 'package:flutter/widgets.dart';
import 'package:moosyl_flutter/l10n/generated/moosyl_localization.dart';
import 'package:moosyl_flutter/src/helpers/exception_handling/exception_mapper.dart';
import 'package:moosyl_flutter/src/helpers/exception_handling/exceptions.dart';

/// The payer-facing text for a `GimtelController.error`, or `null` when there
/// is no error. Never shows an exception's `toString()`:
/// - `'invalidPhone'` -> the localized invalid-number message;
/// - a backend message the SDK knows -> its localized text (`ExceptionMapper`);
/// - any other backend message (an [AppException] built from the response's
///   `{ message }` body by `MoosylGimtelApi`) -> that message, verbatim;
/// - anything else (network error, timeout, unexpected response) -> the
///   localized generic error.
String? gimtelErrorMessage(Object? error, BuildContext context) {
  if (error == null) return null;
  final l10n = MoosylLocalization.of(context)!;
  if (error == 'invalidPhone') return l10n.gimtelInvalidPhone;
  final mapped = ExceptionMapper.getErrorMessage(error, context);
  if (mapped != l10n.unknownError) return mapped;
  if (error is AppException) {
    final message = error.message;
    if (message != null && message.trim().isNotEmpty) return message;
  }
  return l10n.unknownError;
}
