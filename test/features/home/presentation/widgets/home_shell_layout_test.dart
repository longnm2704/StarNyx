import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:starnyx/domain/entities/starnyx_progress_stats.dart';
import 'package:starnyx/features/home/presentation/widgets/home_shell_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('layout holds at 320px width and 2.0 text scale', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const <Locale>[Locale('en')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: Builder(
          builder: (BuildContext context) {
            return MaterialApp(
              locale: context.locale,
              supportedLocales: context.supportedLocales,
              localizationsDelegates: context.localizationDelegates,
              home: Scaffold(body: _view()),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('home-star-grid-placeholder')), findsOneWidget);

    final GridView grid = tester.widget<GridView>(
      find.byKey(const Key('home-star-grid-placeholder')),
    );
    final SliverGridDelegateWithFixedCrossAxisCount delegate =
        grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(delegate.crossAxisCount, 18);
    expect(delegate.childAspectRatio, 1.0);
  });
}

Widget _view() {
  return HomeShellView(
    activeStarnyx: StarNyx(
      id: '1',
      title: 'Hydrate',
      description: 'Drink water',
      color: '#DE7B30',
      startDate: DateTime(2026, 4, 10),
      reminderEnabled: true,
      reminderTime: '09:15',
      createdAt: DateTime(2026, 4, 10, 8),
      updatedAt: DateTime(2026, 4, 10, 8),
    ),
    selectedDate: DateTime(2026, 4, 19),
    todayDate: DateTime(2026, 4, 19),
    viewedYear: 2026,
    completedDatesForViewedYear: <DateTime>[DateTime(2026, 4, 18)],
    progressStats: const StarNyxProgressStats(
      currentStreak: 1,
      longestStreak: 2,
      totalCompletedCount: 2,
      completedCountForYear: 3,
      validDayCountForYear: 19,
      completionRateForYear: 3 / 19,
    ),
    onPreviousDayPressed: () {},
    onNextDayPressed: () {},
    onJumpToTodayPressed: () {},
    onDateSelected: (_) {},
    onPreviousYearPressed: () {},
    onNextYearPressed: () {},
    onProfilePressed: () {},
  );
}
