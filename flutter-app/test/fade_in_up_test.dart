import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vesta/core/widgets/fade_in_up.dart';

void main() {
  testWidgets('FadeInUp shows its child and ends fully visible', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: FadeInUp(
          delay: Duration(milliseconds: 120),
          child: Text('hello'),
        ),
      ),
    );

    // Present from the first frame (the tests that look for it still work).
    expect(find.text('hello'), findsOneWidget);

    await tester.pumpAndSettle();

    final opacity = tester.widget<Opacity>(find.byType(Opacity));
    expect(opacity.opacity, 1.0);
    expect(find.text('hello'), findsOneWidget);
  });
}
