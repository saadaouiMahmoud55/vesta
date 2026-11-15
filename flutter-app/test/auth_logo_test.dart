import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/features/auth/login_screen.dart';
import 'package:flutterapp/features/auth/sign_up_screen.dart';
import 'package:flutterapp/l10n/generated/app_localizations.dart';

Future<void> _pump(WidgetTester tester, Widget screen) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(body: screen),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('login shows the logo above the welcome title', (tester) async {
    await _pump(tester, const LoginScreen());
    final logo = find.byKey(const Key('auth-logo'));
    expect(logo, findsOneWidget);
    final title = find.text('Welcome to Vesta');
    expect(title, findsOneWidget);
    expect(
      tester.getBottomLeft(logo).dy,
      lessThanOrEqualTo(tester.getTopLeft(title).dy),
    );
  });

  testWidgets('sign up shows the logo', (tester) async {
    await _pump(tester, const SignUpScreen());
    expect(find.byKey(const Key('auth-logo')), findsOneWidget);
  });
}
