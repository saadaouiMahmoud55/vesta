import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/widgets/splash_gate.dart';
import 'features/onboarding/onboarding_controller.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      child: const SplashGate(child: VestaApp()),
    ),
  );
}
