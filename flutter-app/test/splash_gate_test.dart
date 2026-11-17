import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/core/widgets/splash_gate.dart';

void main() {
  testWidgets('shows the logo first, then reveals the app', (tester) async {
    await tester.pumpWidget(
      const SplashGate(
        duration: Duration(milliseconds: 500),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Text('the app', key: Key('app')),
        ),
      ),
    );

    // At the start the splash covers the app and takes the touches.
    expect(find.byType(Image), findsOneWidget);
    var gate = tester.widget<IgnorePointer>(
      find.descendant(
        of: find.byType(SplashGate),
        matching: find.byType(IgnorePointer),
      ).first,
    );
    expect(gate.ignoring, isFalse);

    // After the wait and the fade, the splash is transparent and ignored.
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    gate = tester.widget<IgnorePointer>(
      find.descendant(
        of: find.byType(SplashGate),
        matching: find.byType(IgnorePointer),
      ).first,
    );
    expect(gate.ignoring, isTrue);
    final opacity = tester.widget<AnimatedOpacity>(find.byKey(const Key('splash')));
    expect(opacity.opacity, 0);
    expect(find.byKey(const Key('app')), findsOneWidget);
  });
}
