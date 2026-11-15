import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import 'listing.dart';

/// Small read-only map under the city on the details screen: the exact pin
/// the owner placed. Shown only when the listing has a position. The map does
/// not move (no zoom or drag), so it never fights with the page scroll; the
/// button opens the position in the phone's map app.
class ListingLocationCard extends StatelessWidget {
  const ListingLocationCard({super.key, required this.listing});

  final Listing listing;

  static Uri mapsUri(double latitude, double longitude) => Uri.parse(
    'https://www.openstreetmap.org/?mlat=$latitude&mlon=$longitude'
    '#map=17/$latitude/$longitude',
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final point = LatLng(listing.latitude!, listing.longitude!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 180,
            // The map reads left-to-right even in Arabic: it is a drawing.
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: point,
                  initialZoom: 15,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.vesta.flutterapp',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: point,
                        width: 48,
                        height: 48,
                        // The tip of the pin is on the position.
                        alignment: Alignment.topCenter,
                        child: const Icon(
                          Icons.location_on,
                          size: 44,
                          color: AppColors.terracotta,
                        ),
                      ),
                    ],
                  ),
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
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => launchUrl(
            mapsUri(point.latitude, point.longitude),
            mode: LaunchMode.externalApplication,
          ),
          icon: const Icon(Icons.map_outlined),
          label: Text(l10n.listingDetailOpenMaps),
        ),
      ],
    );
  }
}
