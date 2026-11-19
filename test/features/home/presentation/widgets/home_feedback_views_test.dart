import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starnyx/features/home/presentation/widgets/active_starnyx_home_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('active habit view renders the habit shell and forwards taps', (
    tester,
  ) async {
    final starnyx = StarNyx(
      id: '1',
      title: 'Hydrate',
      description: 'Drink water',
      color: '#2360E9',
      startDate: DateTime(2026, 4, 10),
      reminderEnabled: true,
      reminderTime: '09:15',
      createdAt: DateTime(2026, 4, 10, 8),
      updatedAt: DateTime(2026, 4, 10, 8),
    );
    var checkInPressed = false;
    var previousPressed = false;
    var nextPressed = false;
    var jumpTodayPressed = false;
    var previousYearPressed = false;
    var nextYearPressed = false;

    await tester.pumpWidget(
      _buildLocalizedApp(
        ActiveStarnyxHomeView(
          activeStarnyx: starnyx,
          selectedDate: DateTime(2026, 4, 18),
          todayDate: DateTime(2026, 4, 19),
          viewedYear: 2026,
          completedDatesForViewedYear: <DateTime>[DateTime(2026, 4, 18)],
          onDateSelected: (_) {},
          onPreviousDayPressed: () {
            previousPressed = true;
          },
          onNextDayPressed: () {
            nextPressed = true;
          },
          onJumpToTodayPressed: () {
            jumpTodayPressed = true;
          },
          onPreviousYearPressed: () {
            previousYearPressed = true;
          },
          onNextYearPressed: () {
            nextYearPressed = true;
          },
          onProfilePressed: () {},
          onToggleCompletionPressed: () {
            checkInPressed = true;
          },
          isCheckingIn: false,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Hydrate'), findsOneWidget);
    expect(find.text('Drink water'), findsOneWidget);
    expect(find.text('2026'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.byKey(const Key('home-star-grid-placeholder')), findsOneWidget);
    expect(find.text('Swipe up for tools'), findsNothing);
    expect(find.text('Habit Deck'), findsNothing);

    await tester.ensureVisible(
      find.byKey(const Key('home-selected-date-button')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home-selected-date-button')));
    await tester.pump();
    expect(checkInPressed, isTrue);
    await tester.ensureVisible(
      find.byKey(const Key('home-previous-day-button')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home-previous-day-button')));
    await tester.pump();
    expect(previousPressed, isTrue);
    await tester.ensureVisible(find.byKey(const Key('home-next-day-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home-next-day-button')));
    await tester.pump();
    expect(nextPressed, isTrue);
    await tester.ensureVisible(find.byKey(const Key('home-jump-today-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home-jump-today-button')));
    await tester.pump();
    expect(jumpTodayPressed, isTrue);
    await tester.ensureVisible(
      find.byKey(const Key('home-previous-year-button')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home-previous-year-button')));
    await tester.pump();
    expect(previousYearPressed, isTrue);
    await tester.ensureVisible(find.byKey(const Key('home-next-year-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home-next-year-button')));
    await tester.pump();
    expect(nextYearPressed, isFalse);
  });

  testWidgets('selected date button is disabled outside 7-day edit window', (
    tester,
  ) async {
    expect(
      canToggleCompletionForSelectedDate(
        selectedDate: DateTime(2026, 4, 3),
        todayDate: DateTime(2026, 4, 10),
        startDate: DateTime(2026, 4, 1),
      ),
      isFalse,
    );
    expect(
      canToggleCompletionForSelectedDate(
        selectedDate: DateTime(2026, 4, 4),
        todayDate: DateTime(2026, 4, 10),
        startDate: DateTime(2026, 4, 1),
      ),
      isTrue,
    );
    expect(
      canToggleCompletionForSelectedDate(
        selectedDate: DateTime(2026, 3, 31),
        todayDate: DateTime(2026, 4, 10),
        startDate: DateTime(2026, 4, 1),
      ),
      isFalse,
    );
    expect(
      canToggleCompletionForSelectedDate(
        selectedDate: DateTime(2026, 4, 11),
        todayDate: DateTime(2026, 4, 10),
        startDate: DateTime(2026, 4, 1),
      ),
      isFalse,
    );
  });
}

Widget _buildLocalizedApp(Widget child) {
  return EasyLocalization(
    supportedLocales: const <Locale>[Locale('en')],
    path: 'assets/translations',
    fallbackLocale: const Locale('en'),
    child: Builder(
      builder: (context) {
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
