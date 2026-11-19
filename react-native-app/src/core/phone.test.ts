import {
  formatPhone,
  isValidTunisianPhone,
  normalizeTunisianPhone,
} from './phone';

describe('normalizeTunisianPhone', () => {
  it('accepts the usual ways to write a number', () => {
    expect(normalizeTunisianPhone('+21692816836')).toBe('+21692816836');
    expect(normalizeTunisianPhone('92 816 836')).toBe('+21692816836');
    expect(normalizeTunisianPhone('92-816-836')).toBe('+21692816836');
    expect(normalizeTunisianPhone('0021692816836')).toBe('+21692816836');
    expect(normalizeTunisianPhone('21692816836')).toBe('+21692816836');
  });

  it('accepts the first digits 2, 3, 4, 5, 7 and 9 only', () => {
    for (const d of ['2', '3', '4', '5', '7', '9']) {
      expect(isValidTunisianPhone(`${d}1234567`)).toBe(true);
    }
    for (const d of ['0', '1', '6', '8']) {
      expect(isValidTunisianPhone(`${d}1234567`)).toBe(false);
    }
  });

  it('rejects wrong lengths and text', () => {
    expect(normalizeTunisianPhone('9281683')).toBeNull();
    expect(normalizeTunisianPhone('928168360')).toBeNull();
    expect(normalizeTunisianPhone('abc')).toBeNull();
    expect(normalizeTunisianPhone('')).toBeNull();
  });
});

describe('formatPhone', () => {
  it('groups the digits like the Flutter app', () => {
    expect(formatPhone('+21692816836')).toBe('+216 92 816 836');
    expect(formatPhone('92816836')).toBe('+216 92 816 836');
  });

  it('returns the input when it is not a valid number', () => {
    expect(formatPhone('abc')).toBe('abc');
  });
});