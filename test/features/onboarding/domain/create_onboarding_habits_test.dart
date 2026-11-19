import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starnyx/core/services/core_services.dart';
import 'package:starnyx/data/db/app_database.dart';
import 'package:starnyx/data/repositories/data_repositories.dart';
import 'package:starnyx/domain/usecases/domain_usecases.dart';
import 'package:starnyx/features/onboarding/domain/create_onboarding_habits.dart';
import 'package:uuid/uuid.dart';

void main() {
  late AppDatabase database;
  late DriftStarNyxRepository repository;
  late _FakeNotificationService notifications;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftStarNyxRepository(database);
    notifications = _FakeNotificationService();
  });
  tearDown(() => database.close());

  const drafts = <OnboardingHabitDraft>[
    (
      title: 'Water',
      description: 'Morning',
      icon: 'droplet',
      color: '#10B981',
      reminderTime: '06:45',
    ),
    (
      title: 'Sleep',
      description: 'Night',
      icon: 'moon',
      color: '#FFB95F',
      reminderTime: '22:15',
    ),
  ];

  Future<List<Object>> run() => createOnboardingHabits(
    drafts,
    create: CreateStarNyxUseCase(repository, const Uuid()),
    delete: DeleteStarNyxUseCase(
      repository,
      DriftAppSettingsRepository(database),
    ),
    sync: SyncNotificationsUseCase(notifications, repository),
  );

  test('creates every draft with a daily reminder and schedules it', () async {
    await run();

    final saved = await repository.getAllStarnyxs();
    expect(saved.map((s) => s.title), <String>['Water', 'Sleep']);
    expect(saved.map((s) => s.reminderTime), <String>['06:45', '22:15']);
    expect(saved.every((s) => s.reminderEnabled), isTrue);
    expect(saved.map((s) => s.icon), <String>['droplet', 'moon']);
    expect(notifications.scheduled, hasLength(2));
  });

  test('rolls back created habits when a later step fails', () async {
    notifications.failOnCall = 2;

    await expectLater(run(), throwsA(isA<StateError>()));

    expect(await repository.getAllStarnyxs(), isEmpty);
    expect(notifications.cancelled, hasLength(2));
  });
}

class _FakeNotificationService implements NotificationService {
  final scheduled = <String>[];
  final cancelled = <String>[];
  int? failOnCall;

  @override
  Future<void> updateReminder(starnyx) async {
    if (scheduled.length + 1 == failOnCall) throw StateError('boom');
    scheduled.add(starnyx.id);
  }

  @override
  Future<void> cancelReminder(String starnyxId) async =>
      cancelled.add(starnyxId);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
