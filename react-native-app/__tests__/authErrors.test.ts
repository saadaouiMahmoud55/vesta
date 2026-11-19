import {
  authErrorKey,
  errorCodeOf,
  mapAuthCode,
} from '../src/data/repositories/authErrors';

describe('auth errors (same mapping as the Flutter AuthRepository)', () => {
  it('maps the Firebase Auth codes', () => {
    expect(mapAuthCode('auth/invalid-email')).toBe('invalidEmail');
    expect(mapAuthCode('auth/email-already-in-use')).toBe('emailInUse');
    expect(mapAuthCode('auth/weak-password')).toBe('passwordTooShort');
    expect(mapAuthCode('auth/wrong-password')).toBe('wrongPassword');
    expect(mapAuthCode('auth/invalid-credential')).toBe('wrongPassword');
    expect(mapAuthCode('auth/user-not-found')).toBe('wrongPassword');
    expect(mapAuthCode('auth/network-request-failed')).toBe('noNetwork');
    expect(mapAuthCode('auth/too-many-requests')).toBe('tooManyRequests');
    expect(mapAuthCode('auth/something-new')).toBe('unknown');
  });

  it('maps the Firestore code unavailable to no network', () => {
    expect(mapAuthCode('unavailable')).toBe('noNetwork');
  });

  it('reads the code of an error and ignores other values', () => {
    expect(errorCodeOf({ code: 'auth/invalid-email' })).toBe(
      'auth/invalid-email',
    );
    expect(errorCodeOf(new Error('x'))).toBe('');
    expect(errorCodeOf(null)).toBe('');
    expect(errorCodeOf('auth/invalid-email')).toBe('');
  });

  it('gives a translation key for every error', () => {
    expect(authErrorKey('wrongPassword')).toBe('authErrorWrongPassword');
    expect(authErrorKey('unknown')).toBe('authErrorUnknown');
  });
});
