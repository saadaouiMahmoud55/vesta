import en from '../src/core/translations/en';
import fr from '../src/core/translations/fr';
import ar from '../src/core/translations/ar';

const keys = [
  'contactCall',
  'contactWhatsapp',
  'contactSignInToSee',
  'contactNoWhatsapp',
  'contactCallError',
  'contactMessageSale',
  'contactMessageRent',
  'contactMessageStay',
];
const messageKeys = [
  'contactMessageSale',
  'contactMessageRent',
  'contactMessageStay',
];

describe('contact translations', () => {
  it.each([
    ['en', en],
    ['fr', fr],
    ['ar', ar],
  ])('%s has the 8 contact keys', (_name, translations) => {
    const texts = translations as Record<string, string>;
    for (const key of keys) {
      expect(typeof texts[key]).toBe('string');
      expect(texts[key].length).toBeGreaterThan(0);
    }
    for (const key of messageKeys) {
      expect(texts[key]).toContain('{{title}}');
    }
  });
});