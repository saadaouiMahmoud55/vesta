import { useCallback, useState } from 'react';
import { Listing } from '../../data/models/listing';
import { listingsRepository } from '../../data/repositories/listingsRepository';
import { loadErrorKey } from './loadErrorKey';

export type LatestListings = {
  listings: Listing[];
  /** True until the first read is over. */
  loading: boolean;
  /** True during a pull-down refresh. */
  refreshing: boolean;
  /** Translation key of the error of the last read, or null. */
  errorKey: string | null;
  reload: (fromPullDown?: boolean) => Promise<void>;
};

/** Newest listings for the Explore tab (same as latestListingsProvider in Flutter). */
export function useLatestListings(): LatestListings {
  const [listings, setListings] = useState<Listing[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [errorKey, setErrorKey] = useState<string | null>(null);

  const reload = useCallback(async (fromPullDown = false) => {
    if (fromPullDown) {
      setRefreshing(true);
    }
    try {
      setListings(await listingsRepository.getLatestListings());
      setErrorKey(null);
    } catch (error) {
      setErrorKey(loadErrorKey(error));
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  }, []);

  return { listings, loading, refreshing, errorKey, reload };
}
