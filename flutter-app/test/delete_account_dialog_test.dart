import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/features/auth/delete_account_dialog.dart';
import 'package:flutterapp/l10n/generated/app_localizations.dart';
import 'package:flutterapp/l10n/generated/app_localizations_en.dart';

void main() {
  testWidgets('empty password shows an error and a retry button',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: DeleteAccountDialog()),
        ),
      ),
    );

    final l10n = AppLocalizationsEn();
    await tester.tap(find.text(l10n.deleteAccountConfirm));
    await tester.pump();

    expect(find.text(l10n.authErrorWrongPassword), findsOneWidget);
    expect(find.text(l10n.favoritesRetry), findsOneWidget);
  });
}
