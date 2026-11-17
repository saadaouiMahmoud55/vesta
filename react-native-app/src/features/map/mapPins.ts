import {
  hasLocation,
  isUnavailable,
  Listing,
} from '../../data/models/listing';
import { placeByName } from './tunisiaPlaces';

/** One pin of the map: the listing and where to draw it. */
export type MapPin = {
  listing: Listing;
  latitude: number;
  longitude: number;
  /** true: the owner placed the pin. false: center of the listing's city. */
  exact: boolean;
};

/** The [k]-th point around the center: 0 is the center, then ~450 m * sqrt(k), golden angle. */
function spiral(
  latitude: number,
  longitude: number,
  k: number,
): { latitude: number; longitude: number } {
  if (k === 0) {
    return { latitude, longitude };
  }
  const goldenAngle = 2.399963;
  const radius = 0.004 * Math.sqrt(k);
  const angle = k * goldenAngle;
  return {
    latitude: latitude + radius * Math.sin(angle),
    longitude:
      longitude +
      (radius * Math.cos(angle)) / Math.cos((latitude * Math.PI) / 180),
  };
}

/**
 * Pins to draw: every available listing, at its exact position when it has
 * one, otherwise at the center of its city when the city is a known place
 * (others are left out). Approximate pins of one city are spread on a small
 * spiral. Same rules as pinsFor in the Flutter app.
 */
export function pinsFor(listings: Listing[]): MapPin[] {
  const pins: MapPin[] = [];
  const countByCity = new Map<string, number>();
  for (const listing of listings) {
    if (isUnavailable(listing)) {
      continue;
    }
    if (hasLocation(listing)) {
      pins.push({
        listing,
        latitude: listing.latitude as number,
        longitude: listing.longitude as number,
        exact: true,
      });
      continue;
    }
    const place = placeByName(listing.city);
    if (place === null) {
      continue;
    }
    const k = countByCity.get(place.name) ?? 0;
    countByCity.set(place.name, k + 1);
    pins.push({
      listing,
      ...spiral(place.latitude, place.longitude, k),
      exact: false,
    });
  }
  return pins;
}
