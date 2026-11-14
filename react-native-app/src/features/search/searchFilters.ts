import { isUnavailable, Listing } from '../../data/models/listing';
import {
  categoryOf,
  ListingCategory,
} from '../../data/models/listingCategory';

/** Wait this long after the last keystroke before filtering. */
export const SEARCH_DEBOUNCE_MS = 400;

/** How many listings the search reads (newest first). */
export const SEARCH_LIST_LIMIT = 100;

const ACCENTS_FROM = 'àáâãäåçèéêëìíîïñòóôõöùúûüýÿ';
const ACCENTS_TO = 'aaaaaaceeeeiiiinooooouuuuyy';

/** Lower case, no accents, no spaces around: "  Gabès " becomes "gabes". */
export function normalizeSearchText(input: string): string {
  let result = '';
  for (const char of input.trim().toLowerCase()) {
    const index = ACCENTS_FROM.indexOf(char);
    result += index === -1 ? char : ACCENTS_TO[index];
  }
  return result;
}

/**
 * Same fields as SearchFilters in Flutter. null = no filter.
 * `offerType` uses the shared rule (buy, rent, stay): a stay (rent per
 * night) is not a rent.
 */
export type SearchFilters = {
  minPrice: number | null;
  maxPrice: number | null;
  city: string;
  offerType: ListingCategory | null;
  propertyType: string | null;
};

export const emptyFilters: SearchFilters = {
  minPrice: null,
  maxPrice: null,
  city: '',
  offerType: null,
  propertyType: null,
};

/** Number of active filters (badge on the filter button). */
export function activeFilterCount(filters: SearchFilters): number {
  return (
    (filters.minPrice !== null || filters.maxPrice !== null ? 1 : 0) +
    (filters.city.trim() !== '' ? 1 : 0) +
    (filters.offerType !== null ? 1 : 0) +
    (filters.propertyType !== null ? 1 : 0)
  );
}

export function matchesFilters(listing: Listing, f: SearchFilters): boolean {
  if (f.minPrice !== null && listing.price < f.minPrice) {
    return false;
  }
  if (f.maxPrice !== null && listing.price > f.maxPrice) {
    return false;
  }
  if (f.offerType !== null && categoryOf(listing) !== f.offerType) {
    return false;
  }
  if (f.propertyType !== null && listing.propertyType !== f.propertyType) {
    return false;
  }
  const text = normalizeSearchText(f.city);
  // The text matches the city or the title of the listing.
  if (
    text !== '' &&
    !normalizeSearchText(listing.city).includes(text) &&
    !normalizeSearchText(listing.title).includes(text)
  ) {
    return false;
  }
  return true;
}

/**
 * Keeps the order of `listings` (already newest first). Sold, rented,
 * unavailable or hidden listings are not offered by the search.
 */
export function applyFilters(
  listings: Listing[],
  filters: SearchFilters,
): Listing[] {
  return listings.filter(
    listing => !isUnavailable(listing) && matchesFilters(listing, filters),
  );
}