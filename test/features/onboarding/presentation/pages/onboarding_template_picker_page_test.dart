import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starnyx/app/theme/app_theme.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/core/widgets/core_widgets.dart';
import 'package:starnyx/features/onboarding/domain/onboarding_template.dart';
import 'package:starnyx/features/onboarding/presentation/pages/onboarding_template_picker_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<List<OnboardingTemplate>> continued;
  late int skipped;
  late int custom;

  setUp(() async {
    rootBundle.clear();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();
    continued = <List<OnboardingTemplate>>[];
    skipped = 0;
    custom = 0;
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
            home: OnboardingTemplatePickerPage(
              onBack: () {},
              onSkip: () => skipped++,
              onCreateCustom: () => custom++,
              onContinue: continued.add,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  AppPrimaryButton continueButton(WidgetTester tester) =>
      tester.widget(find.byKey(const Key('onboarding-continue')));

  Future<void> tapTemplate(WidgetTester tester, String id) async {
    final card = find.byKey(Key('onboarding-template-$id'));
    await tester.scrollUntilVisible(card, 200, scrollable: _list);
    await tester.pumpAndSettle();
    await tester.ensureVisible(card);
    await tester.pumpAndSettle();
    await tester.tap(card);
    await tester.pumpAndSettle();
  }

  test('templates map to real symbols and preset colors', () {
    expect(onboardingTemplates.length, greaterThanOrEqualTo(5));
    for (final template in onboardingTemplates) {
      expect(HabitSymbols.icons.containsKey(template.symbol), isTrue);
      expect(AppColors.starnyxPresetColorHexes, contains(template.colorHex));
      expect(template.reminderTime, matches(RegExp(r'^\d{2}:\d{2}$')));
    }
  });

  testWidgets('continue is disabled with nothing selected', (tester) async {
    await render(tester);

    expect(find.text('Start simple'), findsOneWidget);
    expect(find.text('SELECTED: 0 / 3 HABITS'), findsOneWidget);
    expect(continueButton(tester).onPressed, isNull);
  });

  testWidgets('select and deselect updates count and continue', (tester) async {
    await render(tester);

    await tapTemplate(tester, 'water');
    expect(find.text('SELECTED: 1 / 3 HABITS'), findsOneWidget);
    expect(continueButton(tester).onPressed, isNotNull);

    await tapTemplate(tester, 'sleep');
    expect(find.text('Continue setup (2) →'), findsOneWidget);

    await tapTemplate(tester, 'sleep');
    expect(find.text('SELECTED: 1 / 3 HABITS'), findsOneWidget);

    continueButton(tester).onPressed!();
    expect(continued.single.map((t) => t.id), <String>['water']);
  });

  testWidgets('a fourth pick shows a snackbar and is not selected', (
    tester,
  ) async {
    await render(tester);

    for (final id in <String>['water', 'sleep', 'reading', 'move']) {
      await tapTemplate(tester, id);
    }

    expect(find.text('SELECTED: 3 / 3 HABITS'), findsOneWidget);
    expect(
      find.text('You can pick up to 3 habits. Deselect one to swap.'),
      findsOneWidget,
    );
  });

  testWidgets('category chips filter the list', (tester) async {
    await render(tester);

    await tester.tap(find.byKey(const Key('onboarding-category-mind')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('onboarding-template-reading')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('onboarding-template-water')), findsNothing);
  });

  testWidgets('skip and create-your-own fire their callbacks', (tester) async {
    await render(tester);

    await tester.tap(find.byKey(const Key('onboarding-skip')));
    final customRow = find.byKey(const Key('onboarding-create-custom'));
    await tester.scrollUntilVisible(customRow, 200, scrollable: _list);
    await tester.pumpAndSettle();
    await tester.tap(customRow);

    expect(skipped, 1);
    expect(custom, 1);
  });

  testWidgets('fits 320px at 2.0 text scale', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await render(tester, textScale: 2);
    await tapTemplate(tester, 'water');

    expect(tester.takeException(), isNull);
  });
}

final _list = find
    .descendant(of: find.byType(ListView), matching: find.byType(Scrollable))
    .first;
