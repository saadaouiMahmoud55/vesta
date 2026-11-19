import { useEffect, useState } from 'react';
import { ListingContact } from '../../data/models/listingContact';
import { listingsRepository } from '../../data/repositories/listingsRepository';
import { useAuth } from '../auth/authController';

/**
 * Private contact of a listing. Only a signed-in user reads it: a guest must
 * not even try (rules, VST-74). Returns null while loading, for a guest, when
 * the owner gave no number, and when the read fails: the buttons stay hidden.
 * The number is never logged.
 */
export function useListingContact(listingId: string): ListingContact | null {
  const { isSignedIn } = useAuth();
  const [contact, setContact] = useState<ListingContact | null>(null);

  useEffect(() => {
    setContact(null);
    if (!isSignedIn) {
      return undefined;
    }
    let cancelled = false;
    listingsRepository
      .getContact(listingId)
      .then(value => {
        if (!cancelled) {
          setContact(value);
        }
      })
      .catch(() => {
        if (!cancelled) {
          setContact(null);
        }
      });
    return () => {
      cancelled = true;
    };
  }, [isSignedIn, listingId]);

  return contact;
}