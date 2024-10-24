/// A class representing application exception codes.
class AppExceptionCode {
  /// Creates an instance of [AppExceptionCode] with the given value.
  const AppExceptionCode(
    this._value,
  );

  final String _value; // Private field to hold the exception code value.

  /// A constant for an unknown error code.
  static const unknown = AppExceptionCode('Unknown error');

  ///An existing pending payment was found. Please wait for the previous payment to be processed.
  static const existingPaymentWasFound = AppExceptionCode(
    'An existing pending payment was found. Please wait for the previous payment to be processed.',
  );

  /// API key is required
  static const apiKeyRequired = AppExceptionCode('API key is required');

  ///Invalid API key, organization not found
  static const invalidApiKeyOrganizationNotFound = AppExceptionCode(
    'Invalid API key, organization not found',
  );

  ///File not found
  static const fileNotFound = AppExceptionCode('File not found');

  ///Authentication BPay failed
  static const authenticationBPayFailed = AppExceptionCode(
    'Authentication BPay failed',
  );

  ///Configuration not found
  static const configurationNotFound = AppExceptionCode(
    'Configuration not found',
  );

  ///PaymentRequest not found
  static const paymentRequestNotFound = AppExceptionCode(
    'PaymentRequest not found',
  );

  ///Payment not found
  static const paymentNotFound = AppExceptionCode('Payment not found');

  ///Error while creating payment
  static const errorWhileCreatingPayment = AppExceptionCode(
    'Error while creating payment',
  );

  ///Error while creating paymentRequest
  static const errorWhileCreatingPaymentRequest = AppExceptionCode(
    'Error while creating paymentRequest',
  );

  ///Organization not found
  static const organizationNotFound =
      AppExceptionCode('Organization not found');

  ///Invalid API key
  static const invalidApiKey = AppExceptionCode('Invalid API key');

  ///Processing Error
  static const processingError = AppExceptionCode('Processing Error');

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
