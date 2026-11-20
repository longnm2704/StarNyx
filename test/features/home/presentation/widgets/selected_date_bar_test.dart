import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starnyx/core/constants/habit_symbols.dart';
import 'package:starnyx/core/widgets/app_icon.dart';
import 'package:starnyx/core/widgets/core_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starnyx/features/home/presentation/widgets/selected_date_bar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('renders date label, habit symbol icon, and action text', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SelectedDateBar(
            selectedDateLabel: 'Sunday, 19 Apr',
            onPreviousDayPressed: () {},
            onNextDayPressed: () {},
            accentColor: const Color(0xFFDE7B30),
            symbolKey: 'flame',
            isLit: false,
            onSelectedDatePressed: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('home-selected-date-button')), findsOneWidget);
    // Habit symbol icon is present.
    expect(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget is AppIcon && widget.icon == HabitSymbols.iconFor('flame'),
      ),
      findsWidgets,
    );
    // Two text widgets: date label + action text.
    expect(find.byType(Text), findsNWidgets(2));
  });

  testWidgets('shows different number of text widgets for lit vs unlit', (
    WidgetTester tester,
  ) async {
    // Unlit: date + action text
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SelectedDateBar(
            selectedDateLabel: 'Sunday, 19 Apr',
            onPreviousDayPressed: () {},
            onNextDayPressed: () {},
            accentColor: const Color(0xFFDE7B30),
            symbolKey: 'star',
            isLit: false,
            onSelectedDatePressed: () {},
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(Text), findsNWidgets(2));

    // Lit: date + action text (same count, different content)
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SelectedDateBar(
            selectedDateLabel: 'Sunday, 19 Apr',
            onPreviousDayPressed: () {},
            onNextDayPressed: () {},
            accentColor: const Color(0xFFDE7B30),
            symbolKey: 'star',
            isLit: true,
            onSelectedDatePressed: () {},
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(Text), findsNWidgets(2));
  });

  testWidgets('is non-interactive when completion toggle is disabled', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SelectedDateBar(
            selectedDateLabel: 'Sunday, 19 Apr',
            onPreviousDayPressed: () {},
            onNextDayPressed: () {},
            accentColor: const Color(0xFFDE7B30),
            symbolKey: 'star',
            isLit: false,
            onSelectedDatePressed: null,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('home-selected-date-button')), findsOneWidget);
    final button = tester.widget<InkWell>(
      find.byKey(const Key('home-selected-date-button')),
    );
    expect(button.onTap, isNull);
  });

  testWidgets('past days say "this day"; disabled days explain why', (
    WidgetTester tester,
  ) async {
    Widget bar({required bool isToday, VoidCallback? onPressed}) {
      return MaterialApp(
        home: Scaffold(
          body: SelectedDateBar(
            selectedDateLabel: 'Friday, 17 Apr',
            onPreviousDayPressed: () {},
            onNextDayPressed: () {},
            accentColor: const Color(0xFFDE7B30),
            symbolKey: 'star',
            isLit: false,
            isToday: isToday,
            blockedReason: 'Only the last 7 days can be changed',
            onSelectedDatePressed: onPressed,
          ),
        ),
      );
    }

    await tester.pumpWidget(bar(isToday: false, onPressed: () {}));
    expect(find.text('home.checkin_light_day'), findsOneWidget);
    expect(find.text('home.checkin_light_today'), findsNothing);

    await tester.pumpWidget(bar(isToday: false));
    expect(find.text('Only the last 7 days can be changed'), findsOneWidget);
  });
}
