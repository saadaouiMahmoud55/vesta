import React, {
  createContext,
  ReactNode,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useRef,
  useState,
} from 'react';
import { User } from 'firebase/auth';
import {
  authRepository,
  SignUpData,
} from '../../data/repositories/authRepository';
import { AuthError, AuthFailure } from '../../data/repositories/authErrors';

type AuthContextValue = {
  /** True when a user is signed in (and no sign up is still in progress). */
  isSignedIn: boolean;
  /** Uid of the signed-in user, null for a guest. */
  uid: string | null;
  /** True until Firebase has told if a session was kept (app start). */
  initializing: boolean;
  isLoading: boolean;
  error: AuthError | null;
  signIn: (email: string, password: string) => Promise<boolean>;
  signUp: (data: SignUpData) => Promise<boolean>;
  signOut: () => Promise<void>;
  clearError: () => void;
};

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({
  children,
}: {
  children: ReactNode;
}): React.JSX.Element {
  const [user, setUser] = useState<User | null>(null);
  const [initializing, setInitializing] = useState(true);
  const [isLoading, setIsLoading] = useState(false);
  const [isSigningUp, setIsSigningUp] = useState(false);
  const [error, setError] = useState<AuthError | null>(null);
  const busy = useRef(false);

  useEffect(() => {
    return authRepository.onAuthStateChanged(nextUser => {
      setUser(nextUser);
      setInitializing(false);
    });
  }, []);

  // One action at a time (no double submit). The loading and error state live
  // here, not in a screen, so they survive the screen changes.
  const run = useCallback(
    async (action: () => Promise<void>, signingUp: boolean) => {
      if (busy.current) {
        return false;
      }
      busy.current = true;
      setIsLoading(true);
      setIsSigningUp(signingUp);
      setError(null);
      try {
        await action();
        return true;
      } catch (failure) {
        setError(failure instanceof AuthFailure ? failure.error : 'unknown');
        return false;
      } finally {
        busy.current = false;
        setIsLoading(false);
        setIsSigningUp(false);
      }
    },
    [],
  );

  const signIn = useCallback(
    (email: string, password: string) =>
      run(() => authRepository.signIn(email.trim(), password), false),
    [run],
  );

  const signUp = useCallback(
    (data: SignUpData) =>
      run(
        () =>
          authRepository.signUp({
            email: data.email.trim(),
            password: data.password,
            displayName: data.displayName.trim(),
          }),
        true,
      ),
    [run],
  );

  const signOut = useCallback(() => authRepository.signOut(), []);
  const clearError = useCallback(() => setError(null), []);

  const value = useMemo<AuthContextValue>(
    () => ({
      // While a sign up runs, Firebase already has the user but the profile
      // is not saved yet: stay on the auth screens until it is done.
      isSignedIn: user !== null && !isSigningUp,
      uid: user !== null && !isSigningUp ? user.uid : null,
      initializing,
      isLoading,
      error,
      signIn,
      signUp,
      signOut,
      clearError,
    }),
    [
      user,
      isSigningUp,
      initializing,
      isLoading,
      error,
      signIn,
      signUp,
      signOut,
      clearError,
    ],
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth(): AuthContextValue {
  const value = useContext(AuthContext);
  if (value === null) {
    throw new Error('useAuth must be used inside AuthProvider');
  }
  return value;
}
