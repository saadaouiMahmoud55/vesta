import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/features/map/location_service.dart';
import 'package:geolocator/geolocator.dart';

/// A phone that answers what the test says. Records what the service asks.
class _FakeGateway implements LocationGateway {
  _FakeGateway({
    this.serviceOn = true,
    this.permission = LocationPermission.whileInUse,
    this.afterRequest = LocationPermission.whileInUse,
    this.throwOnPosition = false,
  });

  final bool serviceOn;
  final LocationPermission permission;
  final LocationPermission afterRequest;
  final bool throwOnPosition;
  var requested = false;
  var positionRead = false;

  @override
  Future<bool> isServiceEnabled() async => serviceOn;

  @override
  Future<LocationPermission> checkPermission() async => permission;

  @override
  Future<LocationPermission> requestPermission() async {
    requested = true;
    return afterRequest;
  }

  @override
  Future<({double latitude, double longitude})> currentPosition() async {
    positionRead = true;
    if (throwOnPosition) throw Exception('no signal');
    return (latitude: 36.8, longitude: 10.18);
  }

  @override
  Future<bool> openAppSettings() async => true;
}

void main() {
  test('permission already given: returns the position, no question asked',
      () async {
    final gateway = _FakeGateway();
    final result = await LocationService(gateway).locate();
    expect(result.status, LocationStatus.granted);
    expect(result.position?.latitude, 36.8);
    expect(result.position?.longitude, 10.18);
    expect(gateway.requested, isFalse);
  });

  test('permission denied then accepted: asks once, then returns the position',
      () async {
    final gateway = _FakeGateway(permission: LocationPermission.denied);
    final result = await LocationService(gateway).locate();
    expect(gateway.requested, isTrue);
    expect(result.status, LocationStatus.granted);
  });

  test('refused when asked: denied, and the position is never read', () async {
    final gateway = _FakeGateway(
      permission: LocationPermission.denied,
      afterRequest: LocationPermission.denied,
    );
    final result = await LocationService(gateway).locate();
    expect(result.status, LocationStatus.denied);
    expect(result.position, isNull);
    expect(gateway.positionRead, isFalse);
  });

  test('denied forever: no new question, status says so', () async {
    final gateway = _FakeGateway(permission: LocationPermission.deniedForever);
    final result = await LocationService(gateway).locate();
    expect(result.status, LocationStatus.deniedForever);
    expect(gateway.requested, isFalse);
    expect(gateway.positionRead, isFalse);
  });

  test('GPS switched off', () async {
    final result =
        await LocationService(_FakeGateway(serviceOn: false)).locate();
    expect(result.status, LocationStatus.serviceOff);
  });

  test('a failure while reading the position is an error, not a crash',
      () async {
    final result =
        await LocationService(_FakeGateway(throwOnPosition: true)).locate();
    expect(result.status, LocationStatus.error);
  });
}
