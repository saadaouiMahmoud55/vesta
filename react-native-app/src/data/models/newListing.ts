import { ListingType, RentPeriod } from './listingCategory';

/** Same limits as the rules and the Flutter app (docs/data-model.md). */
export const maxListingPhotos = 10;
export const maxBase64Chars = 270000;
export const maxListingPrice = 50000000;
export const maxRoomsLimit = 20;
export const maxGuestsLimit = 30;
export const maxAmenities = 10;

export const listingTypes: ListingType[] = ['sale', 'rent'];
export const rentPeriods: RentPeriod[] = ['night', 'month', 'year'];
export const propertyTypes = [
  'apartment',
  'house',
  'villa',
  'studio',
  'riad',
  'guest_house',
] as const;

/** Keys allowed by the rules (docs/data-model.md). Max 10 amenities, 4 rules. */
export const amenityKeys = [
  'wifi',
  'ac',
  'heating',
  'kitchen',
  'parking',
  'pool',
  'breakfast',
  'washing_machine',
  'tv',
  'garden',
] as const;
export const houseRuleKeys = [
  'no_smoking',
  'no_pets',
  'no_parties',
  'quiet_hours',
] as const;

/** Ready-made times for the check-in and check-out choices (`HH:mm`). */
export const checkInTimes = ['12:00', '13:00', '14:00', '15:00', '16:00'];
export const checkOutTimes = ['10:00', '11:00', '12:00', '13:00'];

export type NewListing = {
  title: string;
  description: string;
  price: number;
  listingType: ListingType;
  rentPeriod: RentPeriod | null;
  propertyType: string;
  city: string;
  bedrooms: number | null;
  bathrooms: number | null;
  areaSqm: number | null;
  /** E.164 form, +216XXXXXXXX. */
  contactPhone: string;
  whatsappEnabled: boolean;
  /** Optional details (VST-82). A missing value means "not filled". */
  maxGuests?: number | null;
  amenities?: string[];
  checkIn?: string | null;
  checkOut?: string | null;
  houseRules?: string[];
};

/** A validator returns the translation key of the error, or null. */
export type FieldError = string | null;

const empty = (value: string | null | undefined): boolean =>
  (value ?? '').trim().length === 0;

export const validateTitle = (v: string): FieldError =>
  empty(v) ? 'listingErrorTitleRequired' : null;

export const validateDescription = (v: string): FieldError =>
  empty(v) ? 'listingErrorDescriptionRequired' : null;

export const validateCity = (v: string): FieldError =>
  empty(v) ? 'listingErrorCityRequired' : null;

/** Plain number from a text field, or NaN. Accepts a comma as the decimal mark. */
export function parseNumber(value: string): number {
  const text = value.trim().replace(',', '.');
  return text.length > 0 && /^\d+(\.\d+)?$/.test(text) ? Number(text) : NaN;
}

export function validatePrice(v: string): FieldError {
  const price = parseNumber(v);
  return Number.isFinite(price) && price > 0 && price <= maxListingPrice
    ? null
    : 'listingErrorPriceInvalid';
}

/** Empty is fine; otherwise a number of 0 or more. */
export function validateOptionalNumber(v: string): FieldError {
  return empty(v) || Number.isFinite(parseNumber(v))
    ? null
    : 'listingErrorNumberInvalid';
}

/** Empty is fine; otherwise a whole number from 0 to 20. */
export function validateRooms(v: string): FieldError {
  if (empty(v)) {
    return null;
  }
  const n = parseNumber(v);
  return Number.isInteger(n) && n >= 0 && n <= maxRoomsLimit
    ? null
    : 'listingErrorRoomsInvalid';
}

/** Empty is fine; otherwise a whole number from 1 to 30. */
export function validateGuests(v: string): FieldError {
  if (empty(v)) {
    return null;
  }
  const n = parseNumber(v);
  return Number.isInteger(n) && n >= 1 && n <= maxGuestsLimit
    ? null
    : 'listingErrorGuestsInvalid';
}

/** `HH:mm`, 00:00 to 23:59. */
export const isValidTime = (v: string): boolean =>
  /^([01]\d|2[0-3]):[0-5]\d$/.test(v);

export const validateRentPeriod = (
  listingType: ListingType,
  period: RentPeriod | null,
): FieldError =>
  listingType === 'rent' && period === null
    ? 'listingErrorRentPeriodRequired'
    : null;

