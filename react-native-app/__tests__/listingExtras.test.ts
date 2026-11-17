import { listingFromData } from '../src/data/models/listing';
import {
  amenityKeys,
  houseRuleKeys,
  isValidTime,
  listingDocumentData,
  NewListing,
  pickKeys,
  toggleKey,
  validateGuests,
} from '../src/data/models/newListing';

const base: NewListing = {
  title: 'Dar',
  description: 'Nice',
  price: 120,
  listingType: 'rent',
  rentPeriod: 'night',
  propertyType: 'guest_house',
  city: 'Tozeur',
  bedrooms: null,
  bathrooms: null,
  areaSqm: null,
  contactPhone: '+21620123456',
  whatsappEnabled: false,
};

describe('validateGuests', () => {
  it('accepts empty and 1 to 30', () => {
    expect(validateGuests('')).toBeNull();
    expect(validateGuests('1')).toBeNull();
    expect(validateGuests('30')).toBeNull();
  });
  it('refuses 0, 31, decimals and text', () => {
    expect(validateGuests('0')).toBe('listingErrorGuestsInvalid');
    expect(validateGuests('31')).toBe('listingErrorGuestsInvalid');
    expect(validateGuests('2.5')).toBe('listingErrorGuestsInvalid');
    expect(validateGuests('abc')).toBe('listingErrorGuestsInvalid');
  });
});

describe('isValidTime', () => {
  it('checks HH:mm', () => {
    expect(isValidTime('14:00')).toBe(true);
    expect(isValidTime('00:00')).toBe(true);
    expect(isValidTime('23:59')).toBe(true);
    expect(isValidTime('24:00')).toBe(false);
    expect(isValidTime('9:00')).toBe(false);
    expect(isValidTime('14:60')).toBe(false);
  });
});

describe('pickKeys and toggleKey', () => {
  it('keeps the order of the allowed keys, whatever the taps', () => {
    expect(pickKeys(amenityKeys, ['tv', 'wifi', 'pool'])).toEqual([
      'wifi',
      'pool',
      'tv',
    ]);
  });
  it('drops unknown keys and duplicates', () => {
    expect(pickKeys(houseRuleKeys, ['no_pets', 'no_pets', 'sea_view'])).toEqual([
      'no_pets',
    ]);
  });
  it('adds and removes a key', () => {
    const added = toggleKey(amenityKeys, ['tv'], 'wifi');
    expect(added).toEqual(['wifi', 'tv']);
    expect(toggleKey(amenityKeys, added, 'tv')).toEqual(['wifi']);
  });
  it('refuses to go over the maximum', () => {
    expect(toggleKey(amenityKeys, ['wifi', 'ac'], 'tv', 2)).toEqual([
      'wifi',
      'ac',
    ]);
  });
  it('ignores an unknown key', () => {
    expect(toggleKey(amenityKeys, ['wifi'], 'sea_view')).toEqual(['wifi']);
  });
});

describe('listingDocumentData with the optional details', () => {
  it('writes nothing for an untouched form', () => {
    const data = listingDocumentData(base, 'uid1', 'TND', 2);
    for (const field of [
      'maxGuests',
      'amenities',
      'checkIn',
      'checkOut',
      'houseRules',
    ]) {
      expect(data).not.toHaveProperty(field);
    }
    expect(data.status).toBe('available');
  });
  it('writes the filled details like Flutter', () => {
    const data = listingDocumentData(
      {
        ...base,
        maxGuests: 4,
        amenities: ['tv', 'wifi'],
        checkIn: '14:00',
        checkOut: '11:00',
        houseRules: ['no_parties', 'no_smoking'],
      },
      'uid1',
      'TND',
      2,
    );
    expect(data.maxGuests).toBe(4);
    expect(data.amenities).toEqual(['wifi', 'tv']);
    expect(data.checkIn).toBe('14:00');
    expect(data.checkOut).toBe('11:00');
    expect(data.houseRules).toEqual(['no_smoking', 'no_parties']);
  });
  it('skips a bad time and an empty list', () => {
    const data = listingDocumentData(
      { ...base, checkIn: '25:00', amenities: [] },
      'uid1',
      'TND',
      1,
    );
    expect(data).not.toHaveProperty('checkIn');
    expect(data).not.toHaveProperty('amenities');
  });
});

describe('listingFromData with the optional details', () => {
  it('reads the new fields', () => {
    const listing = listingFromData('a1', {
      maxGuests: 6,
      amenities: ['wifi', 3, 'pool'],
      checkIn: '15:00',
      houseRules: ['no_pets'],
      bedrooms: 0,
      areaSqm: 85,
    });
    expect(listing.maxGuests).toBe(6);
    expect(listing.amenities).toEqual(['wifi', 'pool']);
    expect(listing.checkIn).toBe('15:00');
    expect(listing.checkOut).toBeNull();
    expect(listing.houseRules).toEqual(['no_pets']);
    expect(listing.bedrooms).toBe(0);
    expect(listing.bathrooms).toBeNull();
    expect(listing.areaSqm).toBe(85);
  });
  it('gives empty defaults when nothing is stored', () => {
    const listing = listingFromData('a2', {});
    expect(listing.maxGuests).toBeNull();
    expect(listing.amenities).toEqual([]);
    expect(listing.houseRules).toEqual([]);
    expect(listing.checkIn).toBeNull();
  });
});
