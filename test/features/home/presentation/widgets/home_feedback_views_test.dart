import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:starnyx/features/home/presentation/widgets/returning_placeholder_view.dart';

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
          ReturningPlaceholderView(
            starnyxs: starnyxs,
            onCreatePressed: () {
              createPressed = true;
            },
            onEditPressed: (starnyx) {
              edited = starnyx;
            },
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Saved Constellations'), findsOneWidget);
      expect(find.text('Hydrate'), findsOneWidget);
      expect(find.text('Stretch'), findsOneWidget);
      expect(find.text('No description yet'), findsOneWidget);
      expect(find.text('Reminder: 09:15'), findsOneWidget);
      expect(find.text('Reminder off'), findsOneWidget);

      await tester.tap(find.text('New'));
      await tester.pump();
      expect(createPressed, isTrue);

      await tester.ensureVisible(find.text('Edit').last);
      await tester.pump();
      await tester.tap(find.text('Edit').last);
      await tester.pump();
      expect(edited, starnyxs[1]);
    },
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
