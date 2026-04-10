import 'package:uuid/uuid.dart';
import 'package:get_it/get_it.dart';
import 'package:starnyx/data/db/app_database.dart';
import 'package:starnyx/app/router/app_router.dart';
import 'package:starnyx/data/repositories/data_repositories.dart';
import 'package:starnyx/domain/repositories/domain_repositories.dart';

final GetIt serviceLocator = GetIt.instance;

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

void _registerUseCases() {}

void _registerBlocFactories() {}
