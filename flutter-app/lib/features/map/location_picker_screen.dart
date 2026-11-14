import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config/app_config.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import 'location_service.dart';
import 'map_controller.dart';

/// Full-screen map where the owner taps to place the pin of a listing
/// (VST-42, part 2). Opened from the publish form; returns the chosen
/// [LatLng] with `Navigator.pop`, or nothing if the owner goes back.
///
/// It starts on the exact position already chosen, else on the city the owner
/// typed, else on the whole country. Same OSM rules as the map screen:
/// attribution visible, app identifier on the tiles.
class LocationPickerScreen extends ConsumerStatefulWidget {
  const LocationPickerScreen({super.key, this.initialPoint, this.cityCenter});

  /// The pin already placed (editing the choice).
  final LatLng? initialPoint;

  /// Center of the city typed in the form (no pin yet).
  final LatLng? cityCenter;

  @override
  ConsumerState<LocationPickerScreen> createState() =>
      _LocationPickerScreenState();
}

class _LocationPickerScreenState extends ConsumerState<LocationPickerScreen> {
  final MapController _map = MapController();
  LatLng? _point;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _point = widget.initialPoint;
  }

  @override
  void dispose() {
    _map.dispose();
    super.dispose();
  }

  Future<void> _locate() async {
    if (_locating) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _locating = true);
    final result = await ref.read(locationServiceProvider).locate();
    if (!mounted) return;
    setState(() => _locating = false);

    final position = result.position;
    if (result.status == LocationStatus.granted && position != null) {
      setState(() => _point = position);
      _map.move(position, 17);
      return;
    }
    final text = switch (result.status) {
      LocationStatus.denied => l10n.mapLocationDenied,
      LocationStatus.deniedForever => l10n.mapLocationDeniedForever,
      LocationStatus.serviceOff => l10n.mapLocationServiceOff,
      _ => l10n.mapLocationError,
    };
    messenger.showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final point = _point;

    final start = widget.initialPoint ?? widget.cityCenter;
    final center = start ??
        const LatLng(AppConfig.mapCountryLatitude, AppConfig.mapCountryLongitude);
    final zoom = widget.initialPoint != null
        ? 17.0
        : widget.cityCenter != null
        ? 13.0
        : AppConfig.mapCountryZoom;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.mapPickerTitle)),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _map,
            options: MapOptions(
              initialCenter: center,
              initialZoom: zoom,
              minZoom: 5,
              maxZoom: 18,
              onTap: (_, latLng) => setState(() => _point = latLng),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.vesta.flutterapp',
              ),
              if (point != null)
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
          Align(
            alignment: Alignment.topCenter,
            child: Card(
              margin: const EdgeInsets.all(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  l10n.mapPickerHint,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          PositionedDirectional(
            top: 80,
            end: 12,
            child: FloatingActionButton.small(
              heroTag: 'picker-locate',
              tooltip: l10n.mapMyLocation,
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
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              // Above the attribution, which stays visible.
              minimum: const EdgeInsets.only(bottom: 28),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed:
                        point == null ? null : () => Navigator.pop(context, point),
                    child: Text(l10n.mapPickerConfirm),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
