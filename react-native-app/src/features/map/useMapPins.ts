import { useCallback, useEffect, useState } from 'react';
import { listingsRepository } from '../../data/repositories/listingsRepository';
import { MapPin, pinsFor } from './mapPins';

/** How many of the newest listings the map reads (same as Flutter). */
export const mapListLimit = 100;

export type MapPinsState = {
  pins: MapPin[];
  loading: boolean;
  failed: boolean;
  reload: () => void;
};

/** Controller of the map: reads the newest listings and turns them into pins. */
export function useMapPins(): MapPinsState {
  const [pins, setPins] = useState<MapPin[]>([]);
  const [loading, setLoading] = useState(true);
  const [failed, setFailed] = useState(false);
  const [round, setRound] = useState(0);

  useEffect(() => {
    let active = true;
    setLoading(true);
    setFailed(false);
    listingsRepository
      .getLatestListings(mapListLimit)
      .then(listings => active && setPins(pinsFor(listings)))
      .catch(() => active && setFailed(true))
      .finally(() => active && setLoading(false));
    return () => {
      active = false;
    };
  }, [round]);

  const reload = useCallback(() => setRound(n => n + 1), []);
  return { pins, loading, failed, reload };
}
