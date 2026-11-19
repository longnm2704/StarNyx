import 'package:shared_preferences/shared_preferences.dart';

/// Whether the user has left first-run onboarding (STX-U024).
///
/// Lives in SharedPreferences rather than Drift so no schema migration is
/// needed; delete-all resets it.
class OnboardingPreferences {
  const OnboardingPreferences(this._preferences);

  static const _completedKey = 'onboarding_completed';

  final SharedPreferences _preferences;

  bool get completed => _preferences.getBool(_completedKey) ?? false;

  Future<void> setCompleted(bool value) =>
      _preferences.setBool(_completedKey, value);
}
