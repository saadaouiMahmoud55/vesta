import { AuthError } from '../../data/repositories/authErrors';

// Field validation, shared by Login and Sign up (same rules as Flutter).
export const minPasswordLength = 8;

export function validateEmail(value: string): AuthError | null {
  const valid = /^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(value.trim());
  return valid ? null : 'invalidEmail';
}

export function validatePassword(value: string): AuthError | null {
  return value.length >= minPasswordLength ? null : 'passwordTooShort';
}

export function validateName(value: string): AuthError | null {
  return value.trim().length > 0 ? null : 'nameRequired';
}
