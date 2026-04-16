import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:starnyx/core/widgets/app_svg_icon.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/domain/entities/starnyx_progress_stats.dart';
import 'package:starnyx/features/home/presentation/widgets/home_shell_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets(
    'home shell view renders the STX-025 shell with bound title and footer data',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildLocalizedApp(
          HomeShellView(
            activeStarnyx: _starnyx(),
            selectedDate: DateTime(2026, 4, 19),
            todayDate: DateTime(2026, 4, 19),
            viewedYear: 2026,
            completedDatesForViewedYear: <DateTime>[
              DateTime(2026, 4, 10),
              DateTime(2026, 4, 12),
              DateTime(2026, 4, 18),
            ],
            progressStats: const StarNyxProgressStats(
              currentStreak: 0,
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
            onQuickActionsPressed: null,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Hydrate'), findsOneWidget);
      expect(find.text('Drink water'), findsOneWidget);
      expect(find.text('2026'), findsOneWidget);
      expect(find.text('257 days left'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Sunday, 19 Apr'), findsOneWidget);
      expect(find.text('Total: 2 · Streak: 0'), findsOneWidget);
      expect(
        find.byKey(const Key('home-star-grid-placeholder')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('home-star-grid-day-count-365')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('home-selected-star-cell')), findsOneWidget);
      expect(
        find.byKey(const Key('home-before-start-star-cell-98')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('home-completed-star-cell-99')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('home-missed-star-cell-100')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('home-today-star-cell-108')), findsOneWidget);
      expect(
        find.byKey(const Key('home-future-star-cell-109')),
        findsOneWidget,
      );
      expect(_findSvg('assets/icons/ic_star_active.svg'), findsWidgets);
      expect(_findSvg('assets/icons/ic_star.svg'), findsWidgets);
    },
  );

  test('home grid day count returns 366 for leap years', () {
    expect(homeGridDayCountForYear(2024), 366);
    expect(homeGridDayCountForYear(2026), 365);
  });

  test('home shell gradient colors follow the active starnyx color', () {
    final colors = homeShellGradientColors('#2360E9');

    expect(colors.length, 4);
    expect(colors.last, AppColors.black);
    expect(colors.first, isNot(const Color(0xFFB45A21)));
  });

  test('home shell accent color follows the active starnyx color', () {
    expect(homeShellAccentColor('#2360E9'), const Color(0xFF2360E9));
    expect(homeShellAccentColor('#DE7B30'), const Color(0xFFDE7B30));
  });

  test('home grid keeps the yearly layout fixed at 18 columns', () {
    expect(homeGridColumnCount, 18);
  });

  test('home grid date mapping follows the viewed year day indexes', () {
    expect(homeGridDateForIndex(2026, 0), DateTime.utc(2026, 1, 1));
    expect(homeGridDateForIndex(2026, 99), DateTime.utc(2026, 4, 10));
    expect(homeGridDateForIndex(2026, 364), DateTime.utc(2026, 12, 31));
    expect(homeGridDateForIndex(2024, 365), DateTime.utc(2024, 12, 31));
  });

  test(
    'days left uses today date and stays fixed within the same viewed year',
    () {
      expect(
        homeShellDaysLeftInViewedYear(
          viewedYear: 2026,
          todayDate: DateTime(2026, 4, 19),
        ),
        257,
      );
      expect(
        homeShellDaysLeftInViewedYear(
          viewedYear: 2026,
          todayDate: DateTime(2026, 4, 19),
        ),
        homeShellDaysLeftInViewedYear(
          viewedYear: 2026,
          todayDate: DateTime(2026, 4, 19, 23, 59),
        ),
      );
      expect(
        homeShellDaysLeftInViewedYear(
          viewedYear: 2025,
          todayDate: DateTime(2026, 4, 19),
        ),
        0,
      );
    },
  );
}

Finder _findSvg(String assetPath) {
  return find.byWidgetPredicate(
    (Widget widget) => widget is AppSvgIcon && widget.assetPath == assetPath,
  );
}

StarNyx _starnyx() {
  return StarNyx(
    id: '1',
    title: 'Hydrate',
    description: 'Drink water',
    color: '#DE7B30',
    startDate: DateTime(2026, 4, 10),
    reminderEnabled: true,
    reminderTime: '09:15',
    createdAt: DateTime(2026, 4, 10, 8),
    updatedAt: DateTime(2026, 4, 10, 8),
  );
}

Widget _buildLocalizedApp(Widget child) {
  return EasyLocalization(
    supportedLocales: const <Locale>[Locale('en')],
    path: 'assets/translations',
    fallbackLocale: const Locale('en'),
    child: Builder(
      builder: (BuildContext context) {
        return MaterialApp(
          locale: context.locale,
          supportedLocales: context.supportedLocales,
          localizationsDelegates: context.localizationDelegates,
          home: Scaffold(body: child),
        );
      },
    ),
  );
}
