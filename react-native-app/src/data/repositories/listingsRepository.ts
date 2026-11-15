import { doc, getDoc } from 'firebase/firestore';
import { db } from '../firebase';
import { errorCodeOf } from './authErrors';
import { FavoritesFailure, mapFavoritesCode } from './favoritesErrors';
import { Listing, listingFromData } from '../models/listing';
import { ListingContact, contactFromData } from '../models/listingContact';

/** Only place that reads the `listings` collection and its photos. */
export class ListingsRepository {
  /** Same order as `ids`; null means deleted or not readable (hidden). */
  getListingsByIds(ids: string[]): Promise<(Listing | null)[]> {
    return Promise.all(ids.map(id => this.getOrNull(id)));
  }

  private async getOrNull(id: string): Promise<Listing | null> {
    try {
      const snapshot = await getDoc(doc(db, 'listings', id));
      if (!snapshot.exists()) {
        return null;
      }
      return listingFromData(snapshot.id, snapshot.data());
    } catch (error) {
      const code = errorCodeOf(error);
      if (code === 'permission-denied') {
        return null;
      }
      throw new FavoritesFailure(mapFavoritesCode(code));
    }
  }

  /** Cover photo (id p0) as base64, or null. */
  async getCoverPhotoBase64(listingId: string): Promise<string | null> {
    try {
      const snapshot = await getDoc(
        doc(db, 'listings', listingId, 'photos', 'p0'),
      );
      const base64 = snapshot.data()?.base64;
      return typeof base64 === 'string' ? base64 : null;
    } catch (error) {
      const code = errorCodeOf(error);
      if (code === 'permission-denied') {
        return null;
      }
      throw new FavoritesFailure(mapFavoritesCode(code));
    }
  }

  /**
   * Private contact of a listing (contact/info). Call it only for a signed-in
   * user: a guest must not even try (rules). Null when the owner gave no number.
   */
  async getContact(listingId: string): Promise<ListingContact | null> {
    try {
      const snapshot = await getDoc(
        doc(db, 'listings', listingId, 'contact', 'info'),
      );
      return contactFromData(snapshot.data());
    } catch (error) {
      const code = errorCodeOf(error);
      if (code === 'permission-denied') {
        return null;
      }
      throw new FavoritesFailure(mapFavoritesCode(code));
    }
  }
}

export const listingsRepository = new ListingsRepository();
