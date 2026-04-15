import 'package:uuid/uuid.dart';
import 'package:get_it/get_it.dart';
import 'package:starnyx/data/db/app_database.dart';
import 'package:starnyx/app/router/app_router.dart';
import 'package:starnyx/domain/usecases/domain_usecases.dart';
import 'package:starnyx/domain/entities/starnyx.dart' as domain;
import 'package:starnyx/data/repositories/data_repositories.dart';
import 'package:starnyx/domain/repositories/domain_repositories.dart';
import 'package:starnyx/features/home/presentation/bloc/home_bloc.dart';
import 'package:starnyx/features/starnyx_form/presentation/bloc/starnyx_form_bloc.dart';

final GetIt serviceLocator = GetIt.instance;

/// Registers all application dependencies in a single setup call.
/// Organizes registration into layers:
/// 1. Repositories (data layer)
/// 2. Use cases (domain layer)
/// 3. BLoC factories (presentation layer)
/// 4. Router and app infrastructure
Future<void> configureDependencies() async {
  // This guard keeps hot restart / repeated bootstrap from double-registering.
  if (serviceLocator.isRegistered<AppRouter>()) {
    return;
  }

  _registerCoreDependencies();
  _registerServices();
  _registerRepositories();
  _registerUseCases();
  _registerBlocFactories();
}

Future<void> resetDependencies() {
  return serviceLocator.reset();
}

void _registerCoreDependencies() {
  // Uuid is a simple utility that doesn't need to be recreated every time, so we can register it as a singleton.
  serviceLocator.registerLazySingleton<Uuid>(Uuid.new);
  // One shared database instance keeps SQLite access consistent across the app.
  serviceLocator.registerLazySingleton<AppDatabase>(AppDatabase.new);
  // Keeping AppRouter injectable makes later navigation changes easier.
  serviceLocator.registerLazySingleton<AppRouter>(AppRouter.new);
}

// These empty sections keep future registrations organized by layer.
void _registerServices() {}

void _registerRepositories() {
  // Domain code depends on abstractions while DI wires the Drift implementations.
  serviceLocator.registerLazySingleton<StarNyxRepository>(
    () => DriftStarNyxRepository(serviceLocator<AppDatabase>()),
  );
  serviceLocator.registerLazySingleton<CompletionRepository>(
    () => DriftCompletionRepository(serviceLocator<AppDatabase>()),
  );
  serviceLocator.registerLazySingleton<JournalEntryRepository>(
    () => DriftJournalEntryRepository(serviceLocator<AppDatabase>()),
  );
  serviceLocator.registerLazySingleton<AppSettingsRepository>(
    () => DriftAppSettingsRepository(serviceLocator<AppDatabase>()),
  );
}

