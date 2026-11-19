export type FavoritesError =
  | 'notSignedIn'
  | 'noNetwork'
  | 'permissionDenied'
  | 'unknown';

export class FavoritesFailure extends Error {
  readonly error: FavoritesError;

  constructor(error: FavoritesError) {
    super(error);
    this.name = 'FavoritesFailure';
    this.error = error;
  }
}

/** Same mapping as the Flutter FavoritesRepository. */
export function mapFavoritesCode(code: string): FavoritesError {
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

export function favoritesErrorKey(error: FavoritesError): string {
  switch (error) {
    case 'notSignedIn':
      return 'favoritesErrorNotSignedIn';
    case 'noNetwork':
      return 'favoritesErrorNoNetwork';
    case 'permissionDenied':
      return 'favoritesErrorPermission';
    default:
      return 'favoritesErrorUnknown';
  }
}
