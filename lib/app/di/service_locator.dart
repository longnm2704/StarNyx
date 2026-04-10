import 'package:get_it/get_it.dart';
import 'package:starnyx/app/router/app_router.dart';
import 'package:uuid/uuid.dart';

final GetIt serviceLocator = GetIt.instance;

Future<void> configureDependencies() async {
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
  serviceLocator.registerLazySingleton<AppRouter>(AppRouter.new);
  serviceLocator.registerLazySingleton<Uuid>(Uuid.new);
}

void _registerServices() {}

void _registerRepositories() {}

void _registerUseCases() {}

void _registerBlocFactories() {}