void _registerUseCases() {
  // Use cases keep UI and blocs focused on orchestration instead of repository details.
  serviceLocator.registerLazySingleton<CreateStarNyxUseCase>(
    () => CreateStarNyxUseCase(
      serviceLocator<StarNyxRepository>(),
      serviceLocator<Uuid>(),
    ),
  );
  serviceLocator.registerLazySingleton<UpdateStarNyxUseCase>(
    () => UpdateStarNyxUseCase(serviceLocator<StarNyxRepository>()),
  );
  serviceLocator.registerLazySingleton<DeleteStarNyxUseCase>(
    () => DeleteStarNyxUseCase(
      serviceLocator<StarNyxRepository>(),
      serviceLocator<AppSettingsRepository>(),
    ),
  );
  serviceLocator.registerLazySingleton<LoadStarnyxsUseCase>(
    () => LoadStarnyxsUseCase(serviceLocator<StarNyxRepository>()),
  );
  serviceLocator.registerLazySingleton<LoadActiveStarNyxUseCase>(
    () => LoadActiveStarNyxUseCase(
      serviceLocator<StarNyxRepository>(),
      serviceLocator<AppSettingsRepository>(),
    ),
  );
  serviceLocator.registerLazySingleton<LoadStarNyxProgressStatsUseCase>(
    () => LoadStarNyxProgressStatsUseCase(
      serviceLocator<StarNyxRepository>(),
      serviceLocator<CompletionRepository>(),
    ),
  );
  serviceLocator
      .registerLazySingleton<LoadStarNyxCompletionDatesForYearUseCase>(
        () => LoadStarNyxCompletionDatesForYearUseCase(
          serviceLocator<CompletionRepository>(),
        ),
      );
  serviceLocator.registerLazySingleton<SelectActiveStarNyxUseCase>(
    () => SelectActiveStarNyxUseCase(
      serviceLocator<StarNyxRepository>(),
      serviceLocator<AppSettingsRepository>(),
    ),
  );
  serviceLocator.registerLazySingleton<ToggleCompletionUseCase>(
    () => ToggleCompletionUseCase(
      serviceLocator<StarNyxRepository>(),
      serviceLocator<CompletionRepository>(),
    ),
  );
  serviceLocator.registerLazySingleton<SaveJournalEntryUseCase>(
    () => SaveJournalEntryUseCase(serviceLocator<JournalEntryRepository>()),
  );
  serviceLocator.registerLazySingleton<ExportDataUseCase>(
    () => ExportDataUseCase(
      serviceLocator<StarNyxRepository>(),
      serviceLocator<CompletionRepository>(),
      serviceLocator<JournalEntryRepository>(),
      serviceLocator<AppSettingsRepository>(),
    ),
  );
  serviceLocator.registerLazySingleton<ImportDataUseCase>(
    () => ImportDataUseCase(
      serviceLocator<StarNyxRepository>(),
      serviceLocator<CompletionRepository>(),
      serviceLocator<JournalEntryRepository>(),
      serviceLocator<AppSettingsRepository>(),
    ),
  );
}

void _registerBlocFactories() {
  serviceLocator.registerFactory<HomeBloc>(
    () => HomeBloc(
      loadStarnyxsUseCase: serviceLocator<LoadStarnyxsUseCase>(),
      loadActiveStarNyxUseCase: serviceLocator<LoadActiveStarNyxUseCase>(),
      selectActiveStarNyxUseCase: serviceLocator<SelectActiveStarNyxUseCase>(),
      loadStarNyxProgressStatsUseCase:
          serviceLocator<LoadStarNyxProgressStatsUseCase>(),
      loadStarNyxCompletionDatesForYearUseCase:
          serviceLocator<LoadStarNyxCompletionDatesForYearUseCase>(),
      toggleCompletionUseCase: serviceLocator<ToggleCompletionUseCase>(),
    ),
  );

  /// Registers StarnyxFormBloc as a factory with optional parameter support.
  ///
  /// GetIt's registerFactoryParam allows the BLoC to be created in two modes:
  /// - **Create mode**: Called with no parameters or param1=null → new form
  /// - **Edit mode**: Called with param1=StarNyx → form prefilled with entity data
  ///
  /// Usage:
  /// ```dart
  /// // Create mode
  /// final bloc = serviceLocator<StarnyxFormBloc>();
  ///
  /// // Edit mode
  /// final bloc = serviceLocator<StarnyxFormBloc>(param1: existingStarnyx);
  /// ```
  ///
  /// The factory automatically injects use cases from the service locator.
  serviceLocator.registerFactoryParam<StarnyxFormBloc, domain.StarNyx?, void>((
    initialStarnyx,
    _,
  ) {
    return StarnyxFormBloc(
      createStarNyxUseCase: serviceLocator<CreateStarNyxUseCase>(),
      updateStarNyxUseCase: serviceLocator<UpdateStarNyxUseCase>(),
      deleteStarNyxUseCase: serviceLocator<DeleteStarNyxUseCase>(),
      initialStarnyx: initialStarnyx,
    );
  });
}
