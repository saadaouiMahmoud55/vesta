import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _seenKey = 'onboarding_seen';

/// Reads, before the app starts, whether the onboarding was already shown.
/// If the phone storage is not available it returns true, so the user is
/// never stuck on the onboarding.
Future<bool> loadOnboardingSeen() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_seenKey) ?? false;
  } catch (_) {
    return true;
  }
}

/// Whether the onboarding was already shown on this phone (VST-99).
///
/// `main()` overrides the start value with [loadOnboardingSeen]. The default
/// is true (nothing to show), so a test that does not care about the
/// onboarding opens the app on the home screen.
class OnboardingController extends Notifier<bool> {
  OnboardingController([this._seen = true]);

  final bool _seen;

  @override
  bool build() => _seen;

  /// Called by "Skip" and "Get started". The onboarding is not shown again.
  Future<void> markSeen() async {
    state = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_seenKey, true);
    } catch (_) {
      // Not saved: the onboarding may show again at the next launch.
    }
  }
}

final onboardingSeenProvider =
    NotifierProvider<OnboardingController, bool>(OnboardingController.new);
