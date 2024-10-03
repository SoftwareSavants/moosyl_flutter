class AppExceptionCode {
  const AppExceptionCode(this._value);

  final String _value;

  static const invalidOTP = AppExceptionCode('Invalid OTP code');
  static const unknown = AppExceptionCode('Unknown error');
  static const shiftNotPossible = AppExceptionCode('P0001');

  @override
  bool operator ==(covariant AppExceptionCode other) {
    if (identical(this, other)) return true;

    return other._value == _value;
  }

  @override
  int get hashCode => _value.hashCode;
}

class AppException {
  final AppExceptionCode code;
  final String? message;
  final StackTrace? stackTrace;

  AppException({
    required this.code,
    this.message,
    required this.stackTrace,
  });

  @override
  String toString() => 'AppException(code: $code, message: $message)';
}
