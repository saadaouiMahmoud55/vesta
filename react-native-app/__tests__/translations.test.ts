import ar from '../src/core/translations/ar';
import en from '../src/core/translations/en';
import fr from '../src/core/translations/fr';
import { authErrorKey } from '../src/data/repositories/authErrors';
import { favoritesErrorKey } from '../src/data/repositories/favoritesErrors';

const sortedKeys = (value: object) => Object.keys(value).sort();

describe('translations', () => {
  it('have the same keys in English, French and Arabic', () => {
    expect(sortedKeys(fr)).toEqual(sortedKeys(en));
    expect(sortedKeys(ar)).toEqual(sortedKeys(en));
  });

  it('have a text for every auth error', () => {
    const errors = [
      'invalidEmail',
      'passwordTooShort',
      'nameRequired',
      'emailInUse',
      'wrongPassword',
      'noNetwork',
      'tooManyRequests',
      'unknown',
    ] as const;
    const keys = Object.keys(en);
    errors.forEach(error => {
      expect(keys).toContain(authErrorKey(error));
    });
  });

  it('have a text for every favorites error', () => {
    const errors = [
      'notSignedIn',
      'noNetwork',
      'permissionDenied',
      'unknown',
    ] as const;
    const keys = Object.keys(en);
    errors.forEach(error => {
      expect(keys).toContain(favoritesErrorKey(error));
    });
  });
});
