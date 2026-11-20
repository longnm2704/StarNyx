import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starnyx/core/services/paused_reminders_store.dart';
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:starnyx/domain/repositories/starnyx_repository.dart';
import 'package:starnyx/domain/usecases/set_all_reminders_enabled_use_case.dart';
import 'package:starnyx/domain/usecases/sync_notifications_use_case.dart';

class _MockRepo extends Mock implements StarNyxRepository {}

class _MockSync extends Mock implements SyncNotificationsUseCase {}

StarNyx _habit(String id, {required bool enabled, String? time}) => StarNyx(
  id: id,
  title: id,
  description: null,
  color: '#10B981',
  startDate: DateTime(2026),
  reminderEnabled: enabled,
  reminderTime: time,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

void main() {
  setUpAll(() => registerFallbackValue(_habit('x', enabled: false)));

  test('off keeps reminder times so on can restore them', () async {
    final repo = _MockRepo();
    final sync = _MockSync();
    final saved = <StarNyx>[];
    when(repo.getAllStarnyxs).thenAnswer(
      (_) async => <StarNyx>[
        _habit('a', enabled: true, time: '21:00'),
        _habit('b', enabled: false), // no time: untouched
      ],
    );
    when(() => repo.saveStarnyx(any())).thenAnswer((inv) async {
      saved.add(inv.positionalArguments.first as StarNyx);
    });
    when(() => sync.onStarnyxSaved(any())).thenAnswer((_) async {});

    await SetAllRemindersEnabledUseCase(repo, sync)(false);

    expect(saved, hasLength(1));
    expect(saved.single.id, 'a');
    expect(saved.single.reminderEnabled, isFalse);
    expect(saved.single.reminderTime, '21:00');
    verify(() => sync.onStarnyxSaved(saved.single)).called(1);
  });

  test('on restores only the habits that were on before off', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final store = PausedRemindersStore(await SharedPreferences.getInstance());
    final repo = _MockRepo();
    final sync = _MockSync();
    final db = <String, StarNyx>{
      'a': _habit('a', enabled: true, time: '21:00'),
      'b': _habit('b', enabled: false, time: '07:00'), // user turned it off
    };
    when(repo.getAllStarnyxs).thenAnswer((_) async => db.values.toList());
    when(() => repo.saveStarnyx(any())).thenAnswer((inv) async {
      final s = inv.positionalArguments.first as StarNyx;
      db[s.id] = s;
    });
    when(() => sync.onStarnyxSaved(any())).thenAnswer((_) async {});
    final useCase = SetAllRemindersEnabledUseCase(
      repo,
      sync,
      pausedStore: store,
    );

    await useCase(false);
    expect(db.values.every((s) => !s.reminderEnabled), isTrue);

    await useCase(true);
    expect(db['a']!.reminderEnabled, isTrue);
    expect(db['b']!.reminderEnabled, isFalse);
    expect(store.read(), isEmpty);
  });
}
