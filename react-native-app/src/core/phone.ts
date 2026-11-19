/**
 * Tunisian phone helpers. A number is +216 followed by 8 digits, the first
 * digit being 2, 3, 4, 5, 7 or 9. Port of
 * flutter-app/lib/core/utils/phone_utils.dart: same rules, same output.
 */
const LOCAL_NUMBER = /^[234579]\d{7}$/;

/** Returns the number in E.164 form (+216XXXXXXXX), or null if invalid. */
export function normalizeTunisianPhone(input: string): string | null {
  let digits = input.replace(/[\s\-().]/g, '');
  if (digits.startsWith('+216')) {
    digits = digits.slice(4);
  } else if (digits.startsWith('00216')) {
    digits = digits.slice(5);
  } else if (digits.startsWith('216') && digits.length === 11) {
    digits = digits.slice(3);
  }
  return LOCAL_NUMBER.test(digits) ? `+216${digits}` : null;
}

export function isValidTunisianPhone(input: string): boolean {
  return normalizeTunisianPhone(input) !== null;
}

/** +21692816836 -> "+216 92 816 836". Returns the input if invalid. */
export function formatPhone(e164: string): string {
  const normalized = normalizeTunisianPhone(e164);
  if (normalized === null) {
    return e164;
  }
  const n = normalized.slice(4);
  return `+216 ${n.slice(0, 2)} ${n.slice(2, 5)} ${n.slice(5)}`;
}