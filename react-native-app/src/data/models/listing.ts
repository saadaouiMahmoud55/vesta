import { ListingType, RentPeriod } from './listingCategory';

export type Listing = {
  id: string;
  ownerId: string;
  title: string;
  description: string;
  price: number;
  currency: string;
  listingType: ListingType;
  rentPeriod: RentPeriod | null;
  propertyType: string;
  city: string;
  status: string;
  photoCount: number;
  latitude: number | null;
  longitude: number | null;
};

const text = (value: unknown, fallback = ''): string =>
  typeof value === 'string' ? value : fallback;

/** Same defaults as Listing.fromDoc in Flutter. */
export function listingFromData(
  id: string,
  data: Record<string, unknown>,
): Listing {
  const period = data.rentPeriod;
  return {
    id,
    ownerId: text(data.ownerId),
    title: text(data.title),
    description: text(data.description),
    price: typeof data.price === 'number' ? data.price : 0,
    currency: text(data.currency),
    listingType: data.listingType === 'rent' ? 'rent' : 'sale',
    rentPeriod:
      period === 'night' || period === 'month' || period === 'year'
        ? period
        : null,
    propertyType: text(data.propertyType),
    city: text(data.city),
    status: text(data.status, 'available'),
    photoCount: typeof data.photoCount === 'number' ? data.photoCount : 0,
    latitude: typeof data.latitude === 'number' ? data.latitude : null,
    longitude: typeof data.longitude === 'number' ? data.longitude : null,
  };
}

const unavailableStatuses = ['sold', 'rented', 'unavailable', 'hidden'];

/** `reserved` is not here: the listing is still shown normally. */
export function isUnavailable(listing: Listing): boolean {
  return unavailableStatuses.includes(listing.status);
}

/** True when the owner placed an exact pin (both coordinates, inside the valid range). */
export function hasLocation(listing: Listing): boolean {
  const { latitude: lat, longitude: lng } = listing;
  return (
    lat !== null &&
    lng !== null &&
    Math.abs(lat) <= 90 &&
    Math.abs(lng) <= 180
  );
}
