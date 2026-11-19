import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// What happened when the app tried to find the user (VST-42).
enum LocationStatus {
  /// Position found.
  granted,

  /// The user said no this time. The map still works.
  denied,

  /// The user said "don't ask again": only the phone settings can change it.
  deniedForever,

  /// Location (GPS) is switched off on the phone.
  serviceOff,

  /// Anything else (timeout, no signal...).
  error,
}

class LocationResult {
  const LocationResult(this.status, [this.position]);

  final LocationStatus status;

  /// Only set when [status] is [LocationStatus.granted].
  final LatLng? position;
}

/// The few geolocator calls the app needs. A small interface so that tests
/// can replace the phone.
abstract class LocationGateway {
  Future<bool> isServiceEnabled();
  Future<LocationPermission> checkPermission();
  Future<LocationPermission> requestPermission();
  Future<({double latitude, double longitude})> currentPosition();
  Future<bool> openAppSettings();
}

class GeolocatorGateway implements LocationGateway {
  const GeolocatorGateway();

  @override
  Future<bool> isServiceEnabled() => Geolocator.isLocationServiceEnabled();

  @override
  Future<LocationPermission> checkPermission() => Geolocator.checkPermission();

  @override
  Future<LocationPermission> requestPermission() =>
      Geolocator.requestPermission();

  @override
  Future<({double latitude, double longitude})> currentPosition() async {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    return (latitude: position.latitude, longitude: position.longitude);
  }

  @override
  Future<bool> openAppSettings() => Geolocator.openAppSettings();
}

/// Finds the position of the user, asking the permission properly: only when
/// the user taps "my location", and every refusal is a normal result, never a
/// crash.
class LocationService {
  LocationService([LocationGateway? gateway])
    : _gateway = gateway ?? const GeolocatorGateway();

  final LocationGateway _gateway;

  /// How long to wait for a position before giving up.
  static const Duration timeout = Duration(seconds: 15);

  Future<LocationResult> locate() async {
    try {
      if (!await _gateway.isServiceEnabled()) {
        return const LocationResult(LocationStatus.serviceOff);
      }

      var permission = await _gateway.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await _gateway.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        return const LocationResult(LocationStatus.deniedForever);
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.unableToDetermine) {
        return const LocationResult(LocationStatus.denied);
      }

      final position = await _gateway.currentPosition().timeout(timeout);
      return LocationResult(
        LocationStatus.granted,
        LatLng(position.latitude, position.longitude),
      );
    } catch (_) {
      return const LocationResult(LocationStatus.error);
    }
  }

  /// Opens the settings page of the app (for "denied forever").
  Future<bool> openSettings() async {
    try {
      return await _gateway.openAppSettings();
    } catch (_) {
      return false;
    }
  }
}
