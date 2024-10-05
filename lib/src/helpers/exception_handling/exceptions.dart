/// A class representing application exception codes.
class AppExceptionCode {
  /// Creates an instance of [AppExceptionCode] with the given value.
  const AppExceptionCode(
    this._value,
  );

  final String _value; // Private field to hold the exception code value.

  /// A constant for an unknown error code.
  static const unknown = AppExceptionCode('Unknown error');

  @override
  bool operator ==(covariant AppExceptionCode other) {
    if (identical(this, other)) return true; // Check for reference equality.

    return other._value == _value; // Check for value equality.
  }

  @override
  int get hashCode =>
      _value.hashCode; // Generate a hash code based on the _value.

  @override
  String toString() =>
      _value; // Return the string representation of the exception code.
}

/// A class representing an application exception.
class AppException {
  /// The code representing the type of exception.
  final AppExceptionCode code;

  /// Optional message providing additional information.
  final String? message;

  /// Optional stack trace for debugging.
  final StackTrace? stackTrace;

  /// AppException
  AppException({
    required this.code, // Required parameter for the exception code.
    this.message, // Optional parameter for the exception message.
    this.stackTrace, // Optional parameter for the stack trace.
  });

  @override
  String toString() =>
      'AppException(code: $code, message: $message)'; // String representation of the exception.
}
