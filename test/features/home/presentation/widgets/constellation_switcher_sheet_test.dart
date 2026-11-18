import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/core/widgets/app_icon.dart';
import 'package:starnyx/core/widgets/core_widgets.dart';
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:starnyx/features/home/presentation/widgets/constellation_switcher_sheet.dart';

Finder _findIcon(List<List<dynamic>> icon) {
  return find.byWidgetPredicate(
    (Widget widget) => widget is AppIcon && widget.icon == icon,
  );
}

Widget _buildApp(Widget child) {
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets(
    'each switcher sheet row shows the habit symbol in its color',
    (WidgetTester tester) async {
      final starnyxs = <StarNyx>[
        StarNyx(
          id: 'habit-1',
          title: 'Hydrate',
          description: null,
          color: '#102030',
          startDate: DateTime(2026, 4, 1),
          reminderEnabled: false,
          reminderTime: null,
          createdAt: DateTime(2026, 4, 1, 8),
          updatedAt: DateTime(2026, 4, 1, 8),
          icon: 'star',
          displayOrder: 0,
        ),
        StarNyx(
          id: 'habit-2',
          title: 'Read',
          description: null,
          color: '#FF0000',
          startDate: DateTime(2026, 4, 1),
          reminderEnabled: false,
          reminderTime: null,
          createdAt: DateTime(2026, 4, 1, 8),
          updatedAt: DateTime(2026, 4, 1, 8),
          icon: 'flame',
          displayOrder: 1,
        ),
      ];

      await tester.pumpWidget(
        _buildApp(
          ConstellationSwitcherSheet(
            starnyxs: starnyxs,
            activeStarnyxId: 'habit-1',
            onSelectPressed: (_) {},
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 200));

      // Each habit symbol renders in its accent color.
      expect(
        _findIcon(HabitSymbols.iconFor('star')),
        findsOneWidget,
      );
      expect(
        _findIcon(HabitSymbols.iconFor('flame')),
        findsOneWidget,
      );

      // Each habit title is still present.
      expect(find.text('Hydrate'), findsOneWidget);
      expect(find.text('Read'), findsOneWidget);
    },
  );
}
