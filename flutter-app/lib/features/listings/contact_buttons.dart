import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/generated/app_localizations.dart';
import '../auth/require_sign_in.dart';
import '../chat/chat_controller.dart';
import 'listing.dart';
import 'listing_controller.dart';

/// Private contact of a listing (contact/info). Read only for signed-in
/// users: a guest never triggers this read (rules + VST-74).
final listingContactProvider = FutureProvider.autoDispose
    .family<({String phone, bool whatsapp})?, String>((ref, listingId) {
      return ref.read(listingRepositoryProvider).getContact(listingId);
    });

/// Call and WhatsApp buttons under the price (VST-79).
/// The phone number is never logged.
class ContactButtons extends ConsumerWidget {
  const ContactButtons({super.key, required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final signedIn = ref.watch(myUidProvider) != null;

    if (!signedIn) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: OutlinedButton.icon(
          onPressed: () => requireSignIn(context, ref),
          icon: const Icon(Icons.lock_outline),
          label: Text(l10n.contactSignInToSee),
        ),
      );
    }

    final contact = ref.watch(listingContactProvider(listing.id)).value;
    if (contact == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: () => _call(context, l10n, contact.phone),
              icon: const Icon(Icons.call),
              label: Text(l10n.contactCall),
            ),
          ),
          if (contact.whatsapp) ...[
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _whatsapp(context, l10n, contact.phone),
                icon: const Icon(Icons.chat),
                label: Text(l10n.contactWhatsapp),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _message(AppLocalizations l10n) {
    switch (offerTypeOf(listing)) {
      case OfferType.sale:
        return l10n.contactMessageSale(listing.title);
      case OfferType.rent:
        return l10n.contactMessageRent(listing.title);
      case OfferType.stay:
        return l10n.contactMessageStay(listing.title);
    }
  }

  Future<void> _call(
    BuildContext context,
    AppLocalizations l10n,
    String phone,
  ) async {
    final ok = await _open(
      Uri(scheme: 'tel', path: phone),
      LaunchMode.externalApplication,
    );
    if (!ok && context.mounted) _snack(context, l10n.contactCallError);
  }

  Future<void> _whatsapp(
    BuildContext context,
    AppLocalizations l10n,
    String phone,
  ) async {
    final digits = phone.replaceAll('+', '');
    final uri = Uri.https('wa.me', '/$digits', {'text': _message(l10n)});
    final ok = await _open(uri, LaunchMode.externalNonBrowserApplication);
    if (!ok && context.mounted) _snack(context, l10n.contactNoWhatsapp);
  }

  Future<bool> _open(Uri uri, LaunchMode mode) async {
    try {
      return await launchUrl(uri, mode: mode);
    } catch (_) {
      return false;
    }
  }

  void _snack(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}
