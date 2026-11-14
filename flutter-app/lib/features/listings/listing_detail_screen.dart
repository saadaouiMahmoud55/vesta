import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/app_config.dart';
import '../../core/router/app_router.dart';
import '../../l10n/generated/app_localizations.dart';
import 'contact_buttons.dart';
import '../auth/require_sign_in.dart';
import '../chat/chat_controller.dart';
import '../chat/chat_repository.dart';
import 'listing.dart';
import 'listing_controller.dart';
import 'listing_labels.dart';
import 'listing_location_card.dart';

/// Details of one listing (VST-73 and VST-81): photos, price, city, "At a
/// glance" facts, description, amenities, check-in/out and house rules.
/// Read only. The favorite heart and the contact buttons are added later by
/// their own tickets, in the slots marked SLOT below.
class ListingDetailScreen extends ConsumerWidget {
  const ListingDetailScreen({super.key, required this.listingId});

  final String listingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final detail = ref.watch(listingDetailProvider(listingId));

    return detail.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => _Message(
        text: l10n.listingDetailLoadError,
        actionLabel: l10n.listingDetailRetry,
        onAction: () => ref.invalidate(listingDetailProvider(listingId)),
      ),
      data: (data) => data == null
          ? _Message(text: l10n.listingDetailNotFound)
          : _DetailBody(data: data),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, this.actionLabel, this.onAction});

  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text, textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

class _Fact {
  const _Fact(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.data});

  final ListingDetail data;

  /// "Contact owner" (VST-44): a guest signs in first, then the chat of this
  /// listing opens. The owner never talks to himself.
  Future<void> _contactOwner(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (!await requireSignIn(context, ref)) return;
    if (!context.mounted) return;
    try {
      final id =
          ref.read(chatRepositoryProvider).conversationIdForListing(data.listing);
      context.push(AppRoutes.chatRoomPath(id));
    } on ChatFailure catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text(
          e.error == ChatError.ownListing
              ? l10n.chatOwnListing
              : l10n.chatContactError,
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final listing = data.listing;
    final myUid = ref.watch(myUidProvider);
    final isOwner = myUid != null && myUid == listing.ownerId;

    // "At a glance": only the facts the owner filled in.
    final facts = <_Fact>[
      if (listing.maxGuests != null)
        _Fact(
          Icons.people_outline,
          l10n.listingDetailGuests,
          _number(listing.maxGuests!),
        ),
      if (listing.bedrooms != null)
        _Fact(
          Icons.bed_outlined,
          l10n.listingDetailBedrooms,
          _number(listing.bedrooms!),
        ),
      if (listing.bathrooms != null)
        _Fact(
          Icons.bathtub_outlined,
          l10n.listingDetailBathrooms,
          _number(listing.bathrooms!),
        ),
      if (listing.areaSqm != null)
        _Fact(
          Icons.square_foot,
          l10n.listingDetailArea,
          _number(listing.areaSqm!),
        ),
    ];
    final hasTimes = listing.checkIn != null || listing.checkOut != null;

    return ListView(
      children: [
        _PhotoGallery(
          photos: data.photos,
          emptyLabel: l10n.listingDetailNoPhoto,
        ),
        if (listing.isUnavailable)
          Container(
            width: double.infinity,
            color: theme.colorScheme.surfaceContainerHighest,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              l10n.favoritesUnavailable,
              style: theme.textTheme.labelLarge,
            ),
          ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _priceText(l10n, listing),
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  // SLOT: favorite heart (VST-46, Mahmoud)
                ],
              ),
              // Call and WhatsApp buttons under the price (VST-79). A guest
              // sees "Sign in to see the contact" (requireSignIn).
              ContactButtons(listing: listing),
              if (!isOwner) ...[
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => _contactOwner(context, ref),
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: Text(l10n.chatContactOwner),
                ),
              ],
              const SizedBox(height: 8),
              Text(listing.title, style: theme.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                listing.city,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (listing.hasLocation)
                _Section(
                  title: l10n.listingDetailLocation,
                  child: ListingLocationCard(listing: listing),
                ),
              if (facts.isNotEmpty)
                _Section(
                  title: l10n.listingDetailAtAGlance,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final fact in facts)
                          Expanded(child: _FactTile(fact: fact)),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              _ExpandableText(
                text: listing.description,
                style: theme.textTheme.bodyLarge,
                moreLabel: l10n.listingDetailReadMore,
                lessLabel: l10n.listingDetailReadLess,
              ),
              if (listing.amenities.isNotEmpty)
                _Section(
                  title: l10n.publishAmenitiesTitle,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final key in listing.amenities)
                        Chip(
                          avatar: Icon(amenityIcon(key), size: 18),
                          label: Text(amenityLabel(l10n, key)),
                        ),
                    ],
                  ),
                ),
              if (hasTimes)
                _Section(
                  title: '${l10n.publishCheckIn} / ${l10n.publishCheckOut}',
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (listing.checkIn != null)
                        Expanded(
                          child: _TimeTile(
                            label: l10n.publishCheckIn,
                            time: listing.checkIn!,
                          ),
                        ),
                      if (listing.checkOut != null)
                        Expanded(
                          child: _TimeTile(
                            label: l10n.publishCheckOut,
                            time: listing.checkOut!,
                          ),
                        ),
                    ],
                  ),
                ),
              if (listing.houseRules.isNotEmpty)
                _Section(
                  title: l10n.publishRulesTitle,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final key in listing.houseRules)
                        Chip(
                          avatar: Icon(houseRuleIcon(key), size: 18),
                          label: Text(houseRuleLabel(l10n, key)),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A titled block of the details page.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _FactTile extends StatelessWidget {
  const _FactTile({required this.fact});

  final _Fact fact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(fact.icon, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          fact.value,
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          fact.label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _TimeTile extends StatelessWidget {
  const _TimeTile({required this.label, required this.time});

  final String label;
  final String time; // 'HH:mm', as stored

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(Icons.schedule, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(time, style: theme.textTheme.titleMedium),
            ],
          ),
        ),
      ],
    );
  }
}

