import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/core/widgets/core_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starnyx/features/home/presentation/widgets/home_star_grid.dart';

Finder _findIcon(List<List<dynamic>> icon) {
  return find.byWidgetPredicate(
    (Widget widget) => widget is AppIcon && widget.icon == icon,
  );
}

Widget _buildLocalizedApp(Widget child) {
  return EasyLocalization(
    supportedLocales: const <Locale>[Locale('en')],
    fallbackLocale: const Locale('en'),
    path: 'assets/translations',
    useOnlyLangCode: true,
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

Widget _grid({
  required String symbolKey,
  int viewedYear = 2026,
  DateTime? selectedDate,
  DateTime? todayDate,
  DateTime? startDate,
  List<DateTime> completedDatesForViewedYear = const <DateTime>[],
  int? completionSuccessAnimationToken,
}) {
  final now = DateTime(2026, 4, 10);
  return HomeStarGrid(
    viewedYear: viewedYear,
    selectedDate: selectedDate ?? now,
    todayDate: todayDate ?? now,
    startDate: startDate ?? now,
    completedDatesForViewedYear: completedDatesForViewedYear,
    accentColor: const Color(0xFFDE7B30),
    onDateSelected: (_) {},
    completionSuccessAnimationToken: completionSuccessAnimationToken,
    symbolKey: symbolKey,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets(
    'renders the configured habit symbol, defaults to star, and preserves day-state keys',
    (WidgetTester tester) async {
      // ── Flame symbol renders instead of the fixed star ──
      await tester.pumpWidget(
        _buildLocalizedApp(_grid(symbolKey: 'flame')),
      );
      await tester.pump();

      expect(
        find.byKey(const Key('home-star-grid-placeholder')),
        findsOneWidget,
      );
      expect(_findIcon(HabitSymbols.iconFor('flame')), findsWidgets);
      expect(_findIcon(HabitSymbols.iconFor('star')), findsNothing);

      // ── Default symbol key falls back to star ──
      await tester.pumpWidget(
        _buildLocalizedApp(_grid(symbolKey: HabitSymbols.defaultKey)),
      );
      await tester.pump();

      expect(_findIcon(HabitSymbols.iconFor('star')), findsWidgets);

      // ── Day-state keys are preserved for every state ──
      await tester.pumpWidget(
        _buildLocalizedApp(
          _grid(
            symbolKey: 'clover',
            selectedDate: DateTime(2026, 4, 19),
            todayDate: DateTime(2026, 4, 19),
            completedDatesForViewedYear: <DateTime>[
              DateTime(2026, 4, 12),
              DateTime(2026, 4, 18),
            ],
          ),
        ),
      );
      await tester.pump();

      expect(
        find.byKey(const ValueKey<String>('home-star-grid-day-count-365')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('home-selected-star-cell')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('home-before-start-star-cell-98')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('home-completed-star-cell-101')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('home-missed-star-cell-100')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('home-today-star-cell-108')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('home-future-star-cell-109')),
        findsOneWidget,
      );
    },
  );
}
