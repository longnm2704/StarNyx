import 'package:shared_preferences/shared_preferences.dart';

/// Habits whose reminders were on when the Settings master switch turned
/// them all off, so switching it back on restores only those.
class PausedRemindersStore {
  const PausedRemindersStore(this._preferences);

  static const _key = 'reminders_paused_ids';

  final SharedPreferences _preferences;

  Set<String> read() =>
      (_preferences.getStringList(_key) ?? <String>[]).toSet();

  Future<void> write(Iterable<String> ids) => ids.isEmpty
      ? _preferences.remove(_key)
      : _preferences.setStringList(_key, ids.toList());
}
