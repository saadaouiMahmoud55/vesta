import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Errors the UI can show. Screens turn them into translated messages.
enum FavoritesError {
  notSignedIn,
  noNetwork,
  permissionDenied,
  unknown,
}

class FavoritesFailure implements Exception {
  const FavoritesFailure(this.error);

  final FavoritesError error;
}

/// Only place that talks to the `favorites` collection.
///
/// One document per favorite, id = `{uid}_{listingId}` (see
/// docs/data-model.md). The id makes duplicates impossible: the same
/// listing always lands on the same document.
class FavoritesRepository {
  FirebaseFirestore get _db => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _favorites =>
      _db.collection('favorites');

  /// Live list of the ids of the listings the user saved, newest first.
  /// Emits an empty list when nobody is signed in.
  Stream<List<String>> watchFavoriteListingIds() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(const <String>[]);

    return _favorites
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
      final docs = snapshot.docs.toList();
      // Sorted here (not in the query) so no Firestore index is needed.
      // createdAt is null for a moment right after an add (the server has
      // not answered yet): those go first, they are the newest.
      docs.sort((a, b) {
        final ta = a.data()['createdAt'] as Timestamp?;
        final tb = b.data()['createdAt'] as Timestamp?;
        if (ta == null && tb == null) return 0;
        if (ta == null) return -1;
        if (tb == null) return 1;
        return tb.compareTo(ta);
      });
      return [for (final doc in docs) doc.data()['listingId'] as String];
    }).handleError((Object error) {
      if (error is FirebaseException) {
        throw FavoritesFailure(_mapCode(error.code));
      }
      throw const FavoritesFailure(FavoritesError.unknown);
    });
  }

  /// Saves a listing as favorite.
  Future<void> add(String listingId) async {
    final user = _auth.currentUser;
    if (user == null) throw const FavoritesFailure(FavoritesError.notSignedIn);

    try {
      await _favorites.doc('${user.uid}_$listingId').set({
        'userId': user.uid,
        'listingId': listingId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw FavoritesFailure(_mapCode(e.code));
    }
  }

  /// Removes a listing from the favorites.
  Future<void> remove(String listingId) async {
    final user = _auth.currentUser;
    if (user == null) throw const FavoritesFailure(FavoritesError.notSignedIn);

    try {
      await _favorites.doc('${user.uid}_$listingId').delete();
    } on FirebaseException catch (e) {
      throw FavoritesFailure(_mapCode(e.code));
    }
  }

  FavoritesError _mapCode(String code) {
    switch (code) {
      case 'unavailable':
      case 'network-request-failed':
        return FavoritesError.noNetwork;
      case 'permission-denied':
        return FavoritesError.permissionDenied;
      default:
        return FavoritesError.unknown;
    }
  }
}
