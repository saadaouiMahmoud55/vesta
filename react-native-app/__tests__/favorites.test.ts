import {
  favoritesErrorKey,
  mapFavoritesCode,
} from '../src/data/repositories/favoritesErrors';
import { sortFavoriteIds } from '../src/data/models/favorite';

const at = (ms: number) => ({ toMillis: () => ms });

describe('favorites (same rules as the Flutter FavoritesRepository)', () => {
  it('maps the Firestore codes', () => {
    expect(mapFavoritesCode('unavailable')).toBe('noNetwork');
    expect(mapFavoritesCode('network-request-failed')).toBe('noNetwork');
    expect(mapFavoritesCode('permission-denied')).toBe('permissionDenied');
    expect(mapFavoritesCode('something-new')).toBe('unknown');
  });

  it('gives a translation key for every error', () => {
    expect(favoritesErrorKey('notSignedIn')).toBe('favoritesErrorNotSignedIn');
    expect(favoritesErrorKey('noNetwork')).toBe('favoritesErrorNoNetwork');
    expect(favoritesErrorKey('permissionDenied')).toBe(
      'favoritesErrorPermission',
    );
    expect(favoritesErrorKey('unknown')).toBe('favoritesErrorUnknown');
  });

  it('sorts newest first and puts a pending add (null) first', () => {
    const ids = sortFavoriteIds([
      { listingId: 'a', createdAt: at(1) },
      { listingId: 'b', createdAt: at(3) },
      { listingId: 'c', createdAt: null },
      { listingId: 'd', createdAt: at(2) },
    ]);
    expect(ids).toEqual(['c', 'b', 'd', 'a']);
  });
});
