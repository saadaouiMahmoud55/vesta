import { useCallback, useEffect, useRef, useState } from 'react';
import { Listing } from '../../data/models/listing';
import {
  FavoritesError,
  FavoritesFailure,
} from '../../data/repositories/favoritesErrors';
import { listingsRepository } from '../../data/repositories/listingsRepository';

export type FavoriteItem = { id: string; listing: Listing | null };

/** Loads the listings behind the favorite ids and keeps successful reads cached. */
export function useFavoriteListings(ids: string[]) {
  const cache = useRef<Map<string, Listing | null>>(new Map());
  const [, setVersion] = useState(0);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<FavoritesError | null>(null);
  const [attempt, setAttempt] = useState(0);
  const key = JSON.stringify(ids);

  useEffect(() => {
    const wanted: string[] = JSON.parse(key);
    const missing = wanted.filter(id => !cache.current.has(id));
    setError(null);
    if (missing.length === 0) {
      setLoading(false);
      return;
    }

    let cancelled = false;
    setLoading(true);
    listingsRepository
      .getListingsByIds(missing)
      .then(results => {
        if (cancelled) {
          return;
        }
        missing.forEach((id, index) => cache.current.set(id, results[index]));
        setVersion(count => count + 1);
        setLoading(false);
      })
      .catch(failure => {
        if (cancelled) {
          return;
        }
        setError(
          failure instanceof FavoritesFailure ? failure.error : 'unknown',
        );
        setLoading(false);
      });

    return () => {
      cancelled = true;
    };
  }, [key, attempt]);

  const items: FavoriteItem[] = ids
    .filter(id => cache.current.has(id))
    .map(id => ({ id, listing: cache.current.get(id) ?? null }));
  const isMissing = error === null && ids.some(id => !cache.current.has(id));

  const retry = useCallback(() => setAttempt(count => count + 1), []);

  return { items, loading: loading || isMissing, error, retry };
}
