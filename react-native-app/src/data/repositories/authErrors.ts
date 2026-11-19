/** Errors the UI can show. Screens turn them into translated messages. */
export type AuthError =
  | 'invalidEmail'
  | 'passwordTooShort'
  | 'nameRequired'
  | 'emailInUse'
  | 'wrongPassword'
  | 'noNetwork'
  | 'tooManyRequests'
  | 'unknown';

export class AuthFailure extends Error {
  readonly error: AuthError;

  constructor(error: AuthError) {
    super(error);
    this.name = 'AuthFailure';
    this.error = error;
  }
}

/** Reads the `code` of a Firebase error (Auth or Firestore), or ''. */
export function errorCodeOf(error: unknown): string {
  if (typeof error === 'object' && error !== null && 'code' in error) {
    const code = (error as { code?: unknown }).code;
    return typeof code === 'string' ? code : '';
  }
  return '';
}

/**
 * Same mapping as the Flutter AuthRepository. Firebase Auth codes start with
 * `auth/`; the Firestore code `unavailable` means there is no network.
 */
export function mapAuthCode(rawCode: string): AuthError {
  const code = rawCode.replace(/^auth\//, '');
  switch (code) {
    case 'invalid-email':
      return 'invalidEmail';
    case 'email-already-in-use':
      return 'emailInUse';
    case 'weak-password':
      return 'passwordTooShort';
    case 'wrong-password':
    case 'invalid-credential':
    case 'user-not-found':
      return 'wrongPassword';
    case 'network-request-failed':
    case 'unavailable':
      return 'noNetwork';
    case 'too-many-requests':
      return 'tooManyRequests';
    default:
      return 'unknown';
  }
}

const translationKeys: Record<AuthError, string> = {
  invalidEmail: 'authErrorInvalidEmail',
  passwordTooShort: 'authErrorPasswordShort',
  nameRequired: 'authErrorNameRequired',
  emailInUse: 'authErrorEmailInUse',
  wrongPassword: 'authErrorWrongPassword',
  noNetwork: 'authErrorNoNetwork',
  tooManyRequests: 'authErrorTooManyRequests',
  unknown: 'authErrorUnknown',
};

/** Translation key of an error message (no text written in a screen). */
export function authErrorKey(error: AuthError): string {
  return translationKeys[error];
}
