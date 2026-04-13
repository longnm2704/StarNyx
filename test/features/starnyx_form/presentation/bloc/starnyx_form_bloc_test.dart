import 'package:uuid/uuid.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starnyx/domain/entities/domain_entities.dart';
import 'package:starnyx/domain/usecases/domain_usecases.dart';
import 'package:starnyx/domain/repositories/domain_repositories.dart';
import 'package:starnyx/features/starnyx_form/presentation/bloc/starnyx_form_bloc.dart';
import 'package:starnyx/features/starnyx_form/presentation/bloc/starnyx_form_event.dart';
import 'package:starnyx/features/starnyx_form/presentation/bloc/starnyx_form_state.dart';

/// Tests for StarnyxFormBloc covering:
/// - Create and edit mode initialization
/// - Field-level validation (title, date, reminder time)
/// - Form submission with create/update use cases
/// - Use case error handling and mapping
/// - Edge cases (empty description, whitespace trimming, etc.)
void main() {
  late _InMemoryStarNyxRepository repository;
  late CreateStarNyxUseCase createUseCase;
  late UpdateStarNyxUseCase updateUseCase;

  /// Sets up mock repository and use cases before each test.
  /// This ensures each test starts with a clean state.
  setUp(() {
    repository = _InMemoryStarNyxRepository();
    createUseCase = CreateStarNyxUseCase(repository, const Uuid());
    updateUseCase = UpdateStarNyxUseCase(repository);
  });

  test(
    'create mode starts with today and preserves the current reminder time',
    () {
      /// Verifies that create mode:
      /// - Starts with today's date
      /// - Disables reminder by default
      /// - Suggests the current reminder time without rounding
      /// - Shows title validation error (required field)
      final bloc = StarnyxFormBloc(
        createStarNyxUseCase: createUseCase,
        updateStarNyxUseCase: updateUseCase,
        nowBuilder: () => DateTime(2026, 4, 13, 10, 20),
      );

      expect(bloc.state.mode, StarnyxFormMode.create);
      expect(bloc.state.startDate, DateTime(2026, 4, 13));
      expect(bloc.state.reminderEnabled, isFalse);
      expect(bloc.state.reminderTime, '10:20');
      expect(bloc.state.titleError, StarnyxFormTitleError.empty);
    },
  );

  test('edit mode prefills fields from the existing StarNyx', () {
    /// Verifies that edit mode:
    /// - Loads all fields from the provided entity
    /// - Sets validation to null (existing data is assumed valid)
    /// - Has null errors initially
    final existing = StarNyx(
      id: 'habit-1',
      title: 'Hydrate',
      description: 'Drink enough water',
      color: '#102030',
      startDate: DateTime(2026, 4, 10),
      reminderEnabled: true,
      reminderTime: '09:30',
      createdAt: DateTime(2026, 4, 10, 8),
      updatedAt: DateTime(2026, 4, 10, 8),
    );
    final bloc = StarnyxFormBloc(
      createStarNyxUseCase: createUseCase,
      updateStarNyxUseCase: updateUseCase,
      initialStarnyx: existing,
      nowBuilder: () => DateTime(2026, 4, 13, 10, 20),
    );

    expect(bloc.state.mode, StarnyxFormMode.edit);
    expect(bloc.state.title, 'Hydrate');
    expect(bloc.state.description, 'Drink enough water');
    expect(bloc.state.color, '#102030');
    expect(bloc.state.startDate, DateTime(2026, 4, 10));
    expect(bloc.state.reminderEnabled, isTrue);
    expect(bloc.state.reminderTime, '09:30');
  });

  test('edit mode preserves an existing reminder time exactly', () {
    final existing = StarNyx(
      id: 'habit-1',
      title: 'Hydrate',
      description: 'Drink enough water',
      color: '#102030',
      startDate: DateTime(2026, 4, 10),
      reminderEnabled: true,
      reminderTime: '09:20',
      createdAt: DateTime(2026, 4, 10, 8),
      updatedAt: DateTime(2026, 4, 10, 8),
    );
    final bloc = StarnyxFormBloc(
      createStarNyxUseCase: createUseCase,
      updateStarNyxUseCase: updateUseCase,
      initialStarnyx: existing,
      nowBuilder: () => DateTime(2026, 4, 13, 10, 20),
    );

    expect(bloc.state.reminderTime, '09:20');
  });

  test('changing fields updates validation state', () async {
    /// Verifies that:
    /// - Title changes trigger revalidation (shows error when empty)
    /// - Reminder toggle enables time validation
    /// - Reminder time can be cleared (shows missing error when reminder ON)
    /// - Setting valid time clears the error
    final bloc = StarnyxFormBloc(
      createStarNyxUseCase: createUseCase,
      updateStarNyxUseCase: updateUseCase,
      nowBuilder: () => DateTime(2026, 4, 13, 10, 20),
    );

    bloc.add(const StarnyxFormTitleChanged('Read'));
    await pumpEventQueue();
    expect(bloc.state.title, 'Read');
    expect(bloc.state.titleError, isNull);

    bloc.add(const StarnyxFormReminderToggled(true));
    bloc.add(const StarnyxFormReminderTimeChanged(''));
    await pumpEventQueue();
    expect(bloc.state.reminderTimeError, StarnyxFormReminderTimeError.missing);

    bloc.add(const StarnyxFormReminderTimeChanged('07:30'));
    await pumpEventQueue();
    expect(bloc.state.reminderTimeError, isNull);
  });

  test('changing reminder time preserves the selected minutes', () async {
    final bloc = StarnyxFormBloc(
      createStarNyxUseCase: createUseCase,
      updateStarNyxUseCase: updateUseCase,
      nowBuilder: () => DateTime(2026, 4, 13, 10, 20),
    );

    bloc.add(const StarnyxFormReminderToggled(true));
    bloc.add(const StarnyxFormReminderTimeChanged('07:44'));
    await pumpEventQueue();

    expect(bloc.state.reminderTime, '07:44');

    bloc.add(const StarnyxFormReminderTimeChanged('07:45'));
    await pumpEventQueue();

    expect(bloc.state.reminderTime, '07:45');
  });

  test('start date older than 7 days surfaces a form error', () async {
    final bloc = StarnyxFormBloc(
      createStarNyxUseCase: createUseCase,
      updateStarNyxUseCase: updateUseCase,
      nowBuilder: () => DateTime(2026, 4, 13, 10, 20),
    );

    bloc.add(const StarnyxFormTitleChanged('Hydrate'));
    bloc.add(StarnyxFormStartDateChanged(DateTime(2026, 4, 5)));
    await pumpEventQueue();

    expect(bloc.state.startDateError, StarnyxFormStartDateError.tooFarInPast);
  });

  test('submit creates a new StarNyx when the form is valid', () async {
    /// Verifies the complete submit flow:
    /// - Valid form → inProgress → success state
    /// - Whitespace is trimmed (title and description)
    /// - Empty description becomes null (optional field)
    /// - Reminder time is saved when enabled
    /// - Returned entity is populated in savedStarnyx
    /// - Repository contains the new item
    final bloc = StarnyxFormBloc(
      createStarNyxUseCase: createUseCase,
      updateStarNyxUseCase: updateUseCase,
      nowBuilder: () => DateTime(2026, 4, 13, 10, 20),
    );

    bloc.add(const StarnyxFormTitleChanged(' Read 20 pages '));
    bloc.add(const StarnyxFormDescriptionChanged('  Before bed  '));
    bloc.add(const StarnyxFormColorChanged('#ABCDEF'));
    bloc.add(const StarnyxFormReminderToggled(true));
    bloc.add(const StarnyxFormReminderTimeChanged('21:00'));
    await pumpEventQueue();

    bloc.add(const StarnyxFormSubmitted());
    await pumpEventQueue(times: 10);

    expect(bloc.state.submissionStatus, StarnyxFormSubmissionStatus.success);
    expect(bloc.state.savedStarnyx, isNotNull);
    expect(bloc.state.savedStarnyx?.title, 'Read 20 pages');
    expect(bloc.state.savedStarnyx?.description, 'Before bed');
    expect(bloc.state.savedStarnyx?.reminderTime, '21:00');
    expect(await repository.getAllStarnyxs(), hasLength(1));
  });

  test(
    'submit persists the exact reminder time selected by the user',
    () async {
      final bloc = StarnyxFormBloc(
        createStarNyxUseCase: createUseCase,
        updateStarNyxUseCase: updateUseCase,
        nowBuilder: () => DateTime(2026, 4, 13, 10, 20),
      );

      bloc.add(const StarnyxFormTitleChanged('Read 20 pages'));
      bloc.add(const StarnyxFormReminderToggled(true));
      bloc.add(const StarnyxFormReminderTimeChanged('21:20'));
      await pumpEventQueue();

      bloc.add(const StarnyxFormSubmitted());
      await pumpEventQueue(times: 10);

      expect(bloc.state.submissionStatus, StarnyxFormSubmissionStatus.success);
      expect(bloc.state.savedStarnyx?.reminderTime, '21:20');
    },
  );

  test('submit updates an existing StarNyx in edit mode', () async {
    /// Verifies that:
    /// - Edit mode calls updateUseCase instead of createStarNyxUseCase
    /// - Entity ID is preserved
    /// - Fields are updated correctly
    /// - Success state includes the updated entity
    final existing = StarNyx(
      id: 'habit-1',
      title: 'Hydrate',
      description: null,
      color: '#102030',
      startDate: DateTime(2026, 4, 10),
      reminderEnabled: false,
      reminderTime: null,
      createdAt: DateTime(2026, 4, 10, 8),
      updatedAt: DateTime(2026, 4, 10, 8),
    );
    await repository.saveStarnyx(existing);

    final bloc = StarnyxFormBloc(
      createStarNyxUseCase: createUseCase,
      updateStarNyxUseCase: updateUseCase,
      initialStarnyx: existing,
      nowBuilder: () => DateTime(2026, 4, 13, 10, 20),
    );

    bloc.add(const StarnyxFormTitleChanged('Hydrate Daily'));
    await pumpEventQueue();
    bloc.add(const StarnyxFormSubmitted());
    await pumpEventQueue(times: 10);

    expect(bloc.state.submissionStatus, StarnyxFormSubmissionStatus.success);
    expect(bloc.state.savedStarnyx?.id, 'habit-1');
    expect(bloc.state.savedStarnyx?.title, 'Hydrate Daily');
  });

  test('submit drops reminder time when reminder is disabled', () async {
    final bloc = StarnyxFormBloc(
      createStarNyxUseCase: createUseCase,
      updateStarNyxUseCase: updateUseCase,
      nowBuilder: () => DateTime(2026, 4, 13, 10, 20),
    );

    bloc.add(const StarnyxFormTitleChanged('Stretch'));
    bloc.add(const StarnyxFormReminderTimeChanged('21:00'));
    await pumpEventQueue();
    bloc.add(const StarnyxFormSubmitted());
    await pumpEventQueue(times: 10);

    expect(bloc.state.submissionStatus, StarnyxFormSubmissionStatus.success);
    expect(bloc.state.savedStarnyx?.reminderEnabled, isFalse);
    expect(bloc.state.savedStarnyx?.reminderTime, isNull);
  });

  test(
    'submit surfaces validation errors instead of calling use cases',
    () async {
      /// Verifies that:
      /// - Submitting an invalid form (empty title) doesn't call use cases
      /// - Submission status stays idle (no network request)
      /// - Validation errors are displayed immediately
      /// - Repository remains unchanged
      final bloc = StarnyxFormBloc(
        createStarNyxUseCase: createUseCase,
        updateStarNyxUseCase: updateUseCase,
        nowBuilder: () => DateTime(2026, 4, 13, 10, 20),
      );

      bloc.add(const StarnyxFormSubmitted());
      await pumpEventQueue();

      expect(bloc.state.submissionStatus, StarnyxFormSubmissionStatus.idle);
      expect(bloc.state.titleError, StarnyxFormTitleError.empty);
      expect(await repository.getAllStarnyxs(), isEmpty);
    },
  );

  test('submit maps future start dates to form errors', () async {
    /// Verifies that:
    /// - Start dates in the future are rejected
    /// - Error is mapped to form state (not thrown as exception)
    /// - Submission status stays idle (validation error, no use case call)
    final bloc = StarnyxFormBloc(
      createStarNyxUseCase: createUseCase,
      updateStarNyxUseCase: updateUseCase,
      nowBuilder: () => DateTime(2026, 4, 13, 10, 20),
    );

    bloc.add(const StarnyxFormTitleChanged('Hydrate'));
    bloc.add(StarnyxFormStartDateChanged(DateTime(2026, 4, 14)));
    await pumpEventQueue();
    bloc.add(const StarnyxFormSubmitted());
    await pumpEventQueue(times: 10);

    expect(bloc.state.submissionStatus, StarnyxFormSubmissionStatus.idle);
    expect(bloc.state.startDateError, StarnyxFormStartDateError.inFuture);
  });

  test('submit maps start dates older than 7 days to form errors', () async {
    final bloc = StarnyxFormBloc(
      createStarNyxUseCase: createUseCase,
      updateStarNyxUseCase: updateUseCase,
      nowBuilder: () => DateTime(2026, 4, 13, 10, 20),
    );

    bloc.add(const StarnyxFormTitleChanged('Hydrate'));
    bloc.add(StarnyxFormStartDateChanged(DateTime(2026, 4, 5)));
    await pumpEventQueue();
    bloc.add(const StarnyxFormSubmitted());
    await pumpEventQueue(times: 10);

    expect(bloc.state.submissionStatus, StarnyxFormSubmissionStatus.idle);
    expect(bloc.state.startDateError, StarnyxFormStartDateError.tooFarInPast);
  });
}

/// In-memory mock repository for testing BLoC logic without database.
/// Implements StarNyxRepository interface to simulate persistence.
class _InMemoryStarNyxRepository implements StarNyxRepository {
  /// Storage map for mocked entities.
  final Map<String, StarNyx> _items = <String, StarNyx>{};

  /// Deletes a StarNyx by ID.
  @override
  Future<void> deleteStarnyxById(String id) async {
    _items.remove(id);
  }

  /// Returns all stored StarNyxs sorted by creation date.
  @override
  Future<List<StarNyx>> getAllStarnyxs() async {
    final items = _items.values.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return items;
  }

  /// Retrieves a single StarNyx by ID (returns null if not found).
  @override
  Future<StarNyx?> getStarnyxById(String id) async => _items[id];

  /// Saves (inserts or updates) a StarNyx entity.
  @override
  Future<void> saveStarnyx(StarNyx starnyx) async {
    _items[starnyx.id] = starnyx;
  }

  /// Watches all StarNyxs for real-time updates (streams the list once for testing).
  @override
  Stream<List<StarNyx>> watchAllStarnyxs() async* {
    yield _items.values.toList();
  }
}
