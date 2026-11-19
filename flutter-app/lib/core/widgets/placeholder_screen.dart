import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';

/// Temporary body used by every feature screen until its real ticket is done.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(title, style: textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(l10n.comingSoon, style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}
