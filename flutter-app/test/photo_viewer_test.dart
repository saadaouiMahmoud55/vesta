import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/core/widgets/photo_viewer.dart';

// A 1x1 transparent PNG.
final String _png = base64Encode(const [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

Widget _app(String? photo) => MaterialApp(
  home: Builder(
    builder: (context) => Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => showPhotoViewer(context, photo),
          child: const Text('open'),
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('opens the photo in a dialog and closes on tap', (tester) async {
    await tester.pumpWidget(_app(_png));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('photo-viewer-image')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('photo-viewer-image')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('photo-viewer-image')), findsNothing);
  });

  testWidgets('does nothing without a photo or with bad data', (tester) async {
    await tester.pumpWidget(_app(null));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);

    await tester.pumpWidget(_app('not base64 !!'));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
  });
}
