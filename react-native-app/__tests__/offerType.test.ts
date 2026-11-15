import {
  offerLabelKey,
  offerTypeOf,
  periodLabelKey,
} from '../src/data/models/offerType';

describe('offerTypeOf', () => {
  it('a sale is a sale', () => {
    expect(offerTypeOf({ listingType: 'sale' })).toBe('sale');
  });
  it('a rent by month or year is a rent', () => {
    expect(offerTypeOf({ listingType: 'rent', rentPeriod: 'month' })).toBe('rent');
    expect(offerTypeOf({ listingType: 'rent', rentPeriod: 'year' })).toBe('rent');
  });
  it('a rent by night is a stay', () => {
    expect(offerTypeOf({ listingType: 'rent', rentPeriod: 'night' })).toBe('stay');
  });
});

describe('translation keys', () => {
  it('gives the ribbon key of each type', () => {
    expect(offerLabelKey('sale')).toBe('offerSale');
    expect(offerLabelKey('rent')).toBe('offerRent');
    expect(offerLabelKey('stay')).toBe('offerStay');
  });
  it('gives the unit key, none for a sale', () => {
    expect(periodLabelKey('night')).toBe('unitNight');
    expect(periodLabelKey('month')).toBe('unitMonth');
    expect(periodLabelKey('year')).toBe('unitYear');
    expect(periodLabelKey(null)).toBeNull();
    expect(periodLabelKey(undefined)).toBeNull();
  });
});
