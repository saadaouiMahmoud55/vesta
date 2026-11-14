import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config/app_config.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/generated/app_localizations.dart';
import '../listings/listing.dart';
import '../listings/listing_repository.dart';
import 'location_service.dart';
import 'map_controller.dart';
import 'map_listing_preview.dart';

/// OpenStreetMap map with one marker per listing that has a position (VST-42).
///
/// OSM rules: the tile layer says who we are (`userAgentPackageName`), only
/// the tiles of the screen are loaded, and the attribution
/// "© OpenStreetMap contributors" is always visible.
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  // flutter_map's controller (the app's own state lives in the providers).
  final MapController _map = MapController();
  Listing? _selected;
  LatLng? _me;
  bool _locating = false;

  @override
  void dispose() {
    _map.dispose();
    super.dispose();
  }

  Future<void> _locate() async {
    if (_locating) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final service = ref.read(locationServiceProvider);

    setState(() => _locating = true);
    final result = await service.locate();
    if (!mounted) return;
    setState(() => _locating = false);

    switch (result.status) {
      case LocationStatus.granted:
        final position = result.position;
        if (position == null) return;
        setState(() => _me = position);
        _map.move(position, math.max(_map.camera.zoom, 14));
      case LocationStatus.denied:
        messenger.showSnackBar(SnackBar(content: Text(l10n.mapLocationDenied)));
      case LocationStatus.deniedForever:
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.mapLocationDeniedForever),
            action: SnackBarAction(
              label: l10n.mapOpenSettings,
              onPressed: service.openSettings,
            ),
          ),
        );
      case LocationStatus.serviceOff:
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.mapLocationServiceOff)),
        );
      case LocationStatus.error:
        messenger.showSnackBar(SnackBar(content: Text(l10n.mapLocationError)));
    }
  }

  String _errorText(AppLocalizations l10n, Object error) {
    if (error is ListingFailure && error.error == ListingError.noNetwork) {
      return l10n.favoritesErrorNoNetwork;
    }
    return l10n.favoritesErrorUnknown;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final listings = ref.watch(mapListingsProvider);
    final items = listings.value ?? const <MapPin>[];
    final selected = _selected;

    return Stack(
      children: [
        FlutterMap(
          mapController: _map,
          options: MapOptions(
            initialCenter: const LatLng(
              AppConfig.mapCenterLatitude,
              AppConfig.mapCenterLongitude,
            ),
            initialZoom: AppConfig.mapDefaultZoom,
            minZoom: 5,
            maxZoom: 18,
            // A tap on the empty map closes the preview.
            onTap: (_, _) => setState(() => _selected = null),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.vesta.flutterapp',
            ),
            MarkerLayer(
              markers: [
                for (final pin in items)
                  Marker(
                    point: pin.point,
                    width: 96,
                    height: 34,
                    child: GestureDetector(
                      onTap: () => setState(() => _selected = pin.listing),
                      child: _PricePin(
                        text: formatPrice(
                          pin.listing.price,
                          currency: pin.listing.currency,
                        ),
                        selected: pin.listing.id == selected?.id,
                      ),
                    ),
                  ),
              ],
            ),
            if (_me != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: _me!,
                    width: 22,
                    height: 22,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 3),
                      ),
                    ),
                  ),
                ],
              ),
            // Bottom left, so the buttons on the right never cover it.
            RichAttributionWidget(
              alignment: AttributionAlignment.bottomLeft,
              attributions: [
                TextSourceAttribution(
                  'OpenStreetMap contributors',
                  onTap: () => launchUrl(
                    Uri.parse('https://www.openstreetmap.org/copyright'),
                    mode: LaunchMode.externalApplication,
                  ),
                ),
              ],
            ),
          ],
        ),
        if (listings.isLoading)
          const Align(
            alignment: Alignment.topCenter,
            child: LinearProgressIndicator(),
          ),
        if (listings.hasError)
          Align(
            alignment: Alignment.topCenter,
            child: Card(
              color: AppColors.white,
              margin: const EdgeInsets.all(AppSpacing.md),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(child: Text(_errorText(l10n, listings.error!))),
                    TextButton(
                      onPressed: () => ref.invalidate(mapListingsProvider),
                      child: Text(l10n.favoritesRetry),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (listings.hasValue && items.isEmpty)
          Align(
            alignment: Alignment.topCenter,
            child: Card(
              color: AppColors.white,
              margin: const EdgeInsets.all(AppSpacing.md),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(l10n.mapNoListings),
              ),
            ),
          ),
        PositionedDirectional(
          // Above the preview card, which sits at the bottom.
          bottom: selected != null ? 140 : 40,
          end: AppSpacing.lg,
          child: FloatingActionButton.small(
            heroTag: 'map-locate',
            tooltip: l10n.mapMyLocation,
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.primary,
            shape: const CircleBorder(),
            onPressed: _locate,
            child: _locating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location),
          ),
        ),
        if (selected != null)
          Align(
            alignment: Alignment.bottomCenter,
            // Above the attribution, which stays visible.
            child: Padding(
              padding: const EdgeInsets.only(bottom: 28),
              child: MapListingPreview(
                listing: selected,
                onOpen: () =>
                    context.push(AppRoutes.listingDetailPath(selected.id)),
              ),
            ),
          ),
      ],
    );
  }
}

/// Price pill on the map: white with navy text, primary when selected.
class _PricePin extends StatelessWidget {
  const _PricePin({required this.text, required this.selected});

  final String text;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs + 2,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        // The price always reads left to right, also in Arabic.
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.white : AppColors.navy,
            ),
          ),
        ),
      ),
    );
  }
}
