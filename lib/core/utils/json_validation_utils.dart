import 'package:starnyx/core/utils/reminder_time_utils.dart';

class JsonValidationResult {
  const JsonValidationResult._(this.errors);

  final List<String> errors;

  bool get isValid => errors.isEmpty;

  factory JsonValidationResult.valid() {
    return const JsonValidationResult._(<String>[]);
  }

  factory JsonValidationResult.invalid(List<String> errors) {
    return JsonValidationResult._(List.unmodifiable(errors));
  }
}

abstract final class JsonValidationUtils {
  static JsonValidationResult validateImportJson(Map<String, dynamic> json) {
    final errors = <String>[];

    _validateSchemaVersion(json, errors);
    final starnyxs = _readList(json, 'starnyxs', errors);
    final completions = _readList(json, 'completions', errors);
    final journalEntries = _readList(json, 'journalEntries', errors);
    final appSettings = _readMap(json, 'appSettings', errors);

    final knownStarNyxIds = <String>{};

    for (var index = 0; index < starnyxs.length; index++) {
      final entry = _asMap(starnyxs[index], 'starnyxs[$index]', errors);
      final id = _validateStarNyxEntry(entry, index, errors);
      if (id == null) {
        continue;
      }

      if (!knownStarNyxIds.add(id)) {
        errors.add('starnyxs[$index].id must be unique.');
      }
    }

    for (var index = 0; index < completions.length; index++) {
      final entry = _asMap(completions[index], 'completions[$index]', errors);
      _validateCompletionEntry(entry, index, knownStarNyxIds, errors);
    }

    for (var index = 0; index < journalEntries.length; index++) {
      final entry = _asMap(
        journalEntries[index],
        'journalEntries[$index]',
        errors,
      );
      _validateJournalEntry(entry, index, knownStarNyxIds, errors);
    }

    _validateAppSettings(appSettings, knownStarNyxIds, errors);

    if (errors.isEmpty) {
      return JsonValidationResult.valid();
    }

    return JsonValidationResult.invalid(errors);
  }

  static void _validateSchemaVersion(
    Map<String, dynamic> json,
    List<String> errors,
  ) {
    final schemaVersion = json['schemaVersion'];
    if (schemaVersion is! int) {
      errors.add('schemaVersion must be an integer.');
      return;
    }

    if (schemaVersion != 1) {
      errors.add('schemaVersion must be 1.');
    }
  }

  static List<dynamic> _readList(
    Map<String, dynamic> json,
    String key,
    List<String> errors,
  ) {
    final value = json[key];
    if (value is List<dynamic>) {
      return value;
    }

    errors.add('$key must be a list.');
    return const <dynamic>[];
  }

  static Map<String, dynamic> _readMap(
    Map<String, dynamic> json,
    String key,
    List<String> errors,
  ) {
    final value = json[key];
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return value.map(
        (mapKey, mapValue) => MapEntry(mapKey.toString(), mapValue),
      );
    }

