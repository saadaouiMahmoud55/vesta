import { useEffect, useState } from 'react';
import { listingsRepository } from '../../data/repositories/listingsRepository';

/** Cover photos already read (null = the listing has none). */
const cache = new Map<string, string | null>();

/** Cover photo (base64) of a listing, read once and kept while the app runs. */
export function useCoverPhoto(listingId: string): string | null {
  const [cover, setCover] = useState<string | null>(
    cache.get(listingId) ?? null,
  );
  useEffect(() => {
    if (cache.has(listingId)) {
      setCover(cache.get(listingId) ?? null);
      return undefined;
    }
    let active = true;
    listingsRepository
      .getCoverPhotoBase64(listingId)
      .then(base64 => {
        cache.set(listingId, base64);
        if (active) {
          setCover(base64);
        }
      })
      .catch(() => {
        // The card keeps its placeholder.
      });
    return () => {
      active = false;
    };
  }, [listingId]);
  return cover;
}
