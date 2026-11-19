import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starnyx/app/theme/app_theme.dart';
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:starnyx/features/onboarding/presentation/pages/onboarding_complete_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late int done;
  late int back;

  final habits = <StarNyx>[
    StarNyx(
      id: 'a',
      title: 'Drink water',
      description: 'Every morning',
      color: '#10B981',
      icon: 'droplet',
      startDate: DateTime(2026, 11, 19),
      reminderEnabled: true,
      reminderTime: '06:30',
      createdAt: DateTime(2026, 11, 19),
      updatedAt: DateTime(2026, 11, 19),
    ),
    StarNyx(
      id: 'b',
      title: 'Sleep early',
      description: null,
      color: '#FFB95F',
      icon: 'moon',
      startDate: DateTime(2026, 11, 19),
      reminderEnabled: true,
      reminderTime: '22:15',
      createdAt: DateTime(2026, 11, 19),
      updatedAt: DateTime(2026, 11, 19),
    ),
  ];

  setUp(() async {
    rootBundle.clear();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();
    done = 0;
    back = 0;
  });

  Future<void> render(WidgetTester tester, {double textScale = 1}) async {
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const <Locale>[Locale('en')],
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        path: 'assets/translations',
        useOnlyLangCode: true,
        child: Builder(
          builder: (context) => MaterialApp(
            theme: AppTheme.dark(),
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(textScale)),
              child: child!,
            ),
            home: OnboardingCompletePage(
              habits: habits,
              onBack: () => back++,
              onDone: () => done++,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders the created habits', (tester) async {
    await render(tester);

    expect(find.text('ALL SET · READY TO BEGIN'), findsOneWidget);
    expect(find.text('Ready to begin.', findRichText: true), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Sleep early'), 200);
    expect(find.text('Drink water'), findsOneWidget);
    expect(find.text('06:30 · Daily · Every morning'), findsOneWidget);
    expect(find.text('22:15 · Daily'), findsOneWidget);
  });

  testWidgets('CTA finishes and back returns', (tester) async {
    await render(tester);

    final cta = find.byKey(const Key('onboarding-complete-done'));
    await tester.scrollUntilVisible(cta, 200);
    await tester.pumpAndSettle();
    await tester.tap(cta);
    expect(done, 1);

    await tester.scrollUntilVisible(
      find.byKey(const Key('onboarding-back')),
      -200,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('onboarding-back')));
    expect(back, 1);
  });

  testWidgets('fits 320px at 2.0 text scale', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await render(tester, textScale: 2);
    await tester.drag(find.byType(ListView), const Offset(0, -3000));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
