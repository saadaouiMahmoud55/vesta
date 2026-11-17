import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { Listing } from '../../data/models/listing';
import { ListingCategory } from '../../data/models/listingCategory';
import {
  FavoritesError,
  FavoritesFailure,
} from '../../data/repositories/favoritesErrors';
import { listingsRepository } from '../../data/repositories/listingsRepository';
import {
  activeFilterCount,
  applyFilters,
  emptyFilters,
  SEARCH_DEBOUNCE_MS,
  SEARCH_LIST_LIMIT,
  SearchFilters,
} from './searchFilters';

/** Reads the newest listings once, then filters them in memory (as Flutter). */
export function useSearchController() {
  const [filters, setFilters] = useState<SearchFilters>(emptyFilters);
  const [listings, setListings] = useState<Listing[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<FavoritesError | null>(null);
  const timer = useRef<ReturnType<typeof setTimeout> | null>(null);

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      setListings(
        await listingsRepository.getLatestListings(SEARCH_LIST_LIMIT),
      );
    } catch (failure) {
      setError(failure instanceof FavoritesFailure ? failure.error : 'unknown');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
        load();
    return () => {
      if (timer.current) {
        clearTimeout(timer.current);
      }
    };
  }, [load]);

  /** Called on every keystroke: only the last one, 400 ms later, counts. */
  const setCity = useCallback((text: string) => {
    if (timer.current) {
      clearTimeout(timer.current);
    }
    timer.current = setTimeout(() => {
      setFilters(current => ({ ...current, city: text }));
    }, SEARCH_DEBOUNCE_MS);
  }, []);

  const setPriceRange = useCallback(
    (minPrice: number | null, maxPrice: number | null) =>
      setFilters(current => ({ ...current, minPrice, maxPrice })),
    [],
  );

  const setOfferType = useCallback(
    (offerType: ListingCategory | null) =>
      setFilters(current => ({ ...current, offerType })),
    [],
  );

  const setPropertyType = useCallback(
    (propertyType: string | null) =>
      setFilters(current => ({ ...current, propertyType })),
    [],
  );

  const reset = useCallback(() => {
    if (timer.current) {
      clearTimeout(timer.current);
    }
    setFilters(emptyFilters);
  }, []);

  const results = useMemo(
    () => applyFilters(listings, filters),
    [listings, filters],
  );

  return {
    filters,
    results,
    loading,
    error,
    activeCount: activeFilterCount(filters),
    setCity,
    setPriceRange,
    setOfferType,
    setPropertyType,
    reset,
    reload: load,
  };
}