import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starnyx/features/starnyx_form/presentation/widgets/starnyx_form_symbol_picker.dart';

Widget _buildLocalizedApp(Widget child) {
  return EasyLocalization(
    supportedLocales: const <Locale>[Locale('en')],
    fallbackLocale: const Locale('en'),
    path: 'assets/translations',
    useOnlyLangCode: true,
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
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('renders the symbol picker with label and preview',
      (WidgetTester tester) async {
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
  });
}
