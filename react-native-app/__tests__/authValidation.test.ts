import {
  validateEmail,
  validateName,
  validatePassword,
} from '../src/features/auth/authValidation';

describe('auth validation (same rules as Flutter)', () => {
  it('accepts a valid email and refuses an invalid one', () => {
    expect(validateEmail('ahmed@example.com')).toBeNull();
    expect(validateEmail('  ahmed@example.com  ')).toBeNull();
    expect(validateEmail('abc')).toBe('invalidEmail');
    expect(validateEmail('a@b')).toBe('invalidEmail');
    expect(validateEmail('')).toBe('invalidEmail');
  });

  it('needs a password of 8 characters or more', () => {
    expect(validatePassword('1234567')).toBe('passwordTooShort');
    expect(validatePassword('12345678')).toBeNull();
  });

  it('needs a name that is not empty', () => {
    expect(validateName('')).toBe('nameRequired');
    expect(validateName('   ')).toBe('nameRequired');
    expect(validateName('Ahmed')).toBeNull();
  });
});
