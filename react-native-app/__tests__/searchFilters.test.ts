import { Listing } from '../src/data/models/listing';
import {
  activeFilterCount,
  applyFilters,
  emptyFilters,
  normalizeSearchText,
} from '../src/features/search/searchFilters';

const make = (over: Partial<Listing>): Listing => ({
  id: 'x',
  ownerId: 'o',
  title: 'Maison',
  description: '',
  price: 100,
  currency: 'TND',
  listingType: 'sale',
  rentPeriod: null,
  propertyType: 'house',
  city: 'Tunis',
  status: 'available',
  photoCount: 1,
  latitude: null,
  longitude: null,
  bedrooms: null,
  bathrooms: null,
  areaSqm: null,
  maxGuests: null,
  amenities: [],
  checkIn: null,
  checkOut: null,
  houseRules: [],
  ...over,
});

const ids = (list: Listing[]): string[] => list.map(item => item.id);

test('normalizeSearchText removes accents, case and spaces', () => {
  expect(normalizeSearchText('  Gabès ')).toBe('gabes');
});

test('city text matches the city or the title, without accents', () => {
  const list = [
    make({ id: 'a', city: 'Gabès' }),
    make({ id: 'b', title: 'Villa à Gabès', city: 'Tunis' }),
    make({ id: 'c' }),
  ];
  expect(ids(applyFilters(list, { ...emptyFilters, city: 'gabes' }))).toEqual([
    'a',
    'b',
  ]);
});

test('price range keeps the bounds', () => {
  const list = [
    make({ id: 'a', price: 50 }),
    make({ id: 'b', price: 100 }),
    make({ id: 'c', price: 150 }),
    make({ id: 'd', price: 200 }),
  ];
  const filters = { ...emptyFilters, minPrice: 100, maxPrice: 150 };
  expect(ids(applyFilters(list, filters))).toEqual(['b', 'c']);
});

test('offer type: a stay is not a rent', () => {
  const list = [
    make({ id: 'sale' }),
    make({ id: 'stay', listingType: 'rent', rentPeriod: 'night' }),
    make({ id: 'rent', listingType: 'rent', rentPeriod: 'month' }),
  ];
  expect(
    ids(applyFilters(list, { ...emptyFilters, offerType: 'buy' })),
  ).toEqual(['sale']);
  expect(
    ids(applyFilters(list, { ...emptyFilters, offerType: 'stay' })),
  ).toEqual(['stay']);
  expect(
    ids(applyFilters(list, { ...emptyFilters, offerType: 'rent' })),
  ).toEqual(['rent']);
});

test('property type filters on the exact type', () => {
  const list = [
    make({ id: 'a', propertyType: 'villa' }),
    make({ id: 'b', propertyType: 'house' }),
  ];
  expect(
    ids(applyFilters(list, { ...emptyFilters, propertyType: 'villa' })),
  ).toEqual(['a']);
});

test('sold and hidden listings are not offered, reserved is', () => {
  const list = [
    make({ id: 'a', status: 'sold' }),
    make({ id: 'b', status: 'hidden' }),
    make({ id: 'c', status: 'reserved' }),
  ];
  expect(ids(applyFilters(list, emptyFilters))).toEqual(['c']);
});

test('three filters together', () => {
  const list = [
    make({ id: 'a', price: 120, city: 'Tunis', propertyType: 'villa' }),
    make({ id: 'b', price: 300, city: 'Tunis', propertyType: 'villa' }),
    make({ id: 'c', price: 120, city: 'Sfax', propertyType: 'villa' }),
  ];
  const filters = {
    ...emptyFilters,
    maxPrice: 200,
    city: 'tunis',
    propertyType: 'villa',
  };
  expect(ids(applyFilters(list, filters))).toEqual(['a']);
});

test('activeFilterCount counts a price range once', () => {
  expect(
    activeFilterCount({ ...emptyFilters, minPrice: 10, maxPrice: 20 }),
  ).toBe(1);
  expect(activeFilterCount(emptyFilters)).toBe(0);
});