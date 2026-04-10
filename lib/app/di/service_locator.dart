import 'package:get_it/get_it.dart';
import 'package:starnyx/app/router/app_router.dart';
import 'package:uuid/uuid.dart';

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
  // Keeping AppRouter injectable makes later navigation changes easier.
  serviceLocator.registerLazySingleton<AppRouter>(AppRouter.new);
  serviceLocator.registerLazySingleton<Uuid>(Uuid.new);
}

// These empty sections keep future registrations organized by layer.
void _registerServices() {}

void _registerRepositories() {}

void _registerUseCases() {}

void _registerBlocFactories() {}
