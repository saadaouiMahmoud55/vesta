import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/widgets/splash_gate.dart';
import 'features/onboarding/onboarding_controller.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Draw the logo and the name right away, before Firebase and the saved
  // settings are ready (that wait used to leave a blank screen).
  runApp(const SplashView());
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final onboardingSeen = await loadOnboardingSeen();
  runApp(
    ProviderScope(
      overrides: [
        onboardingSeenProvider.overrideWith(
          () => OnboardingController(onboardingSeen),
        ),
      ],
      // Same splash again for a short moment, then a fade to the app.
      child: const SplashGate(child: VestaApp()),
    ),
  );
}
