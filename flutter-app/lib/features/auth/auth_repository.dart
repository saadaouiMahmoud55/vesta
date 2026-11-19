import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../listings/listing_repository.dart';

/// Errors the UI can show. Screens turn them into translated messages.
enum AuthError {
  invalidEmail,
  passwordTooShort,
  nameRequired,
  emailInUse,
  wrongPassword,
  noNetwork,
  tooManyRequests,
  unknown,
}

class AuthFailure implements Exception {
  const AuthFailure(this.error);

  final AuthError error;
}

/// Only place that talks to Firebase Auth and to the `users` collection.
class AuthRepository {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  /// Emits the signed-in user, or null when signed out.
  /// Until Firebase is configured, the app behaves as signed out.
  Stream<User?> authStateChanges() {
    if (Firebase.apps.isEmpty) return Stream.value(null);
    return _auth.authStateChanges();
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    User? created;
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      created = credential.user!;
      await created.updateDisplayName(displayName);

      // Data model v3: public profile + private contact, one batch write.
      final userRef = _db.collection('users').doc(created.uid);
      final batch = _db.batch();
      batch.set(userRef, {
        'displayName': displayName,
        'createdAt': FieldValue.serverTimestamp(),
      });
      batch.set(userRef.collection('private').doc('contact'), {'email': email});
      await batch.commit();

      // First verification mail. If it fails the account is still fine: the
      // user can ask again from the banner.
      try {
        await created.sendEmailVerification();
      } catch (_) {}
    } on FirebaseAuthException catch (e) {
      await _rollback(created);
      throw AuthFailure(_mapAuthCode(e.code));
    } on FirebaseException catch (e) {
      // Firestore error (for example no network or rules not deployed yet).
      // The Auth account would stay without a profile, so remove it.
      await _rollback(created);
      throw AuthFailure(
        e.code == 'unavailable' ? AuthError.noNetwork : AuthError.unknown,
      );
    }
  }

  /// Deletes the just-created Auth account so a retry does not fail with
  /// "email already in use". Never hides the original error.
  Future<void> _rollback(User? user) async {
    try {
      await user?.delete();
    } catch (_) {}
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_mapAuthCode(e.code));
    }
  }

  Future<void> signOut() => _auth.signOut();

  /// Deletes the account of the signed-in user and its data (VST-84).
  ///
  /// Order: ask the password again (Firebase needs a recent sign-in), then
  /// the listings (photos + contact + listing in one batch each), the
  /// favorites, the private contact and the profile, and the Auth user
  /// LAST: once it is gone the rules refuse every other delete.
  /// Safe to retry: deleting what is already gone is not an error.
  /// Conversations stay for the other person (the rules forbid deleting them).
  /// TODO(VST-84): add blocked users and reports when they exist.
  Future<void> deleteAccount(String password) async {
    final user = _auth.currentUser;
    final email = user?.email;
    if (user == null || email == null) {
      throw const AuthFailure(AuthError.unknown);
    }

    try {
      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: email, password: password),
      );
      final uid = user.uid;

      final listings = await _db
          .collection('listings')
          .where('ownerId', isEqualTo: uid)
          .get();

      for (final listing in listings.docs) {
        final batch = _db.batch();

        // Delete every possible listing photo (p0 through p9).
        for (var i = 0; i < maxListingPhotos; i++) {
          batch.delete(listing.reference.collection('photos').doc('p$i'));
        }

        batch.delete(listing.reference.collection('contact').doc('info'));
        batch.delete(listing.reference);
        await batch.commit();
      }

      final favorites = await _db
          .collection('favorites')
          .where('userId', isEqualTo: uid)
          .get();

      for (final favorite in favorites.docs) {
        await favorite.reference.delete();
      }

      final userRef = _db.collection('users').doc(uid);
      final profileBatch = _db.batch();
      profileBatch.delete(userRef.collection('private').doc('contact'));
      profileBatch.delete(userRef);
      await profileBatch.commit();

      // Delete the Firebase Auth account last.
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_mapAuthCode(e.code));
    } on FirebaseException catch (e) {
      throw AuthFailure(
        e.code == 'unavailable' ? AuthError.noNetwork : AuthError.unknown,
      );
    }
  }

  /// Sends the verification mail to the signed-in user.
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_mapAuthCode(e.code));
    }
  }

  /// Reloads the signed-in user from Firebase and tells if the email is now
  /// verified (the local user object does not change by itself).
  Future<bool> reloadEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) return true;
    await user.reload();
    return _auth.currentUser?.emailVerified ?? true;
  }

  /// Sends the reset mail. An unknown email gives the same result as a known
  /// one, so nobody can find out which emails have an account.
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') return;
      throw AuthFailure(_mapAuthCode(e.code));
    }
  }

  AuthError _mapAuthCode(String code) {
    switch (code) {
      case 'invalid-email':
        return AuthError.invalidEmail;
      case 'email-already-in-use':
        return AuthError.emailInUse;
      case 'weak-password':
        return AuthError.passwordTooShort;
      case 'wrong-password':
      case 'invalid-credential':
      case 'user-not-found':
        return AuthError.wrongPassword;
      case 'network-request-failed':
        return AuthError.noNetwork;
      case 'too-many-requests':
        return AuthError.tooManyRequests;
      default:
        // Shown as a generic message; the code helps to find the cause.
        debugPrint('Unmapped Firebase Auth error code: $code');
        return AuthError.unknown;
    }
  }
}