const localNumber = /^[234579]\d{7}$/;

/** `+216` and 8 digits, first digit 2, 3, 4, 5, 7 or 9. Null if not valid. */
export function normalizeTunisianPhone(input: string): string | null {
  let digits = input.replace(/[\s\-().]/g, '');
  if (digits.startsWith('+216')) {
    digits = digits.slice(4);
  } else if (digits.startsWith('00216')) {
    digits = digits.slice(5);
  } else if (digits.startsWith('216') && digits.length === 11) {
    digits = digits.slice(3);
  }
  return localNumber.test(digits) ? `+216${digits}` : null;
}

export const validatePhone = (v: string): FieldError =>
  normalizeTunisianPhone(v) === null ? 'listingErrorPhoneInvalid' : null;

/**
 * The selected keys, in the order of `allowed`, without unknown keys or
 * duplicates, at most `max` of them (same as Flutter: the order does not
 * depend on the order of the taps).
 */
export function pickKeys(
  allowed: readonly string[],
  selected: readonly string[],
  max: number = allowed.length,
): string[] {
  return allowed.filter((key) => selected.includes(key)).slice(0, max);
}

/**
 * Adds the key if it is missing, removes it if it is there. Adding is
 * refused (same list returned) when `max` keys are already selected.
 */
export function toggleKey(
  allowed: readonly string[],
  selected: readonly string[],
  key: string,
  max: number = allowed.length,
): string[] {
  if (!allowed.includes(key)) {
    return pickKeys(allowed, selected, max);
  }
  if (selected.includes(key)) {
    return pickKeys(
      allowed,
      selected.filter((k) => k !== key),
      max,
    );
  }
  return selected.length >= max
    ? pickKeys(allowed, selected, max)
    : pickKeys(allowed, [...selected, key], max);
}

export type AddedPhotos = {
  photos: string[];
  duplicates: boolean;
  overLimit: boolean;
};

/** Adds the new photos, skipping duplicates and anything over `max`. */
export function addUniquePhotos(
  current: string[],
  incoming: string[],
  max: number = maxListingPhotos,
): AddedPhotos {
  const photos = [...current];
  let duplicates = false;
  let overLimit = false;
  for (const photo of incoming) {
    if (photos.includes(photo)) {
      duplicates = true;
    } else if (photos.length >= max) {
      overLimit = true;
    } else {
      photos.push(photo);
    }
  }
  return { photos, duplicates, overLimit };
}

/**
 * Public fields of the listing document, same as createListing in Flutter:
 * optional fields only when filled, `rentPeriod` only for a rent, status
 * always `available`. The server timestamps and the phone are added by the
 * repository (the phone goes in `contact/info`, not here).
 */
export function listingDocumentData(
  listing: NewListing,
  ownerId: string,
  currency: string,
  photoCount: number,
): Record<string, unknown> {
  const amenities = pickKeys(
    amenityKeys,
    listing.amenities ?? [],
    maxAmenities,
  );
  const houseRules = pickKeys(houseRuleKeys, listing.houseRules ?? []);
  const checkIn = listing.checkIn ?? null;
  const checkOut = listing.checkOut ?? null;
  const maxGuests = listing.maxGuests ?? null;
  return {
    ownerId,
    title: listing.title,
    description: listing.description,
    price: listing.price,
    currency,
    listingType: listing.listingType,
    ...(listing.listingType === 'rent' ? { rentPeriod: listing.rentPeriod } : {}),
    propertyType: listing.propertyType,
    city: listing.city,
    status: 'available',
    ...(listing.bedrooms !== null ? { bedrooms: listing.bedrooms } : {}),
    ...(listing.bathrooms !== null ? { bathrooms: listing.bathrooms } : {}),
    ...(listing.areaSqm !== null ? { areaSqm: listing.areaSqm } : {}),
    ...(maxGuests !== null ? { maxGuests } : {}),
    ...(amenities.length > 0 ? { amenities } : {}),
    ...(checkIn !== null && isValidTime(checkIn) ? { checkIn } : {}),
    ...(checkOut !== null && isValidTime(checkOut) ? { checkOut } : {}),
    ...(houseRules.length > 0 ? { houseRules } : {}),
    photoCount,
  };
}
