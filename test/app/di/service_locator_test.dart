import 'package:uuid/uuid.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starnyx/data/db/app_database.dart';
import 'package:starnyx/app/router/app_router.dart';
import 'package:starnyx/app/di/service_locator.dart';
import 'package:starnyx/domain/usecases/domain_usecases.dart';
import 'package:starnyx/domain/entities/starnyx.dart' as domain;
import 'package:starnyx/domain/repositories/domain_repositories.dart';
import 'package:starnyx/features/home/presentation/bloc/home_bloc.dart';
import 'package:starnyx/features/starnyx_form/presentation/bloc/starnyx_form_bloc.dart';
import 'package:starnyx/features/starnyx_form/presentation/bloc/starnyx_form_state.dart';

// Covers the minimal DI contract expected before feature registrations grow.
/// Tests the dependency injection setup ensures all services and factories are properly registered.
/// Verifies that the service locator is accessible globally and behaves as a singleton.
void main() {
  tearDown(() async {
    await resetDependencies();
  });

  test('registers core app dependencies', () async {
    await configureDependencies();

    expect(serviceLocator.isRegistered<Uuid>(), isTrue);
    expect(serviceLocator.isRegistered<AppRouter>(), isTrue);
    expect(serviceLocator.isRegistered<AppDatabase>(), isTrue);
    expect(serviceLocator.isRegistered<StarNyxRepository>(), isTrue);
    expect(serviceLocator.isRegistered<CompletionRepository>(), isTrue);
    expect(serviceLocator.isRegistered<JournalEntryRepository>(), isTrue);
    expect(serviceLocator.isRegistered<AppSettingsRepository>(), isTrue);
    expect(serviceLocator.isRegistered<CreateStarNyxUseCase>(), isTrue);
    expect(serviceLocator.isRegistered<UpdateStarNyxUseCase>(), isTrue);
    expect(serviceLocator.isRegistered<DeleteStarNyxUseCase>(), isTrue);
    expect(serviceLocator.isRegistered<LoadStarnyxsUseCase>(), isTrue);
    expect(serviceLocator.isRegistered<LoadActiveStarNyxUseCase>(), isTrue);
    expect(
      serviceLocator.isRegistered<LoadStarNyxProgressStatsUseCase>(),
      isTrue,
    );
    expect(
      serviceLocator.isRegistered<LoadStarNyxCompletionDatesForYearUseCase>(),
      isTrue,
    );
    expect(serviceLocator.isRegistered<SelectActiveStarNyxUseCase>(), isTrue);
    expect(serviceLocator.isRegistered<ToggleCompletionUseCase>(), isTrue);
    expect(serviceLocator.isRegistered<SaveJournalEntryUseCase>(), isTrue);
    expect(serviceLocator.isRegistered<ExportDataUseCase>(), isTrue);
    expect(serviceLocator.isRegistered<ImportDataUseCase>(), isTrue);
    expect(serviceLocator.isRegistered<HomeBloc>(), isTrue);
    expect(serviceLocator.isRegistered<StarnyxFormBloc>(), isTrue);
  });

  test('keeps AppRouter as a lazy singleton', () async {
    /// Verifies that the router is created once and reused.
    await configureDependencies();

    final first = serviceLocator<AppRouter>();
    final second = serviceLocator<AppRouter>();

    expect(identical(first, second), isTrue);
  });

  test('exposes the shared GetIt instance', () {
    /// Verifies that the application's serviceLocator is the global GetIt instance.
    /// This ensures consistency across all parts of the app.
    expect(identical(serviceLocator, GetIt.instance), isTrue);
  });

  test('creates StarnyxFormBloc in create and edit modes', () async {
    /// Verifies that the StarnyxFormBloc factory correctly handles both modes:
    /// - Create mode: No initialStarnyx => form starts empty
    /// - Edit mode: initialStarnyx provided => form prefilled with entity data
    await configureDependencies();

    final createBloc = serviceLocator<StarnyxFormBloc>();

    /// Get a BLoC instance in create mode (no parameters)

    final editBloc = serviceLocator<StarnyxFormBloc>(
      param1: domain.StarNyx(
        id: 'habit-1',
        title: 'Hydrate',
        description: 'Drink enough water',
        color: '#8E5BFF',
        startDate: DateTime(2026, 4, 10),
        reminderEnabled: true,
        reminderTime: '09:30',
        createdAt: DateTime(2026, 4, 10, 8),
        updatedAt: DateTime(2026, 4, 10, 8),
      ),
    );

    expect(createBloc.state.mode, StarnyxFormMode.create);
    expect(editBloc.state.mode, StarnyxFormMode.edit);

    /// Verify each BLoC is in the correct mode

    await createBloc.close();
    await editBloc.close();
  });
}
