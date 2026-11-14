import { pickLanguage } from '../src/core/language';

describe('pickLanguage', () => {
  it('keeps the language saved in the app', () => {
    expect(pickLanguage('fr', 'en')).toBe('fr');
  });
  it('uses the phone language when nothing is saved', () => {
    expect(pickLanguage(null, 'en')).toBe('en');
  });
  it('starts in Arabic when the phone language is not supported', () => {
    expect(pickLanguage(null, 'de')).toBe('ar');
  });
  it('ignores a saved language that is not supported', () => {
    expect(pickLanguage('de', 'fr')).toBe('fr');
  });
  it('starts in Arabic when there is no information', () => {
    expect(pickLanguage(undefined, undefined)).toBe('ar');
  });
});