    errors.add('$key must be an object.');
    return const <String, dynamic>{};
  }

  static Map<String, dynamic> _asMap(
    dynamic value,
    String path,
    List<String> errors,
  ) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return value.map(
        (mapKey, mapValue) => MapEntry(mapKey.toString(), mapValue),
      );
    }

    errors.add('$path must be an object.');
    return const <String, dynamic>{};
  }

  static String? _validateStarNyxEntry(
    Map<String, dynamic> entry,
    int index,
    List<String> errors,
  ) {
    final id = _requireString(entry, 'id', 'starnyxs[$index]', errors);
    _requireString(entry, 'title', 'starnyxs[$index]', errors);
    _requireString(entry, 'color', 'starnyxs[$index]', errors);
    _requireDateString(entry, 'startDate', 'starnyxs[$index]', errors);
    _requireBool(entry, 'reminderEnabled', 'starnyxs[$index]', errors);
    _requireIsoDateTime(entry, 'createdAt', 'starnyxs[$index]', errors);
    _requireIsoDateTime(entry, 'updatedAt', 'starnyxs[$index]', errors);
    _optionalNullableString(entry, 'description', 'starnyxs[$index]', errors);
    _optionalNullableReminderTime(
      entry,
      'reminderTime',
      'starnyxs[$index]',
      errors,
    );
    return id;
  }

  static void _validateCompletionEntry(
    Map<String, dynamic> entry,
    int index,
    Set<String> knownStarNyxIds,
    List<String> errors,
  ) {
    final starnyxId = _requireString(
      entry,
      'starnyxId',
      'completions[$index]',
      errors,
    );
    _requireDateString(entry, 'date', 'completions[$index]', errors);
    _requireBool(entry, 'completed', 'completions[$index]', errors);

    if (starnyxId != null && !knownStarNyxIds.contains(starnyxId)) {
      errors.add(
        'completions[$index].starnyxId must reference a known StarNyx.',
      );
    }
  }

  static void _validateJournalEntry(
    Map<String, dynamic> entry,
    int index,
    Set<String> knownStarNyxIds,
    List<String> errors,
  ) {
    final starnyxId = _requireString(
      entry,
      'starnyxId',
      'journalEntries[$index]',
      errors,
    );
    _requireDateString(entry, 'date', 'journalEntries[$index]', errors);
    _requireString(entry, 'content', 'journalEntries[$index]', errors);

    if (starnyxId != null && !knownStarNyxIds.contains(starnyxId)) {
      errors.add(
        'journalEntries[$index].starnyxId must reference a known StarNyx.',
      );
    }
  }

  static void _validateAppSettings(
    Map<String, dynamic> appSettings,
    Set<String> knownStarNyxIds,
    List<String> errors,
  ) {
    final selectedId = appSettings['lastSelectedStarnyxId'];
    if (selectedId != null && selectedId is! String) {
      errors.add('appSettings.lastSelectedStarnyxId must be a string or null.');
    }

    if (selectedId is String && !knownStarNyxIds.contains(selectedId)) {
      errors.add(
        'appSettings.lastSelectedStarnyxId must reference a known StarNyx.',
      );
    }

    _requireIsoDateTime(appSettings, 'updatedAt', 'appSettings', errors);
  }

  static String? _requireString(
    Map<String, dynamic> entry,
    String key,
    String path,
    List<String> errors,
  ) {
    final value = entry[key];
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }

    errors.add('$path.$key must be a non-empty string.');
    return null;
  }

  static void _optionalNullableString(
    Map<String, dynamic> entry,
    String key,
    String path,
    List<String> errors,
  ) {
    final value = entry[key];
    if (value == null || value is String) {
      return;
    }

    errors.add('$path.$key must be a string or null.');
  }

  static void _optionalNullableReminderTime(
    Map<String, dynamic> entry,
    String key,
    String path,
    List<String> errors,
  ) {
    final value = entry[key];
    if (value == null) {
      return;
    }

    if (value is! String || !ReminderTimeUtils.isValidTimeString(value)) {
      errors.add('$path.$key must be a valid HH:mm string or null.');
    }
  }

  static void _requireBool(
    Map<String, dynamic> entry,
    String key,
    String path,
    List<String> errors,
  ) {
    if (entry[key] is bool) {
      return;
    }

    errors.add('$path.$key must be a boolean.');
  }

  static void _requireDateString(
    Map<String, dynamic> entry,
    String key,
    String path,
    List<String> errors,
  ) {
    final value = entry[key];
    if (value is! String || !_isValidDateOnlyString(value)) {
      errors.add('$path.$key must be a valid YYYY-MM-DD string.');
    }
  }

  static void _requireIsoDateTime(
    Map<String, dynamic> entry,
    String key,
    String path,
    List<String> errors,
  ) {
    final value = entry[key];
    if (value is! String || DateTime.tryParse(value) == null) {
      errors.add('$path.$key must be a valid ISO-8601 string.');
    }
  }

  static bool _isValidDateOnlyString(String value) {
    final pattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!pattern.hasMatch(value)) {
      return false;
    }

    return DateTime.tryParse(value) != null;
  }
}
