import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../listings/listing.dart';

/// Translated label of a status key (the database stores the key only).
String statusLabel(AppLocalizations l, String status) {
  switch (status) {
    case 'available':
      return l.profileStatusAvailable;
    case 'reserved':
      return l.profileStatusReserved;
    case 'sold':
      return l.profileStatusSold;
    case 'rented':
      return l.profileStatusRented;
    case 'unavailable':
      return l.profileStatusUnavailable;
    case 'hidden':
      return l.profileStatusHidden;
    default:
      return status;
  }
}

/// Bottom sheet with the statuses allowed for this listing's offer type.
/// Returns the chosen status, or null if the sheet was closed.
Future<String?> showListingStatusSheet(BuildContext context, Listing listing) {
  final l10n = AppLocalizations.of(context);
  final theme = Theme.of(context);
  final options = allowedStatuses(offerTypeOf(listing));

  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
            child: Text(
              l10n.profileStatusSheetTitle,
              style: theme.textTheme.titleMedium,
            ),
          ),
          for (final status in options)
            ListTile(
              title: Text(statusLabel(l10n, status)),
              trailing: status == listing.status
                  ? Icon(Icons.check, color: theme.colorScheme.primary)
                  : null,
              onTap: () => Navigator.of(ctx).pop(status),
            ),
        ],
      ),
    ),
  );
}
