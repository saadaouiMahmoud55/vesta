import {
  collection,
  doc,
  getDoc,
  getDocs,
  limit,
  orderBy,
  query,
  serverTimestamp,
  writeBatch,
} from 'firebase/firestore';
import { appConfig } from '../../core/config';
import { auth, db } from '../firebase';
import { errorCodeOf } from './authErrors';
import { FavoritesFailure, mapFavoritesCode } from './favoritesErrors';
import { ListingFailure, toListingFailure } from './listingErrors';
import { Listing, listingFromData } from '../models/listing';
import { ListingContact, contactFromData } from '../models/listingContact';
import {
  listingDocumentData,
  maxListingPhotos,
  NewListing,
} from '../models/newListing';
import { photosFromDocs } from '../models/photoList';

/** Only place that reads the `listings` collection and its photos. */
export class ListingsRepository {
  /** Newest listings first, hidden ones left out. One small read, no index (same as Flutter). */
  async getLatestListings(max = 100): Promise<Listing[]> {
    try {
      const snapshot = await getDocs(
        query(collection(db, 'listings'), orderBy('createdAt', 'desc'), limit(max)),
      );
      return snapshot.docs
        .map(item => listingFromData(item.id, item.data()))
        .filter(listing => listing.status !== 'hidden');
    } catch (error) {
      throw new FavoritesFailure(mapFavoritesCode(errorCodeOf(error)));
    }
  }

  /** One listing, or null when it does not exist or cannot be read (hidden). */
  getListing(id: string): Promise<Listing | null> {
    return this.getOrNull(id);
  }

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

  createListing = createListing;

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

  /** All the photos of a listing as base64, sorted by id (p0 = cover first). */
  async getPhotos(listingId: string): Promise<string[]> {
    try {
      const snapshot = await getDocs(
        collection(db, 'listings', listingId, 'photos'),
      );
      return photosFromDocs(
        snapshot.docs.map(item => ({
          id: item.id,
          base64: item.data().base64,
        })),
      );
    } catch (error) {
      const code = errorCodeOf(error);
      if (code === 'permission-denied') {
        return [];
      }
      throw new FavoritesFailure(mapFavoritesCode(code));
    }
  }
}

/** Creates a listing, its photos and its private contact in ONE batch. */
async function createListing(
  listing: NewListing,
  photosBase64: string[],
): Promise<string> {
  const user = auth.currentUser;
  try {
    if (!user) {
      throw new ListingFailure('notSignedIn');
    }
    if (photosBase64.length === 0) {
      throw new ListingFailure('noPhotos');
    }
    if (photosBase64.length > maxListingPhotos) {
      throw new ListingFailure('tooManyPhotos');
    }
    const ref = doc(collection(db, 'listings')); // auto id
    const batch = writeBatch(db);
    batch.set(ref, {
      ...listingDocumentData(
        listing,
        user.uid,
        appConfig.currency,
        photosBase64.length,
      ),
      createdAt: serverTimestamp(),
      updatedAt: serverTimestamp(),
    });
    // Fixed ids p0..p9: the id gives the display order, p0 is the cover.
    photosBase64.forEach((base64, index) => {
      batch.set(doc(ref, 'photos', `p${index}`), {
        base64,
        createdAt: serverTimestamp(),
      });
    });
    // The phone stays outside the public listing document.
    batch.set(doc(ref, 'contact', 'info'), {
      contactPhone: listing.contactPhone,
      whatsappEnabled: listing.whatsappEnabled,
      updatedAt: serverTimestamp(),
    });
    await batch.commit();
    return ref.id;
  } catch (error) {
    throw toListingFailure(error);
  }
}

export const listingsRepository = new ListingsRepository();