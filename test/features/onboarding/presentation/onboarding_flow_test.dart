import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starnyx/app/theme/app_theme.dart';
import 'package:starnyx/features/onboarding/presentation/onboarding_flow.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late int finished;

  setUp(() async {
    rootBundle.clear();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();
    finished = 0;
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
            home: OnboardingFlow(onFinished: () => finished++),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(finder, 200);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('renders the welcome screen', (tester) async {
    await render(tester);

    expect(
      find.text('Begin your journey.', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('• DAILY DISCIPLINE'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('100% private'), 200);
    expect(find.text('Offline privacy'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Restore data'), 200);
  });

  testWidgets('demo card lights up on tap', (tester) async {
    await render(tester);

    await tapVisible(tester, find.byKey(const Key('onboarding-demo')));
    expect(find.text('Lit for today'), findsOneWidget);

    await tester.tap(find.byKey(const Key('onboarding-demo')));
    await tester.pumpAndSettle();
    expect(find.text('Tap to feel what done is like'), findsOneWidget);
  });

  testWidgets('CTA opens the template picker and back returns', (tester) async {
    await render(tester);

    await tapVisible(tester, find.byKey(const Key('onboarding-start')));
    expect(find.text('Start simple'), findsOneWidget);
    expect(finished, 0);

    await tester.tap(find.byKey(const Key('onboarding-back')));
    await tester.pumpAndSettle();
    expect(find.text('Start simple'), findsNothing);
    expect(find.byKey(const Key('onboarding-start')), findsOneWidget);
  });

  testWidgets('skip finishes onboarding from welcome and picker', (
    tester,
  ) async {
    await render(tester);

    await tester.tap(find.byKey(const Key('onboarding-skip')));
    expect(finished, 1);

    await tapVisible(tester, find.byKey(const Key('onboarding-start')));
    await tester.tap(find.byKey(const Key('onboarding-skip')));
    expect(finished, 2);
  });

  testWidgets('fits 320px at 2.0 text scale', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await render(tester, textScale: 2);
    await tapVisible(tester, find.byKey(const Key('onboarding-start')));

    expect(find.text('Start simple'), findsOneWidget);
  });
}
