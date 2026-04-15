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

      await tester.pumpWidget(
        _buildLocalizedApp(
          ActiveStarnyxHomeView(
            starnyxs: starnyxs,
            activeStarnyxId: '1',
            selectedDate: DateTime(2025, 12, 31),
            todayDate: DateTime(2026, 4, 19),
            viewedYear: 2025,
            completedDatesForViewedYear: <DateTime>[
              DateTime(2025, 12, 30),
            ],
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
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Hydrate'), findsOneWidget);
      expect(find.text('Drink water'), findsOneWidget);
      expect(find.text('Swipe up'), findsOneWidget);
      expect(find.text('2025'), findsOneWidget);
      expect(find.text('Reset to current date'), findsOneWidget);
      expect(
        find.byKey(const Key('home-star-grid-placeholder')),
        findsOneWidget,
      );

      await tester.tap(find.text('Swipe up'));
      await tester.pump(const Duration(milliseconds: 220));
      await tester.pump(const Duration(milliseconds: 220));
      await tester.pump(const Duration(milliseconds: 220));

      expect(find.text('Observation Deck'), findsOneWidget);
      expect(find.text('Manage'), findsOneWidget);
      expect(find.text('StarNyx Plus'), findsOneWidget);
      expect(find.text('Constellations'), findsOneWidget);
      expect(find.text('(Tap Edit to reorder)'), findsOneWidget);
      expect(find.text('Stretch'), findsOneWidget);
      expect(_findSvg('assets/icons/ic_settings.svg'), findsOneWidget);
      expect(_findSvg('assets/icons/ic_book.svg'), findsOneWidget);
      expect(_findSvg('assets/icons/ic_plus.svg'), findsOneWidget);

      await tester.tap(_findSvg('assets/icons/ic_settings.svg'));
      await tester.pump();
      expect(edited, isNull);
      expect(find.text('Observation Deck'), findsOneWidget);

      await tester.tap(find.text('Edit'));
      await tester.pump();
      expect(find.text('Done'), findsOneWidget);
      expect(find.text('1'), findsWidgets);
      expect(find.text('2'), findsWidgets);

      await tester.tap(find.text('Done'));
      await tester.pump();
      expect(find.text('Edit'), findsOneWidget);

      await tester.tap(_findSvg('assets/icons/ic_plus.svg'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 220));
      await tester.pump(const Duration(milliseconds: 220));
      await tester.pump(const Duration(milliseconds: 220));
      expect(createPressed, isTrue);
      createPressed = false;
      expect(find.text('Observation Deck'), findsOneWidget);

      await tester.ensureVisible(find.text('Stretch'));
      await tester.pump();
      await tester.tap(find.text('Stretch'));
      await tester.pump();
      expect(edited, starnyxs[1]);
      edited = null;

      await tester.tap(find.text('Swipe up'));
      await tester.pump(const Duration(milliseconds: 220));
      await tester.pump(const Duration(milliseconds: 220));
      await tester.pump(const Duration(milliseconds: 220));

      await tester.ensureVisible(_findSvg('assets/icons/ic_edit.svg').last);
      await tester.pump();
      await tester.tap(_findSvg('assets/icons/ic_edit.svg').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 220));
      await tester.pump(const Duration(milliseconds: 220));
      await tester.pump(const Duration(milliseconds: 220));
      expect(edited, starnyxs[1]);
      edited = null;
      expect(find.text('Observation Deck'), findsOneWidget);
    },
  );
}

Finder _findSvg(String assetPath) {
  return find.byWidgetPredicate(
    (Widget widget) => widget is AppSvgIcon && widget.assetPath == assetPath,
  );
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
