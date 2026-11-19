import { useCallback, useEffect, useRef, useState } from 'react';
import { favoritesRepository } from '../../data/repositories/favoritesRepository';
import {
  FavoritesError,
  FavoritesFailure,
} from '../../data/repositories/favoritesErrors';
import { useAuth } from '../auth/authController';

/** Screens call this hook. It talks to the repository only. */
export function useFavorites() {
  const { isSignedIn } = useAuth();
  const [ids, setIds] = useState<string[]>([]);
  const [loading, setLoading] = useState(true);
  // Optimistic answers: listingId -> what the heart must show right now.
  const [pending, setPending] = useState<Record<string, boolean>>({});
  const [error, setError] = useState<FavoritesError | null>(null);
  const [attempt, setAttempt] = useState(0);
  const inFlight = useRef<Set<string>>(new Set());

  // Restarts by itself when the user signs in or out.
  useEffect(() => {
    setLoading(true);
    setError(null);
    return favoritesRepository.watchFavoriteListingIds(
      next => {
        setIds(next);
        setLoading(false);
      },
      failure => {
        setError(failure.error);
        setLoading(false);
      },
    );
  }, [isSignedIn, attempt]);

  const isFavorite = useCallback(
    (listingId: string) => pending[listingId] ?? ids.includes(listingId),
    [pending, ids],
  );

  /** Tap on the heart: add if not saved, remove if saved. */
  const toggle = useCallback(
    async (listingId: string) => {
      // Ignore a second tap while the first save is still running.
      if (inFlight.current.has(listingId)) {
        return;
      }
      if (!isSignedIn) {
        setError('notSignedIn');
        return;
      }
      const wantSaved = !ids.includes(listingId);
      inFlight.current.add(listingId);
      setPending(current => ({ ...current, [listingId]: wantSaved }));
      try {
        if (wantSaved) {
          await favoritesRepository.add(listingId);
        } else {
          await favoritesRepository.remove(listingId);
        }
      } catch (failure) {
        setError(
          failure instanceof FavoritesFailure ? failure.error : 'unknown',
        );
      } finally {
        inFlight.current.delete(listingId);
        // Dropping the optimistic value rolls the heart back to the real
        // state (success: the live list already knows the change).
        setPending(current => {
          const next = { ...current };
          delete next[listingId];
          return next;
        });
      }
    },
    [ids, isSignedIn],
  );

  const clearError = useCallback(() => setError(null), []);
  const retry = useCallback(() => setAttempt(count => count + 1), []);

  return { ids, loading, error, isFavorite, toggle, clearError, retry };
}
