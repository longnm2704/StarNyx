import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:starnyx/core/widgets/core_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starnyx/features/home/presentation/widgets/active_starnyx_home_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets(
    'returning placeholder renders saved starnyxs and forwards edit taps',
    (tester) async {
      final starnyxs = <StarNyx>[
        StarNyx(
          id: '1',
          title: 'Hydrate',
          description: 'Drink water',
          color: '#2360E9',
          startDate: DateTime(2026, 4, 10),
          reminderEnabled: true,
          reminderTime: '09:15',
          createdAt: DateTime(2026, 4, 10, 8),
          updatedAt: DateTime(2026, 4, 10, 8),
        ),
        StarNyx(
          id: '2',
          title: 'Stretch',
          description: null,
          color: '#DE7B30',
          startDate: DateTime(2026, 4, 11),
          reminderEnabled: false,
          reminderTime: null,
          createdAt: DateTime(2026, 4, 11, 8),
          updatedAt: DateTime(2026, 4, 11, 8),
        ),
      ];
      StarNyx? edited;
      var createPressed = false;
      var checkInPressed = false;
      var previousPressed = false;
      var nextPressed = false;
      var jumpTodayPressed = false;
      var previousYearPressed = false;
      var nextYearPressed = false;

      await tester.pumpWidget(
        _buildLocalizedApp(
          ActiveStarnyxHomeView(
            starnyxs: starnyxs,
            activeStarnyxId: '1',
            selectedDate: DateTime(2026, 4, 18),
            todayDate: DateTime(2026, 4, 19),
            viewedYear: 2026,
            completedDatesForViewedYear: <DateTime>[DateTime(2026, 4, 18)],
            onCreatePressed: () {
              createPressed = true;
            },
            onEditPressed: (starnyx) {
              edited = starnyx;
            },
            onDateSelected: (_) {},
            onSelectPressed: (starnyx) {
              edited = starnyx;
            },
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
      expect(find.text('Swipe up for tools'), findsOneWidget);
      expect(find.text('2026'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(
        find.byKey(const Key('home-star-grid-placeholder')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('home-selected-date-button')));
      await tester.pump();
      expect(checkInPressed, isTrue);
      await tester.tap(find.byKey(const Key('home-previous-day-button')));
      await tester.pump();
      expect(previousPressed, isTrue);
      await tester.tap(find.byKey(const Key('home-next-day-button')));
      await tester.pump();
      expect(nextPressed, isTrue);
      await tester.tap(find.byKey(const Key('home-jump-today-button')));
      await tester.pump();
      expect(jumpTodayPressed, isTrue);
      await tester.tap(find.byKey(const Key('home-previous-year-button')));
      await tester.pump();
      expect(previousYearPressed, isTrue);
      await tester.tap(find.byKey(const Key('home-next-year-button')));
      await tester.pump();
      expect(nextYearPressed, isFalse);

      await tester.tap(find.text('Swipe up for tools'));
      await tester.pump(const Duration(milliseconds: 220));
      await tester.pump(const Duration(milliseconds: 220));
      await tester.pump(const Duration(milliseconds: 220));

      expect(find.text('Constellation Deck'), findsOneWidget);
      expect(find.text('Switch, write, or adjust'), findsOneWidget);
      expect(find.text('Current focus'), findsOneWidget);
      expect(find.text('Your constellations'), findsOneWidget);
      expect(find.text('Edit to reorder'), findsOneWidget);
      expect(find.text('Stretch'), findsOneWidget);
      expect(_findSvg('assets/icons/ic_settings.svg'), findsOneWidget);
      expect(_findSvg('assets/icons/ic_book.svg'), findsOneWidget);
      expect(_findSvg('assets/icons/ic_plus.svg'), findsOneWidget);

      expect(edited, isNull);
      expect(find.text('Constellation Deck'), findsOneWidget);

      _pressTextButton(tester, 'Edit');
      await tester.pump();
      expect(find.text('Done'), findsOneWidget);
      expect(_findSvg('assets/icons/ic_cursor.svg'), findsWidgets);

      _pressTextButton(tester, 'Done');
      await tester.pump();
      expect(find.text('Edit'), findsOneWidget);

      _pressSheetActionIcon(tester, 'assets/icons/ic_plus.svg');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 220));
      await tester.pump(const Duration(milliseconds: 220));
      await tester.pump(const Duration(milliseconds: 220));
      expect(createPressed, isTrue);
      createPressed = false;
      expect(find.text('Constellation Deck'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Stretch'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pump();
      await tester.tap(find.text('Stretch'));
      await tester.pump();
      expect(edited, starnyxs[1]);
      edited = null;

      await tester.tap(find.text('Swipe up for tools'));
      await tester.pump(const Duration(milliseconds: 220));
      await tester.pump(const Duration(milliseconds: 220));
      await tester.pump(const Duration(milliseconds: 220));

      await tester.scrollUntilVisible(
        _findSvg('assets/icons/ic_edit.svg').last,
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pump();
      _pressIconButton(tester, _findSvg('assets/icons/ic_edit.svg').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 220));
      await tester.pump(const Duration(milliseconds: 220));
      await tester.pump(const Duration(milliseconds: 220));
      expect(edited, starnyxs[1]);
      edited = null;
      expect(find.text('Constellation Deck'), findsOneWidget);
    },
  );

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

Finder _findSvg(String assetPath) {
  return find.byWidgetPredicate(
    (Widget widget) => widget is AppSvgIcon && widget.assetPath == assetPath,
  );
}

void _pressTextButton(WidgetTester tester, String label) {
  final button = tester.widget<TextButton>(
    find.widgetWithText(TextButton, label),
  );
  button.onPressed!.call();
}

void _pressSheetActionIcon(WidgetTester tester, String assetPath) {
  final action = tester.widget<InkWell>(
    find.ancestor(of: _findSvg(assetPath), matching: find.byType(InkWell)),
  );
  action.onTap!.call();
}

void _pressIconButton(WidgetTester tester, Finder finder) {
  final button = tester.widget<IconButton>(
    find.ancestor(of: finder, matching: find.byType(IconButton)),
  );
  button.onPressed!.call();
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
