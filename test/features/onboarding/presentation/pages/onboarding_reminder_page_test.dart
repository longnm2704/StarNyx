import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starnyx/app/theme/app_theme.dart';
import 'package:starnyx/features/onboarding/domain/create_onboarding_habits.dart';
import 'package:starnyx/features/onboarding/domain/onboarding_template.dart';
import 'package:starnyx/features/onboarding/presentation/pages/onboarding_reminder_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<List<OnboardingHabitDraft>> started;
  late int skipped;
  late bool failStart;

  final templates = <OnboardingTemplate>[
    onboardingTemplates.firstWhere((t) => t.id == 'water'),
    onboardingTemplates.firstWhere((t) => t.id == 'sleep'),
  ];

  setUp(() async {
    rootBundle.clear();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();
    started = <List<OnboardingHabitDraft>>[];
    skipped = 0;
    failStart = false;
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
            home: OnboardingReminderPage(
              templates: templates,
              onBack: () {},
              onSkip: () => skipped++,
              onStart: (drafts) async {
                if (failStart) throw StateError('boom');
                started.add(drafts);
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('renders one row per template with its default time', (
    tester,
  ) async {
    await render(tester);

    expect(find.text('STEP 3/3'), findsOneWidget);
    expect(find.text('2 HABITS SELECTED'), findsOneWidget);
    expect(find.text('Reminder: 06:30 Morning'), findsOneWidget);
    expect(find.text('Reminder: 22:15 Evening'), findsOneWidget);
  });

  testWidgets('shared time can be nudged and applied to all', (tester) async {
    await render(tester);

    await tapVisible(tester, find.byKey(const Key('onboarding-shared-later')));
    expect(find.text('21:45'), findsOneWidget);
    await tapVisible(tester, find.byKey(const Key('onboarding-shared-apply')));

    expect(find.text('Reminder: 21:45 Evening'), findsNWidgets(2));
  });

  testWidgets('editing a row time opens the picker and updates the row', (
    tester,
  ) async {
    await render(tester);

    await tapVisible(
      tester,
      find.byKey(const Key('onboarding-reminder-edit-water')),
    );
    expect(find.byType(CupertinoDatePicker), findsOneWidget);
    // Scroll the hour wheel down a few rows.
    await tester.drag(
      find.byType(CupertinoPicker).first,
      const Offset(0, -100),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('Reminder: 06:30 Morning'), findsNothing);
    expect(find.text('Reminder: 22:15 Evening'), findsOneWidget);
  });

  testWidgets('continue hands localized drafts with edited times', (
    tester,
  ) async {
    await render(tester);

    await tapVisible(tester, find.byKey(const Key('onboarding-shared-later')));
    await tapVisible(tester, find.byKey(const Key('onboarding-shared-apply')));
    await tapVisible(
      tester,
      find.byKey(const Key('onboarding-reminder-start')),
    );

    expect(started, hasLength(1));
    final drafts = started.single;
    expect(drafts.map((d) => d.title), <String>[
      'Drink 500ml of warm water',
      'Sleep before 23:00',
    ]);
    expect(drafts.map((d) => d.reminderTime), <String>['21:45', '21:45']);
    expect(drafts.map((d) => d.icon), <String>['droplet', 'moon']);
  });

  testWidgets('a failed start shows an error', (tester) async {
    failStart = true;
    await render(tester);

    await tapVisible(
      tester,
      find.byKey(const Key('onboarding-reminder-start')),
    );

    expect(
      find.text(
        'Could not create your habits. Nothing was saved, please try again.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('skip leaves onboarding', (tester) async {
    await render(tester);

    await tester.tap(find.byKey(const Key('onboarding-skip')));
    expect(skipped, 1);
    expect(started, isEmpty);
  });

  testWidgets('fits 320px at 2.0 text scale', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await render(tester, textScale: 2);
    await tester.drag(find.byType(ListView), const Offset(0, -2000));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
