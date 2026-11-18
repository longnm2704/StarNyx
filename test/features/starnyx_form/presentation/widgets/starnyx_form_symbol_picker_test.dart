import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/core/widgets/app_icon.dart';
import 'package:starnyx/features/starnyx_form/presentation/widgets/starnyx_form_symbol_picker.dart';

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets(
    'renders symbol picker, catalog symbols, and selected symbol preview',
    (WidgetTester tester) async {
      // ── Render star symbol picker ──
      await tester.pumpWidget(
        _buildLocalizedApp(
          StarnyxFormSymbolPicker(
            selectedSymbol: 'star',
            color: Colors.amber,
            onSymbolSelected: (String _) {},
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(StarnyxFormSymbolPicker), findsOneWidget);
      expect(find.text('Symbol'), findsOneWidget);
      expect(find.text('Preview'), findsOneWidget);

      // ── Catalog symbols render in grid ──
      expect(_findIcon(HabitSymbols.iconFor('clover')), findsWidgets);
      expect(_findIcon(HabitSymbols.iconFor('flame')), findsWidgets);
      expect(_findIcon(HabitSymbols.iconFor('heart')), findsWidgets);

      // ── Replace with flame picker; preview renders flame ──
      await tester.pumpWidget(
        _buildLocalizedApp(
          StarnyxFormSymbolPicker(
            selectedSymbol: 'flame',
            color: Colors.amber,
            onSymbolSelected: (String _) {},
          ),
        ),
      );
      await tester.pump();

      expect(_findIcon(HabitSymbols.iconFor('flame')), findsWidgets);
    },
  );
}
