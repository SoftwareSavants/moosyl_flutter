import 'package:flutter/widgets.dart';
import 'package:moosyl/l10n/generated/moosyl_localization.dart';

/// A utility class for validating different input formats.
class Validators {
  /// Validates a Mauritanian phone number.
  ///
  /// This method checks if the given [value] is a valid Mauritanian phone number.
  /// The phone number must optionally start with '+222' or '00222' and followed
  /// by 8 digits where the first digit should be between 2 and 9.
  ///
  /// Returns an error message if the [value] is null, empty, or not valid.
  /// Returns null if the phone number is valid.
  static String? validateMauritanianPhoneNumber(
      String? value, BuildContext context) {
    // Regular expression pattern for a valid Mauritanian phone number.
    const pattern = r'^(?:\+222|00222)?[2-9]\d{7}$';
    final localizationHelper = MoosylLocalization.of(context)!;
    // Regular expression object to match the pattern against the input value.
    final regExp = RegExp(pattern);

    // Check if the value is null or empty and return an appropriate error message.
    if (value == null || value.isEmpty) {
      return localizationHelper.phoneNumberRequired;
    }
    // Check if the value matches the pattern and return an appropriate error message.
    else if (!regExp.hasMatch(value)) {
      return localizationHelper.validMauritanianNumber;
    }
    // Return null if the phone number is valid.
    return null;
  }

  /// Validates a 4-digit code.
  ///
  /// This method checks if the given [value] is a valid 4-digit code.
  /// The code must consist of exactly 4 digits.
  ///
  /// Returns an error message if the [value] is null, empty, or not valid.
  /// Returns null if the code is valid.
  static String? validatePassCode(String? value, BuildContext context) {
    // Regular expression pattern for a valid 4-digit code.
    const pattern = r'^\d{4}$';
    final localizationHelper = MoosylLocalization.of(context)!;
    // Regular expression object to match the pattern against the input value.
    final regExp = RegExp(pattern);

    // Check if the value is null or empty and return an appropriate error message.
    if (value == null || value.isEmpty) {
      return localizationHelper.codeRequired;
    }
    // Check if the value matches the pattern and return an appropriate error message.
    else if (!regExp.hasMatch(value)) {
      return localizationHelper.validDigitCode;
    }
    // Return null if the code is valid.
    return null;
  }
}
