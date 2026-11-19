import { isUnavailable, listingFromData } from '../src/data/models/listing';

describe('listing model', () => {
  it('uses the same defaults as Flutter', () => {
    const listing = listingFromData('a', {});
    expect(listing.listingType).toBe('sale');
    expect(listing.status).toBe('available');
    expect(listing.rentPeriod).toBeNull();
    expect(listing.price).toBe(0);
  });

  it('knows which statuses are unavailable', () => {
    const make = (status: string) => listingFromData('a', { status });
    expect(isUnavailable(make('sold'))).toBe(true);
    expect(isUnavailable(make('hidden'))).toBe(true);
    expect(isUnavailable(make('reserved'))).toBe(false);
    expect(isUnavailable(make('available'))).toBe(false);
  });
});
