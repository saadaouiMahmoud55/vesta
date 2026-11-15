import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/features/listings/listing_location_card.dart';

void main() {
  test('the button opens OpenStreetMap on the exact position', () {
    final uri = ListingLocationCard.mapsUri(33.9197, 8.1335);

    expect(uri.host, 'www.openstreetmap.org');
    expect(uri.queryParameters['mlat'], '33.9197');
    expect(uri.queryParameters['mlon'], '8.1335');
    expect(uri.fragment, 'map=17/33.9197/8.1335');
  });
}
