import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/features/auth/auth_proverb.dart';
import 'package:flutterapp/features/listings/explore_welcome.dart';
import 'package:flutterapp/l10n/generated/app_localizations.dart';

Widget _app(Widget child, {Locale locale = const Locale('en')}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: Scaffold(body: child),
  );
}

void main() {
  test('isFirstSignIn: same time means a new account', () {
    final t = DateTime(2026, 11, 15, 12);
    expect(isFirstSignIn(t, t), isTrue);
    expect(isFirstSignIn(t, t.add(const Duration(seconds: 3))), isTrue);
    expect(isFirstSignIn(t, t.add(const Duration(days: 2))), isFalse);
    expect(isFirstSignIn(null, t), isFalse);
    expect(isFirstSignIn(t, null), isFalse);
  });

  testWidgets('shows "Welcome back" with the name', (tester) async {
    await tester.pumpWidget(
      _app(const ExploreWelcome(name: 'Manar', isNew: false)),
    );
    expect(find.text('Welcome back, Manar'), findsOneWidget);
  });

  testWidgets('shows a welcome for a new account', (tester) async {
    await tester.pumpWidget(
      _app(const ExploreWelcome(name: 'Manar', isNew: true)),
    );
    expect(find.text('Welcome to Vesta, Manar'), findsOneWidget);
  });

  testWidgets('without a name it shows the plain welcome title', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(const ExploreWelcome(name: '  ', isNew: false)),
    );
    expect(find.text('Welcome to Vesta'), findsOneWidget);
  });

  testWidgets('the proverb is shown in Arabic', (tester) async {
    await tester.pumpWidget(_app(const AuthProverb(), locale: const Locale('ar')));
    expect(find.text('«الجار قبل الدار»'), findsOneWidget);
  });
}
