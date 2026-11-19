import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/locale_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'l10n/generated/app_localizations.dart';

class VestaApp extends ConsumerWidget {
  const VestaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      theme: AppTheme.light,
      routerConfig: router,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      // When the phone language is not supported, Flutter uses the FIRST locale
      // of this generated list. It is sorted alphabetically (ar, en, fr), so the
      // fallback is Arabic. If a language is added, check that ar is still first.
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}