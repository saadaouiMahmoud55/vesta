import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/utils/phone_utils.dart';

/// Errors the UI can show. Screens turn them into translated messages.
enum ProfileError {
  notSignedIn,
  nameRequired,
  phoneInvalid,
  emailInvalid,
  emailInUse,
  wrongPassword,
  passwordRequired,
  noNetwork,
  permissionDenied,
  unknown,
}

class ProfileFailure implements Exception {
  const ProfileFailure(this.error);

  final ProfileError error;
}

/// Public profile stored in `users/{uid}` (see docs/data-model.md).
class UserProfile {
  const UserProfile({
    required this.uid,
    required this.displayName,
    this.photoBase64,
  });

  final String uid;
  final String displayName;
  final String? photoBase64;

  factory UserProfile.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return UserProfile(
      uid: doc.id,
      displayName: (data['displayName'] as String?) ?? '',
      photoBase64: data['photoBase64'] as String?,
    );
  }
}

/// Reads and updates the `users` document of the signed-in user.
class UserRepository {
  FirebaseFirestore get _db => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;

  Stream<UserProfile?> watchProfile(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserProfile.fromDoc(doc) : null);
  }

  /// Phone saved in users/{uid}/private/contact (null if none).
  Future<String?> loadPhone() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    try {
      final doc = await _db
          .collection('users')
          .doc(user.uid)
          .collection('private')
          .doc('contact')
          .get();
      return doc.data()?['phone'] as String?;
    } on FirebaseException {
      return null;
    }
  }

  /// Updates name and, if given, photo. The photo is a compressed base64
  /// string (about 480 px, under 120 KB), no Firebase Storage.
  /// [removePhoto] deletes the photo field (the rules accept a profile
  /// without it); it wins over [photoBase64].
  Future<void> updateProfile({
    required String displayName,
    String? photoBase64,
    bool removePhoto = false,
    String? phone, // null = do not touch, empty = remove
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw const ProfileFailure(ProfileError.notSignedIn);

    final name = displayName.trim();
    if (name.isEmpty) throw const ProfileFailure(ProfileError.nameRequired);
    final phoneText = phone?.trim();
    final normalizedPhone = (phoneText == null || phoneText.isEmpty)
        ? null
        : normalizeTunisianPhone(phoneText);
    if (phoneText != null && phoneText.isNotEmpty && normalizedPhone == null) {
      throw const ProfileFailure(ProfileError.phoneInvalid);
    }

    try {
      await _db.collection('users').doc(user.uid).update({
        'displayName': name,
        if (removePhoto)
          'photoBase64': FieldValue.delete()
        else
          'photoBase64': ?photoBase64,
      });
      // Same name in Auth, like AuthRepository.signUp does.
      await user.updateDisplayName(name);
      if (phoneText != null) {
        await _db
            .collection('users')
            .doc(user.uid)
            .collection('private')
            .doc('contact')
            .set({
              if (user.email != null) 'email': user.email,
              'phone': normalizedPhone ?? FieldValue.delete(),
            }, SetOptions(merge: true));
      }
    } on FirebaseException catch (e) {
      throw ProfileFailure(_mapCode(e.code));
    }
  }

  /// Changes the sign-in email: asks Firebase to re-check the password, then
  /// sends a confirmation mail to the NEW address. The email only changes
  /// after the user clicks the link in that mail.
  Future<void> changeEmail({
    required String newEmail,
    required String password,
  }) async {
    final user = _auth.currentUser;
    final current = user?.email;
    if (user == null || current == null) {
      throw const ProfileFailure(ProfileError.notSignedIn);
    }
    try {
      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: current, password: password),
      );
      await user.verifyBeforeUpdateEmail(newEmail.trim());
    } on FirebaseException catch (e) {
      throw ProfileFailure(_mapCode(e.code));
    }
  }

  ProfileError _mapCode(String code) {
    switch (code) {
      case 'unavailable':
      case 'network-request-failed':
        return ProfileError.noNetwork;
      case 'permission-denied':
        return ProfileError.permissionDenied;
      case 'invalid-email':
        return ProfileError.emailInvalid;
      case 'email-already-in-use':
        return ProfileError.emailInUse;
      case 'wrong-password':
      case 'invalid-credential':
      case 'requires-recent-login':
        return ProfileError.wrongPassword;
      default:
        return ProfileError.unknown;
    }
  }
}
