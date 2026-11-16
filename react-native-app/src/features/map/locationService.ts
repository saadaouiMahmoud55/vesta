import * as Location from 'expo-location';

export type LocationStatus =
  | 'granted'
  | 'denied'
  | 'deniedForever'
  | 'serviceOff'
  | 'error';

export type LocationResult = {
  status: LocationStatus;
  latitude?: number;
  longitude?: number;
};

/** Finds the user once. Never throws: the map works without it. */
export async function findMe(): Promise<LocationResult> {
  try {
    if (!(await Location.hasServicesEnabledAsync())) {
      return { status: 'serviceOff' };
    }
    let permission = await Location.getForegroundPermissionsAsync();
    if (!permission.granted && permission.canAskAgain) {
      permission = await Location.requestForegroundPermissionsAsync();
    }
    if (!permission.granted) {
      return { status: permission.canAskAgain ? 'denied' : 'deniedForever' };
    }
    const position = await Location.getCurrentPositionAsync({
      accuracy: Location.Accuracy.High,
    });
    return {
      status: 'granted',
      latitude: position.coords.latitude,
      longitude: position.coords.longitude,
    };
  } catch {
    return { status: 'error' };
  }
}

/** Translation key of the message to show for a failed result. */
export function locationMessageKey(status: LocationStatus): string | null {
  switch (status) {
    case 'denied':
      return 'mapLocationDenied';
    case 'deniedForever':
      return 'mapLocationDeniedForever';
    case 'serviceOff':
      return 'mapLocationServiceOff';
    case 'error':
      return 'mapLocationError';
    default:
      return null;
  }
}
