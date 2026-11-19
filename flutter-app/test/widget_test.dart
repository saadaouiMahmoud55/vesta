import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/app.dart';
import 'package:flutterapp/features/auth/auth_controller.dart';
import 'package:flutterapp/features/auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _openAppAsGuest(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authStateProvider.overrideWith((ref) => Stream<User?>.value(null)),
      ],
      child: const VestaApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('guest browses the app without signing in', (tester) async {
    await _openAppAsGuest(tester);

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });

  testWidgets('guest tapping chat gets the sign-in sheet', (tester) async {
    await _openAppAsGuest(tester);

    await tester.tap(find.byIcon(Icons.chat_bubble_outline));
    await tester.pumpAndSettle();

    expect(find.text('Sign in to continue'), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });

  testWidgets('guest chooses Log in and sees the Login screen',
      (tester) async {
    await _openAppAsGuest(tester);

    await tester.tap(find.byIcon(Icons.chat_bubble_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('settings opens from Profile and switches the language',
      (tester) async {
    await _openAppAsGuest(tester);

    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('English'), findsOneWidget);
    expect(find.text('Français'), findsOneWidget);
    // A guest has no sign out and no delete account entry.
    expect(find.text('Log out'), findsNothing);

    await tester.tap(find.text('Français'));
    await tester.pumpAndSettle();

    expect(find.text('Paramètres'), findsWidgets);
  });

  testWidgets('forgot password opens from the Login screen', (tester) async {
    await _openAppAsGuest(tester);

    await tester.tap(find.byIcon(Icons.chat_bubble_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();

    expect(find.text('Reset your password'), findsOneWidget);
  });
}
