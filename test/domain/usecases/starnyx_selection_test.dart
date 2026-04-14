import 'package:flutter_test/flutter_test.dart';
import 'package:starnyx/domain/entities/domain_entities.dart';
import 'package:starnyx/domain/usecases/domain_usecases.dart';
import 'package:starnyx/domain/repositories/domain_repositories.dart';

void main() {
  late _InMemoryStarNyxRepository starNyxRepository;
  late _InMemoryAppSettingsRepository appSettingsRepository;
  late SelectActiveStarNyxUseCase selectUseCase;
  late LoadActiveStarNyxUseCase loadUseCase;

  setUp(() {
    starNyxRepository = _InMemoryStarNyxRepository();
    appSettingsRepository = _InMemoryAppSettingsRepository();
    selectUseCase = SelectActiveStarNyxUseCase(
      starNyxRepository,
      appSettingsRepository,
    );
    loadUseCase = LoadActiveStarNyxUseCase(
      starNyxRepository,
      appSettingsRepository,
    );
  });

  final starnyx1 = StarNyx(
    id: 'habit-1',
    title: 'Hydrate',
    description: null,
    color: '#102030',
    startDate: DateTime(2026, 4, 1),
    reminderEnabled: false,
    reminderTime: null,
    createdAt: DateTime(2026, 4, 1, 8),
    updatedAt: DateTime(2026, 4, 1, 8),
  );

  final starnyx2 = starnyx1.copyWith(id: 'habit-2', title: 'Read');

  test('select active use case persists selection and updatedAt', () async {
    await starNyxRepository.saveStarnyx(starnyx1);
    final now = DateTime(2026, 4, 14, 10);

    await selectUseCase('habit-1', now: now);

    final settings = await appSettingsRepository.getAppSettings();
    expect(settings?.lastSelectedStarnyxId, 'habit-1');
    expect(settings?.updatedAt, now);
  });

  test('select active use case throws when starnyx does not exist', () async {
    expect(
      () => selectUseCase('missing-id'),
      throwsA(isA<StateError>()),
    );
  });

  test('load active use case restores previously selected starnyx', () async {
    await starNyxRepository.saveStarnyx(starnyx1);
    await starNyxRepository.saveStarnyx(starnyx2);
    await appSettingsRepository.saveAppSettings(
      AppSettings(
        lastSelectedStarnyxId: 'habit-2',
        updatedAt: DateTime(2026, 4, 10),
      ),
    );

    final active = await loadUseCase();

    expect(active?.id, 'habit-2');
  });

  test('load active use case returns null when no starnyxs exist', () async {
    final active = await loadUseCase();
    expect(active, isNull);
  });
}

class _InMemoryStarNyxRepository implements StarNyxRepository {
  final Map<String, StarNyx> _items = <String, StarNyx>{};

  @override
  Future<void> deleteStarnyxById(String id) async => _items.remove(id);

  @override
  Future<List<StarNyx>> getAllStarnyxs() async => _items.values.toList();

  @override
  Future<StarNyx?> getStarnyxById(String id) async => _items[id];

  @override
  Future<void> saveStarnyx(StarNyx starnyx) async => _items[starnyx.id] = starnyx;

  @override
  Stream<List<StarNyx>> watchAllStarnyxs() => throw UnimplementedError();
}

class _InMemoryAppSettingsRepository implements AppSettingsRepository {
  AppSettings? _settings;

  @override
  Future<AppSettings?> getAppSettings() async => _settings;

  @override
  Future<void> saveAppSettings(AppSettings settings) async => _settings = settings;

  @override
  Stream<AppSettings?> watchAppSettings() => throw UnimplementedError();
}
