import {
  createUserWithEmailAndPassword,
  deleteUser,
  onAuthStateChanged,
  sendEmailVerification,
  signInWithEmailAndPassword,
  signOut as firebaseSignOut,
  Unsubscribe,
  updateProfile,
  User,
} from 'firebase/auth';
import { doc, serverTimestamp, writeBatch } from 'firebase/firestore';
import { auth, db } from '../firebase';
import { AuthFailure, errorCodeOf, mapAuthCode } from './authErrors';

export type SignUpData = {
  email: string;
  password: string;
  displayName: string;
};

/** Only place that talks to Firebase Auth and to the `users` collection. */
export class AuthRepository {
  /** Calls back with the signed-in user, or null when signed out. */
  onAuthStateChanged(listener: (user: User | null) => void): Unsubscribe {
    return onAuthStateChanged(auth, listener);
  }

  async signUp({ email, password, displayName }: SignUpData): Promise<void> {
    let created: User | null = null;
    try {
      const credential = await createUserWithEmailAndPassword(
        auth,
        email,
        password,
      );
      created = credential.user;
      await updateProfile(created, { displayName });

      // Data model v3: public profile + private contact, one batch write.
      const userRef = doc(db, 'users', created.uid);
      const batch = writeBatch(db);
      batch.set(userRef, { displayName, createdAt: serverTimestamp() });
      batch.set(doc(db, 'users', created.uid, 'private', 'contact'), {
        email,
      });
      await batch.commit();

      // First verification mail. If it fails the account is still fine.
      try {
        await sendEmailVerification(created);
      } catch {
        // Ignored on purpose.
      }
    } catch (error) {
      // An Auth account without a profile would block a retry ("email already
      // in use"), so remove it. The original error is never hidden.
      await this.rollback(created);
      throw new AuthFailure(mapAuthCode(errorCodeOf(error)));
    }
  }

  async signIn(email: string, password: string): Promise<void> {
    try {
      await signInWithEmailAndPassword(auth, email, password);
    } catch (error) {
      throw new AuthFailure(mapAuthCode(errorCodeOf(error)));
    }
  }

  signOut(): Promise<void> {
    return firebaseSignOut(auth);
  }

  private async rollback(user: User | null): Promise<void> {
    try {
      if (user) {
        await deleteUser(user);
      }
    } catch {
      // Ignored on purpose.
    }
  }
}

export const authRepository = new AuthRepository();
