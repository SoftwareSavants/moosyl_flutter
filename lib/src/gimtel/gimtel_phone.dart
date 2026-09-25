/// Normalizes a Mauritanian phone number to its 8 local digits, or null if invalid.
String? normalizeGimtelPhone(String? input) {
  if (input == null) return null;
  var digits = input.replaceAll(RegExp(r'[\s\-.()]'), '');
  if (digits.startsWith('+222')) {
    digits = digits.substring(4);
  } else if (digits.startsWith('00222')) {
    digits = digits.substring(5);
  } else if (digits.length == 11 && digits.startsWith('222')) {
    digits = digits.substring(3);
  }
  return RegExp(r'^\d{8}$').hasMatch(digits) ? digits : null;
}

/// "36551929" -> "36 55 19 29", the way Mauritanian numbers are usually written.
String groupPhonePairs(String phone) => RegExp(r'^\d{8}$').hasMatch(phone)
    ? '${phone.substring(0, 2)} ${phone.substring(2, 4)} ${phone.substring(4, 6)} ${phone.substring(6)}'
    : phone;
