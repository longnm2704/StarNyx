import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starnyx/features/home/presentation/widgets/home_year_summary_row.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('year controls keep the full year visible on narrow widths', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildLocalizedApp(
        Center(
          child: SizedBox(
            width: 280,
            child: HomeYearSummaryRow(
              viewedYear: 2026,
              daysLeft: 257,
              accentColor: const Color(0xFFDE7B30),
              onPreviousYearPressed: () {},
              onNextYearPressed: () {},
              onJumpToTodayPressed: () {},
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('home-viewed-year-label')), findsOneWidget);
    expect(find.text('2026'), findsOneWidget);
    expect(find.text('257 days left'), findsOneWidget);
  });
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
