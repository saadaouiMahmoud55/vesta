export type ListingType = 'sale' | 'rent';
export type RentPeriod = 'night' | 'month' | 'year';

/** The three filters of the Favorites screen (besides "all"). */
export type ListingCategory = 'buy' | 'rent' | 'stay';

type Categorizable = {
  listingType: ListingType;
  rentPeriod?: RentPeriod | null;
};

/** sale -> buy; rent by the night -> stay; any other rent -> rent. */
export function categoryOf(listing: Categorizable): ListingCategory {
  if (listing.listingType === 'sale') {
    return 'buy';
  }
  return listing.rentPeriod === 'night' ? 'stay' : 'rent';
}

/** `null` means the "All" filter. */
export function filterByCategory<T extends Categorizable>(
  listings: T[],
  category: ListingCategory | null,
): T[] {
  if (category === null) {
    return listings;
  }
  return listings.filter(item => categoryOf(item) === category);
}
