import { useCallback, useEffect, useState } from 'react';
import { Listing } from '../../data/models/listing';
import { listingsRepository } from '../../data/repositories/listingsRepository';

export type ListingDetailState =
  | { status: 'loading' }
  | { status: 'error' }
  | { status: 'notFound' }
  | { status: 'ready'; listing: Listing; photos: string[] };

/** One listing with its photos (same as listingDetailProvider in Flutter). */
export function useListingDetail(listingId: string): {
  state: ListingDetailState;
  retry: () => void;
} {
  const [state, setState] = useState<ListingDetailState>({ status: 'loading' });
  const [attempt, setAttempt] = useState(0);

  useEffect(() => {
    let active = true;
    setState({ status: 'loading' });
    (async () => {
      try {
        const listing = await listingsRepository.getListing(listingId);
        if (!listing) {
          if (active) {
            setState({ status: 'notFound' });
          }
          return;
        }
        const photos = await listingsRepository.getPhotos(listingId);
        if (active) {
          setState({ status: 'ready', listing, photos });
        }
      } catch {
        if (active) {
          setState({ status: 'error' });
        }
      }
    })();
    return () => {
      active = false;
    };
  }, [listingId, attempt]);

  const retry = useCallback(() => setAttempt(n => n + 1), []);
  return { state, retry };
}
