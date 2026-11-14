import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/core/widgets/password_text_field.dart';
import 'package:flutterapp/l10n/generated/app_localizations.dart';

Future<void> _pump(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
  TextEditingController? controller,
}) {
  return tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: PasswordTextField(label: 'Password', controller: controller),
      ),
    ),
  );
}

bool _obscured(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField)).obscureText;

void main() {
  testWidgets('the password is hidden at first', (tester) async {
    await _pump(tester);
    expect(_obscured(tester), isTrue);
    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    expect(find.byTooltip('Show password'), findsOneWidget);
  });

  testWidgets('the eye shows then hides the password', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await _pump(tester, controller: controller);
    await tester.enterText(find.byType(TextField), 'secret123');

    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pump();
    expect(_obscured(tester), isFalse);
    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    expect(find.byTooltip('Hide password'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pump();
    expect(_obscured(tester), isTrue);
    expect(find.byTooltip('Show password'), findsOneWidget);
    // What the user typed is kept when the eye is toggled.
    expect(controller.text, 'secret123');
  });

  testWidgets('the tooltip is translated', (tester) async {
    await _pump(tester, locale: const Locale('fr'));
    expect(find.byTooltip('Afficher le mot de passe'), findsOneWidget);
  });
}
