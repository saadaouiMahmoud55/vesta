import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/app.dart';
import 'package:flutterapp/features/auth/auth_controller.dart';
import 'package:flutterapp/features/onboarding/onboarding_controller.dart';
import 'package:flutterapp/features/onboarding/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app as a guest. [seen] is the saved "onboarding already shown".
Future<void> _openApp(WidgetTester tester, {required bool seen}) async {
  SharedPreferences.setMockInitialValues({});
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authStateProvider.overrideWith((ref) => Stream<User?>.value(null)),
        onboardingSeenProvider.overrideWith(() => OnboardingController(seen)),
      ],
      child: const VestaApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  test('onboarding is not seen on a new phone, and seen once saved', () async {
    SharedPreferences.setMockInitialValues({});
    expect(await loadOnboardingSeen(), isFalse);

    SharedPreferences.setMockInitialValues({'onboarding_seen': true});
    expect(await loadOnboardingSeen(), isTrue);
  });

  testWidgets('first launch shows the onboarding, not the home screen',
      (tester) async {
    await _openApp(tester, seen: false);

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('Find your place in Tunisia'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('already seen: the app opens on the home screen',
      (tester) async {
    await _openApp(tester, seen: true);

    expect(find.byType(OnboardingScreen), findsNothing);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('Skip opens the home screen and saves that it was seen',
      (tester) async {
    await _openApp(tester, seen: false);

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingScreen), findsNothing);
    expect(find.byType(NavigationBar), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('onboarding_seen'), isTrue);
  });

  testWidgets('Next goes through the 3 screens, then Get started opens home',
      (tester) async {
    await _openApp(tester, seen: false);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Contact the owner'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Publish your own place'), findsOneWidget);
    expect(find.text('Next'), findsNothing);

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingScreen), findsNothing);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
