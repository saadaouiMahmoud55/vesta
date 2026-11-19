import {
  collection,
  deleteDoc,
  doc,
  onSnapshot,
  query,
  serverTimestamp,
  setDoc,
  Unsubscribe,
  where,
} from 'firebase/firestore';
import { auth, db } from '../firebase';
import { errorCodeOf } from './authErrors';
import { FavoritesFailure, mapFavoritesCode } from './favoritesErrors';
import { FavoriteDoc, sortFavoriteIds } from '../models/favorite';

/**
 * Only place that talks to the `favorites` collection.
 * One document per favorite, id = `{uid}_{listingId}`: the same listing
 * always lands on the same document, so duplicates are impossible.
 */
export class FavoritesRepository {
  /** Live list of the saved listing ids, newest first. */
  watchFavoriteListingIds(
    onData: (ids: string[]) => void,
    onError: (failure: FavoritesFailure) => void,
  ): Unsubscribe {
    const user = auth.currentUser;
    if (user === null) {
      onData([]);
      return () => {};
    }
    const favorites = query(
      collection(db, 'favorites'),
      where('userId', '==', user.uid),
    );
    return onSnapshot(
      favorites,
      snapshot => {
        onData(
          sortFavoriteIds(snapshot.docs.map(item => item.data() as FavoriteDoc)),
        );
      },
      error => onError(new FavoritesFailure(mapFavoritesCode(errorCodeOf(error)))),
    );
  }

  async add(listingId: string): Promise<void> {
    const user = auth.currentUser;
    if (user === null) {
      throw new FavoritesFailure('notSignedIn');
    }
    try {
      await setDoc(doc(db, 'favorites', `${user.uid}_${listingId}`), {
        userId: user.uid,
        listingId,
        createdAt: serverTimestamp(),
      });
    } catch (error) {
      throw new FavoritesFailure(mapFavoritesCode(errorCodeOf(error)));
    }
  }

  async remove(listingId: string): Promise<void> {
    const user = auth.currentUser;
    if (user === null) {
      throw new FavoritesFailure('notSignedIn');
    }
    try {
      await deleteDoc(doc(db, 'favorites', `${user.uid}_${listingId}`));
    } catch (error) {
      throw new FavoritesFailure(mapFavoritesCode(errorCodeOf(error)));
    }
  }
}

export const favoritesRepository = new FavoritesRepository();
