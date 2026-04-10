import 'package:uuid/uuid.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starnyx/data/db/app_database.dart';
import 'package:starnyx/app/router/app_router.dart';
import 'package:starnyx/app/di/service_locator.dart';

// Covers the minimal DI contract expected before feature registrations grow.
void main() {
  tearDown(() async {
    await resetDependencies();
  });

  test('registers core app dependencies', () async {
    await configureDependencies();

    expect(serviceLocator.isRegistered<Uuid>(), isTrue);
    expect(serviceLocator.isRegistered<AppRouter>(), isTrue);
    expect(serviceLocator.isRegistered<AppDatabase>(), isTrue);
  });

  test('keeps AppRouter as a lazy singleton', () async {
    await configureDependencies();

    final first = serviceLocator<AppRouter>();
    final second = serviceLocator<AppRouter>();

    expect(identical(first, second), isTrue);
  });

  test('exposes the shared GetIt instance', () {
    expect(identical(serviceLocator, GetIt.instance), isTrue);
  });
}
