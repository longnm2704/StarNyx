import 'package:shared_preferences/shared_preferences.dart';

abstract interface class StarNyxOrderStore {
  Future<List<String>> loadOrder();
  Future<void> saveOrder(List<String> orderedIds);
}

class SharedPreferencesStarNyxOrderStore implements StarNyxOrderStore {
  const SharedPreferencesStarNyxOrderStore(this._preferences);

  static const String key = 'starnyx_order_ids';

  final SharedPreferences _preferences;

  @override
  Future<List<String>> loadOrder() async {
    return _preferences.getStringList(key) ?? const <String>[];
  }

  @override
  Future<void> saveOrder(List<String> orderedIds) async {
    final uniqueIds = <String>[];
    final seen = <String>{};
    for (final id in orderedIds) {
      if (seen.add(id)) {
        uniqueIds.add(id);
      }
    }
    await _preferences.setStringList(key, uniqueIds);
  }
}
