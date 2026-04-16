import 'package:flutter_test/flutter_test.dart';
import 'package:starnyx/core/utils/json_validation_utils.dart';

// Covers import payload validation before database writes happen.
void main() {
  group('JsonValidationUtils', () {
    test('accepts a valid import payload', () {
      final result = JsonValidationUtils.validateImportJson(<String, dynamic>{
        'schemaVersion': 1,
        'starnyxs': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'stx-1',
            'title': 'Read',
            'description': null,
            'color': '#123456',
            'startDate': '2026-04-01',
            'reminderEnabled': true,
            'reminderTime': '10:30',
            'createdAt': '2026-04-01T00:00:00.000Z',
            'updatedAt': '2026-04-01T00:00:00.000Z',
          },
        ],
        'completions': <Map<String, dynamic>>[
          <String, dynamic>{
            'starnyxId': 'stx-1',
            'date': '2026-04-10',
            'completed': true,
          },
        ],
        'journalEntries': <Map<String, dynamic>>[
          <String, dynamic>{
            'starnyxId': 'stx-1',
            'date': '2026-04-10',
            'content': 'Nice day',
          },
        ],
        'appSettings': <String, dynamic>{
          'lastSelectedStarnyxId': 'stx-1',
          'updatedAt': '2026-04-10T00:00:00.000Z',
        },
      });

      expect(result.isValid, isTrue);
      expect(result.errors, isEmpty);
    });

    test('rejects invalid payload structure', () {
      final result = JsonValidationUtils.validateImportJson(<String, dynamic>{
        'schemaVersion': 2,
        'starnyxs': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'stx-1',
            'title': '',
            'color': '#123456',
            'startDate': 'bad-date',
            'reminderEnabled': 'yes',
            'createdAt': 'bad-iso',
            'updatedAt': 'bad-iso',
          },
        ],
        'completions': <Map<String, dynamic>>[
          <String, dynamic>{
            'starnyxId': 'missing-id',
            'date': '2026-04-10',
            'completed': true,
          },
        ],
        'journalEntries': <Map<String, dynamic>>[
          <String, dynamic>{
            'starnyxId': 'missing-id',
            'date': '2026-04-10',
            'content': 'entry',
          },
        ],
        'appSettings': <String, dynamic>{
          'lastSelectedStarnyxId': 'missing-id',
          'updatedAt': 'bad-iso',
        },
      });

      expect(result.isValid, isFalse);
      expect(result.errors, isNotEmpty);
    });

    test('requires reminderTime when reminderEnabled is true', () {
      final result = JsonValidationUtils.validateImportJson(<String, dynamic>{
        'schemaVersion': 1,
        'starnyxs': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'stx-1',
            'title': 'Read',
            'description': null,
            'color': '#123456',
            'startDate': '2026-04-01',
            'reminderEnabled': true,
            'reminderTime': null,
            'createdAt': '2026-04-01T00:00:00.000Z',
            'updatedAt': '2026-04-01T00:00:00.000Z',
          },
        ],
        'completions': <Map<String, dynamic>>[],
        'journalEntries': <Map<String, dynamic>>[],
        'appSettings': <String, dynamic>{
          'lastSelectedStarnyxId': null,
          'updatedAt': '2026-04-10T00:00:00.000Z',
        },
      });

      expect(result.isValid, isFalse);
      expect(
        result.errors,
        contains(
          'starnyxs[0].reminderTime is required when reminderEnabled is true.',
        ),
      );
    });

    test('rejects reminderTime when reminderEnabled is false', () {
      final result = JsonValidationUtils.validateImportJson(<String, dynamic>{
        'schemaVersion': 1,
        'starnyxs': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'stx-1',
            'title': 'Read',
            'description': null,
            'color': '#123456',
            'startDate': '2026-04-01',
            'reminderEnabled': false,
            'reminderTime': '10:30',
            'createdAt': '2026-04-01T00:00:00.000Z',
            'updatedAt': '2026-04-01T00:00:00.000Z',
          },
        ],
        'completions': <Map<String, dynamic>>[],
        'journalEntries': <Map<String, dynamic>>[],
        'appSettings': <String, dynamic>{
          'lastSelectedStarnyxId': null,
          'updatedAt': '2026-04-10T00:00:00.000Z',
        },
      });

      expect(result.isValid, isFalse);
      expect(
        result.errors,
        contains(
          'starnyxs[0].reminderTime must be null when reminderEnabled is false.',
        ),
      );
    });
  });
}
