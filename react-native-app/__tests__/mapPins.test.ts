import { listingFromData, Listing } from '../src/data/models/listing';
import { pinsFor } from '../src/features/map/mapPins';
import {
  placeByName,
  searchPlaces,
  tunisiaPlaces,
} from '../src/features/map/tunisiaPlaces';

const make = (id: string, data: Record<string, unknown> = {}): Listing =>
  listingFromData(id, { city: 'Tozeur', price: 100, ...data });

describe('tunisia places', () => {
  it('finds a place by Latin or Arabic name, ignoring case and accents', () => {
    expect(placeByName('tozeur')?.name).toBe('Tozeur');
    expect(placeByName('  GABES ')?.name).toBe('Gabès');
    expect(placeByName('توزر')?.name).toBe('Tozeur');
    expect(placeByName('Atlantis')).toBeNull();
    expect(placeByName(null)).toBeNull();
  });

  it('searches names that start with the text first, then those containing it', () => {
    const names = searchPlaces('sou').map(p => p.name);
    expect(names[0]).toBe('Sousse');
    expect(searchPlaces('')).toEqual([]);
    expect(searchPlaces('a', 3)).toHaveLength(3);
    expect(searchPlaces('توز')[0].name).toBe('Tozeur');
  });

  it('has valid coordinates for every place, inside Tunisia', () => {
    for (const place of tunisiaPlaces) {
      expect(place.latitude).toBeGreaterThan(30);
      expect(place.latitude).toBeLessThan(38);
      expect(place.longitude).toBeGreaterThan(7);
      expect(place.longitude).toBeLessThan(12);
    }
  });
});

describe('pinsFor', () => {
  it('uses the exact position when the owner placed the pin', () => {
    const [pin] = pinsFor([make('a', { latitude: 33.9, longitude: 8.1 })]);
    expect(pin.exact).toBe(true);
    expect(pin.latitude).toBe(33.9);
  });

  it('falls back to the city center, and leaves out unknown cities', () => {
    const pins = pinsFor([make('a'), make('b', { city: 'Nowhere' })]);
    expect(pins).toHaveLength(1);
    expect(pins[0].exact).toBe(false);
    expect(pins[0].latitude).toBeCloseTo(33.9197, 3);
  });

  it('skips unavailable listings', () => {
    expect(pinsFor([make('a', { status: 'sold' })])).toEqual([]);
    expect(pinsFor([make('a', { status: 'reserved' })])).toHaveLength(1);
  });

  it('spreads approximate pins of the same city so they do not overlap', () => {
    const pins = pinsFor([make('a'), make('b'), make('c')]);
    const keys = new Set(pins.map(p => `${p.latitude},${p.longitude}`));
    expect(keys.size).toBe(3);
  });

  it('ignores a half-set or out-of-range position', () => {
    const half = pinsFor([make('a', { latitude: 33.9 })])[0];
    expect(half.exact).toBe(false);
    const bad = pinsFor([make('b', { latitude: 200, longitude: 8 })])[0];
    expect(bad.exact).toBe(false);
  });
});
