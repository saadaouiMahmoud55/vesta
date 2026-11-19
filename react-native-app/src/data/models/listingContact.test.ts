import { contactFromData } from './listingContact';

describe('contactFromData', () => {
  it('reads the phone and the WhatsApp flag', () => {
    expect(
      contactFromData({ contactPhone: '+21692816836', whatsappEnabled: true }),
    ).toEqual({ phone: '+21692816836', whatsapp: true });
  });

  it('has no contact without a phone', () => {
    expect(contactFromData(undefined)).toBeNull();
    expect(contactFromData({})).toBeNull();
    expect(contactFromData({ contactPhone: 92816836 })).toBeNull();
  });

  it('treats a missing or non-true WhatsApp flag as false', () => {
    expect(contactFromData({ contactPhone: '+21692816836' })).toEqual({
      phone: '+21692816836',
      whatsapp: false,
    });
    expect(
      contactFromData({ contactPhone: '+21692816836', whatsappEnabled: 'yes' }),
    ).toEqual({ phone: '+21692816836', whatsapp: false });
  });
});