/// Text folded to 4 lines, with a "Read more" button only when it is longer.
class _ExpandableText extends StatefulWidget {
  const _ExpandableText({
    required this.text,
    required this.style,
    required this.moreLabel,
    required this.lessLabel,
  });

  final String text;
  final TextStyle? style;
  final String moreLabel;
  final String lessLabel;

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  static const _collapsedLines = 4;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final style = widget.style ?? DefaultTextStyle.of(context).style;

    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: widget.text, style: style),
          maxLines: _collapsedLines,
          textDirection: Directionality.of(context),
        )..layout(maxWidth: constraints.maxWidth);
        final overflows = painter.didExceedMaxLines;
        painter.dispose();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.text,
              style: style,
              maxLines: _expanded ? null : _collapsedLines,
              overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
            if (overflows)
              TextButton(
                onPressed: () => setState(() => _expanded = !_expanded),
                child: Text(_expanded ? widget.lessLabel : widget.moreLabel),
              ),
          ],
        );
      },
    );
  }
}

/// formatPrice is the only function that formats a price. The unit is added
/// for a stay (night) and for a rental (month or year). The offer type comes
/// from offerTypeOf: the rule is not written a second time here.
String _priceText(AppLocalizations l10n, Listing listing) {
  final price = formatPrice(listing.price, currency: listing.currency);
  switch (offerTypeOf(listing)) {
    case OfferType.sale:
      return price;
    case OfferType.stay:
      return '$price ${l10n.listingDetailPerNight}';
    case OfferType.rent:
      switch (listing.rentPeriod) {
        case 'year':
          return '$price ${l10n.listingDetailPerYear}';
        case 'month':
          return '$price ${l10n.listingDetailPerMonth}';
        default:
          return price;
      }
  }
}

/// 3.0 is shown as 3.
String _number(num value) =>
    value == value.roundToDouble() ? value.toInt().toString() : '$value';

class _PhotoGallery extends StatefulWidget {
  const _PhotoGallery({required this.photos, required this.emptyLabel});

  final List<Uint8List> photos;
  final String emptyLabel;

  @override
  State<_PhotoGallery> createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends State<_PhotoGallery> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.photos.isEmpty) {
      return AspectRatio(
        aspectRatio: 4 / 3,
        child: Container(
          color: theme.colorScheme.surfaceContainerHighest,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.home_work_outlined, size: 48),
              const SizedBox(height: 8),
              Text(widget.emptyLabel),
            ],
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.photos.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) => Image.memory(
              widget.photos[i],
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (context, error, stackTrace) =>
                  const Center(child: Icon(Icons.broken_image_outlined)),
            ),
          ),
          if (widget.photos.length > 1)
            PositionedDirectional(
              bottom: 8,
              end: 8,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('${_index + 1} / ${widget.photos.length}'),
              ),
            ),
        ],
      ),
    );
  }
}
