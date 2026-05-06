import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActiveStarnyxColorCache {
  const ActiveStarnyxColorCache(this._preferences);

  static const _colorKey = 'active_starnyx_color_value';

  final SharedPreferences _preferences;

  Color? readColor() {
    final value = _preferences.getInt(_colorKey);
    return value == null ? null : Color(value);
  }

  Future<void> saveColor(Color color) {
    return _preferences.setInt(_colorKey, color.toARGB32());
  }
}
