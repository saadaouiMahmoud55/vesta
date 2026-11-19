import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'favorites_repository.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepository>(
  (ref) => FavoritesRepository(),
);

/// Current signed-in user (null when signed out).
final _authUserProvider = StreamProvider<User?>(
  (ref) => FirebaseAuth.instance.authStateChanges(),
);

/// Live list of the saved listing ids, newest first.
/// Restarts by itself when the user signs in or out.
final favoriteIdsProvider = StreamProvider<List<String>>((ref) {
  ref.watch(_authUserProvider);
  return ref.watch(favoritesRepositoryProvider).watchFavoriteListingIds();
});

/// State of the actions (add / remove), not of the list itself.
class FavoritesState {
  const FavoritesState({this.pending = const {}, this.error});

  /// Optimistic answers: listingId -> what the heart must show right now,
  /// while the save is still running.
  final Map<String, bool> pending;
  final FavoritesError? error;
}

/// Screens call this. It talks to [FavoritesRepository] only.
class FavoritesController extends Notifier<FavoritesState> {
  @override
  FavoritesState build() => const FavoritesState();

  FavoritesRepository get _repository => ref.read(favoritesRepositoryProvider);

  bool _isSaved(String listingId) {
    final ids = ref.read(favoriteIdsProvider).value ?? const <String>[];
    return ids.contains(listingId);
  }

  /// Tap on the heart: add if not saved, remove if saved.
  Future<void> toggle(String listingId) async {
    // Ignore a second tap while the first save is still running.
    if (state.pending.containsKey(listingId)) return;

    if (FirebaseAuth.instance.currentUser == null) {
      state = const FavoritesState(error: FavoritesError.notSignedIn);
      return;
    }

    final wantSaved = !_isSaved(listingId);

    // Update the screen immediately.
    state = FavoritesState(pending: {...state.pending, listingId: wantSaved});

    try {
      if (wantSaved) {
        await _repository.add(listingId);
      } else {
        await _repository.remove(listingId);
      }
      // The live list now knows the change, so drop the optimistic value.
      state = FavoritesState(pending: _without(listingId));
    } on FavoritesFailure catch (e) {
      // Dropping the optimistic value rolls the heart back to Firestore state.
      state = FavoritesState(pending: _without(listingId), error: e.error);
    } catch (_) {
      state = FavoritesState(
        pending: _without(listingId),
        error: FavoritesError.unknown,
      );
    }
  }

  void clearError() {
    if (state.error == null) return;
    state = FavoritesState(pending: state.pending);
  }

  Map<String, bool> _without(String listingId) {
    return Map<String, bool>.of(state.pending)..remove(listingId);
  }
}

final favoritesControllerProvider =
    NotifierProvider<FavoritesController, FavoritesState>(
  FavoritesController.new,
);

/// What the heart of one listing must show: the optimistic answer if a save
/// is running, otherwise the real state from Firestore.
final isFavoriteProvider = Provider.family<bool, String>((ref, listingId) {
  final pending = ref.watch(
    favoritesControllerProvider.select((s) => s.pending[listingId]),
  );
  if (pending != null) return pending;
  final ids = ref.watch(favoriteIdsProvider).value ?? const <String>[];
  return ids.contains(listingId);
});
