import { contactMessageKey, telUrl, whatsappAppUrl } from './contactLinks';

describe('telUrl', () => {
  it('keeps the + of the E.164 number', () => {
    expect(telUrl('+21692816836')).toBe('tel:+21692816836');
  });
});

describe('whatsappAppUrl', () => {
  it('removes the + and pre-fills the message', () => {
    expect(whatsappAppUrl('+21692816836', 'Bonjour')).toBe(
      'whatsapp://send?phone=21692816836&text=Bonjour',
    );
  });

  it('encodes spaces, quotes and punctuation', () => {
    expect(
      whatsappAppUrl('+21692816836', 'Hello, is "Villa A" available?'),
    ).toBe(
      'whatsapp://send?phone=21692816836&text=Hello%2C%20is%20%22Villa%20A%22%20available%3F',
    );
  });

  it('encodes Arabic text', () => {
    expect(whatsappAppUrl('+21692816836', 'مرحبا')).toBe(
      'whatsapp://send?phone=21692816836&text=%D9%85%D8%B1%D8%AD%D8%A8%D8%A7',
    );
  });
});

describe('contactMessageKey', () => {
  it('uses the sale message for a sale', () => {
    expect(contactMessageKey({ listingType: 'sale', rentPeriod: null })).toBe(
      'contactMessageSale',
    );
  });

  it('uses the stay message for a rent by the night', () => {
    expect(
      contactMessageKey({ listingType: 'rent', rentPeriod: 'night' }),
    ).toBe('contactMessageStay');
  });

  it('uses the rent message for a rent by the month or the year', () => {
    expect(
      contactMessageKey({ listingType: 'rent', rentPeriod: 'month' }),
    ).toBe('contactMessageRent');
    expect(
      contactMessageKey({ listingType: 'rent', rentPeriod: 'year' }),
    ).toBe('contactMessageRent');
    expect(contactMessageKey({ listingType: 'rent', rentPeriod: null })).toBe(
      'contactMessageRent',
    );
  });
});