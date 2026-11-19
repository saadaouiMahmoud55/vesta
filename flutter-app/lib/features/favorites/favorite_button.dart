import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../auth/require_sign_in.dart';
import 'favorites_controller.dart';

/// Heart button: tap to save the listing, tap again to remove it.
/// Shows a filled red heart when saved, an outline heart when not.
///
/// Used on the listing card and on the listing details screen.
class FavoriteButton extends ConsumerWidget {
  const FavoriteButton({super.key, required this.listingId, this.size = 24});

  final String listingId;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Optimistic answer while a save runs, real Firestore state otherwise.
    final isFavorite = ref.watch(isFavoriteProvider(listingId));

    return IconButton(
      iconSize: size,
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: isFavorite ? AppColors.error : null,
      ),
      onPressed: () async {
        // A guest first signs in (VST-72), then the heart is toggled.
        if (!await requireSignIn(context, ref)) return;
        if (!context.mounted) return;
        ref.read(favoritesControllerProvider.notifier).toggle(listingId);
      },
    );
  }
}
