import { errorCodeOf } from './authErrors';

export type ListingError =
  | 'notSignedIn'
  | 'noPhotos'
  | 'tooManyPhotos'
  | 'noNetwork'
  | 'permissionDenied'
  | 'unknown';

export class ListingFailure extends Error {
  constructor(readonly error: ListingError) {
    super(error);
  }
}

/** Same mapping as _mapCode in the Flutter ListingRepository. */
export function mapListingCode(code: string): ListingError {
  switch (code) {
    case 'unavailable':
    case 'network-request-failed':
      return 'noNetwork';
    case 'permission-denied':
      return 'permissionDenied';
    default:
      return 'unknown';
  }
}

export function listingErrorKey(error: ListingError): string {
  switch (error) {
    case 'notSignedIn':
      return 'listingErrorNotSignedIn';
    case 'noPhotos':
      return 'listingErrorNoPhotos';
    case 'tooManyPhotos':
      return 'listingErrorTooManyPhotos';
    case 'noNetwork':
      return 'listingErrorNoNetwork';
    case 'permissionDenied':
      return 'listingErrorPermissionDenied';
    default:
      return 'listingErrorUnknown';
  }
}

/** Turns anything thrown into a ListingFailure. */
export function toListingFailure(error: unknown): ListingFailure {
  return error instanceof ListingFailure
    ? error
    : new ListingFailure(mapListingCode(errorCodeOf(error)));
}
