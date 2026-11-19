import type { Persistence } from 'firebase/auth';

// The React Native build of firebase/auth exports getReactNativePersistence,
// but the default types (used by tsc) do not list it.
interface AsyncStorageLike {
  getItem(key: string): Promise<string | null>;
  setItem(key: string, value: string): Promise<void>;
  removeItem(key: string): Promise<void>;
}

declare module 'firebase/auth' {
  export function getReactNativePersistence(
    storage: AsyncStorageLike,
  ): Persistence;
}
