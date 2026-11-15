import { telUrl, whatsappUrl } from './contactLinks';

describe('telUrl', () => {
  it('keeps the + of the E.164 number', () => {
    expect(telUrl('+21692816836')).toBe('tel:+21692816836');
  });
});

describe('whatsappUrl', () => {
  it('removes the + and pre-fills the message', () => {
    expect(whatsappUrl('+21692816836', 'Bonjour')).toBe(
      'https://wa.me/21692816836?text=Bonjour',
    );
  });

  it('encodes spaces, quotes and punctuation', () => {
    expect(whatsappUrl('+21692816836', 'Hello, is "Villa A" available?')).toBe(
      'https://wa.me/21692816836?text=Hello%2C%20is%20%22Villa%20A%22%20available%3F',
    );
  });

  it('encodes Arabic text', () => {
    expect(whatsappUrl('+21692816836', 'مرحبا')).toBe(
      'https://wa.me/21692816836?text=%D9%85%D8%B1%D8%AD%D8%A8%D8%A7',
    );
  });
});