/// Tunisian phone helpers. A number is +216 followed by 8 digits,
/// the first digit being 2, 3, 4, 5, 7 or 9.
final RegExp _localNumber = RegExp(r'^[234579]\d{7}$');

/// Returns the number in E.164 form (+216XXXXXXXX), or null if invalid.
String? normalizeTunisianPhone(String input) {
  var digits = input.replaceAll(RegExp(r'[\s\-().]'), '');
  if (digits.startsWith('+216')) {
    digits = digits.substring(4);
  } else if (digits.startsWith('00216')) {
    digits = digits.substring(5);
  } else if (digits.startsWith('216') && digits.length == 11) {
    digits = digits.substring(3);
  }
  return _localNumber.hasMatch(digits) ? '+216$digits' : null;
}

bool isValidTunisianPhone(String input) =>
    normalizeTunisianPhone(input) != null;

/// +21692816836 -> "+216 92 816 836". Returns the input if invalid.
String formatPhone(String e164) {
  final normalized = normalizeTunisianPhone(e164);
  if (normalized == null) return e164;
  final n = normalized.substring(4);
  return '+216 ${n.substring(0, 2)} ${n.substring(2, 5)} ${n.substring(5)}';
}
