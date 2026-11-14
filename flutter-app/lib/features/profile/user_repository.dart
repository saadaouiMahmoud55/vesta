import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Errors the UI can show. Screens turn them into translated messages.
enum ProfileError {
  notSignedIn,
  nameRequired,
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

  /// Updates name and, if given, photo. The photo is a compressed base64
  /// string (about 200 px, under 100 KB), no Firebase Storage.
  /// [removePhoto] deletes the photo field (the rules accept a profile
  /// without it); it wins over [photoBase64].
  Future<void> updateProfile({
    required String displayName,
    String? photoBase64,
    bool removePhoto = false,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw const ProfileFailure(ProfileError.notSignedIn);

    final name = displayName.trim();
    if (name.isEmpty) throw const ProfileFailure(ProfileError.nameRequired);

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
      default:
        return ProfileError.unknown;
    }
  }
}
