import {
  addUniquePhotos,
  listingDocumentData,
  NewListing,
  normalizeTunisianPhone,
  parseNumber,
  validateOptionalNumber,
  validatePhone,
  validatePrice,
  validateRentPeriod,
  validateRooms,
  validateTitle,
} from '../src/data/models/newListing';
import { mapListingCode } from '../src/data/repositories/listingErrors';

const base: NewListing = {
  title: 'Villa',
  description: 'Nice',
  price: 120,
  listingType: 'sale',
  rentPeriod: null,
  propertyType: 'villa',
  city: 'Tunis',
  bedrooms: null,
  bathrooms: null,
  areaSqm: null,
  contactPhone: '+21620123456',
  whatsappEnabled: false,
};

describe('validators', () => {
  it('requires a title', () => {
    expect(validateTitle('  ')).toBe('listingErrorTitleRequired');
    expect(validateTitle('Villa')).toBeNull();
  });
  it('accepts a price from 1 to 50,000,000 only', () => {
    expect(validatePrice('120')).toBeNull();
    expect(validatePrice('120,5')).toBeNull();
    expect(validatePrice('0')).toBe('listingErrorPriceInvalid');
    expect(validatePrice('abc')).toBe('listingErrorPriceInvalid');
    expect(validatePrice('50000001')).toBe('listingErrorPriceInvalid');
  });
  it('accepts rooms from 0 to 20, or empty', () => {
    expect(validateRooms('')).toBeNull();
    expect(validateRooms('0')).toBeNull();
    expect(validateRooms('20')).toBeNull();
    expect(validateRooms('21')).toBe('listingErrorRoomsInvalid');
    expect(validateRooms('1.5')).toBe('listingErrorRoomsInvalid');
  });
  it('accepts an optional number', () => {
    expect(validateOptionalNumber('')).toBeNull();
    expect(validateOptionalNumber('85')).toBeNull();
    expect(validateOptionalNumber('-3')).toBe('listingErrorNumberInvalid');
  });
  it('asks for a period only for a rent', () => {
    expect(validateRentPeriod('rent', null)).toBe(
      'listingErrorRentPeriodRequired',
    );
    expect(validateRentPeriod('rent', 'month')).toBeNull();
    expect(validateRentPeriod('sale', null)).toBeNull();
  });
  it('parses numbers', () => {
    expect(parseNumber('12,5')).toBe(12.5);
    expect(parseNumber('x')).toBeNaN();
  });
});

describe('Tunisian phone', () => {
  it('normalizes the usual forms', () => {
    expect(normalizeTunisianPhone('20 123 456')).toBe('+21620123456');
    expect(normalizeTunisianPhone('+216 20 123 456')).toBe('+21620123456');
    expect(normalizeTunisianPhone('0021620123456')).toBe('+21620123456');
    expect(normalizeTunisianPhone('21620123456')).toBe('+21620123456');
  });
  it('refuses a number starting with 1, 6, 8 or 0, or too short', () => {
    expect(normalizeTunisianPhone('10123456')).toBeNull();
    expect(normalizeTunisianPhone('60123456')).toBeNull();
    expect(normalizeTunisianPhone('2012345')).toBeNull();
    expect(validatePhone('')).toBe('listingErrorPhoneInvalid');
  });
});

describe('addUniquePhotos', () => {
  it('skips duplicates and flags them', () => {
    const result = addUniquePhotos(['a'], ['a', 'b']);
    expect(result).toEqual({
      photos: ['a', 'b'],
      duplicates: true,
      overLimit: false,
    });
  });
  it('stops at the limit and flags it', () => {
    const result = addUniquePhotos(['a', 'b'], ['c', 'd'], 3);
    expect(result.photos).toEqual(['a', 'b', 'c']);
    expect(result.overLimit).toBe(true);
  });
});

describe('listingDocumentData (same structure as Flutter)', () => {
  it('a sale has no rentPeriod and no optional fields', () => {
    const data = listingDocumentData(base, 'u1', 'TND', 3);
    expect(data).toEqual({
      ownerId: 'u1',
      title: 'Villa',
      description: 'Nice',
      price: 120,
      currency: 'TND',
      listingType: 'sale',
      propertyType: 'villa',
      city: 'Tunis',
      status: 'available',
      photoCount: 3,
    });
    expect('rentPeriod' in data).toBe(false);
    expect('contactPhone' in data).toBe(false);
  });
  it('a rent has its period and the filled optional fields', () => {
    const data = listingDocumentData(
      { ...base, listingType: 'rent', rentPeriod: 'night', bedrooms: 0, areaSqm: 85 },
      'u1',
      'TND',
      1,
    );
    expect(data.rentPeriod).toBe('night');
    expect(data.bedrooms).toBe(0);
    expect(data.areaSqm).toBe(85);
    expect('bathrooms' in data).toBe(false);
  });
});

describe('mapListingCode', () => {
  it('maps like the Flutter repository', () => {
    expect(mapListingCode('unavailable')).toBe('noNetwork');
    expect(mapListingCode('permission-denied')).toBe('permissionDenied');
    expect(mapListingCode('other')).toBe('unknown');
  });
});
