import {
  categoryOf,
  filterByCategory,
} from '../src/data/models/listingCategory';

describe('listing category', () => {
  it('maps sale, night rent and other rent', () => {
    expect(categoryOf({ listingType: 'sale' })).toBe('buy');
    expect(categoryOf({ listingType: 'rent', rentPeriod: 'night' })).toBe(
      'stay',
    );
    expect(categoryOf({ listingType: 'rent', rentPeriod: 'month' })).toBe(
      'rent',
    );
    expect(categoryOf({ listingType: 'rent', rentPeriod: 'year' })).toBe('rent');
    expect(categoryOf({ listingType: 'rent', rentPeriod: null })).toBe('rent');
  });

  it('filters and keeps everything for "all"', () => {
    const items = [
      { listingType: 'sale' as const },
      { listingType: 'rent' as const, rentPeriod: 'night' as const },
      { listingType: 'rent' as const, rentPeriod: 'month' as const },
    ];
    expect(filterByCategory(items, null)).toHaveLength(3);
    expect(filterByCategory(items, 'stay')).toHaveLength(1);
    expect(filterByCategory(items, 'rent')).toHaveLength(1);
  });
});
