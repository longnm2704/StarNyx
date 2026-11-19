import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starnyx/app/router/app_router.dart';
import 'package:starnyx/app/shell/app_shell.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('tabs switch screens, keep state, and back returns to Habits', (
    tester,
  ) async {
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    expect(find.text('habits-screen'), findsOneWidget);
    expect(find.text('overview-screen'), findsNothing);
    expect(find.text('journal-screen'), findsNothing);
    expect(find.text('settings-screen'), findsNothing);

    await tester.tap(find.byKey(const Key('bottom-nav-overview')));
    await tester.pumpAndSettle();
    expect(find.text('overview-screen'), findsOneWidget);
    expect(find.text('habits-screen'), findsNothing);

    await tester.tap(find.byKey(const Key('overview-increment')));
    await tester.pump();
    expect(find.text('overview-count-1'), findsOneWidget);

    await tester.tap(find.byKey(const Key('bottom-nav-journal')));
    await tester.pumpAndSettle();
    expect(find.text('journal-screen'), findsOneWidget);
    expect(find.text('overview-screen'), findsNothing);

    await tester.tap(find.byKey(const Key('bottom-nav-overview')));
    await tester.pumpAndSettle();
    expect(find.text('overview-count-1'), findsOneWidget);

    await tester.tap(find.byKey(const Key('bottom-nav-settings')));
    await tester.pumpAndSettle();
    expect(find.text('settings-screen'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('habits-screen'), findsOneWidget);
    expect(find.text('settings-screen'), findsNothing);

    await tester.tap(find.byKey(const Key('bottom-nav-journal')));
    await tester.pumpAndSettle();
    expect(find.text('journal-screen'), findsOneWidget);

    await tester.tap(find.byKey(const Key('bottom-nav-habits')));
    await tester.pumpAndSettle();
    expect(find.text('habits-screen'), findsOneWidget);
  });

  test('deep-link routes resolve to the matching initial tab', () {
    expect(AppRoutes.tabForRoute('/habits'), AppShellTab.habits);
    expect(AppRoutes.tabForRoute('/overview'), AppShellTab.overview);
    expect(AppRoutes.tabForRoute('/journal'), AppShellTab.journal);
    expect(AppRoutes.tabForRoute('/settings'), AppShellTab.settings);
    expect(AppRoutes.tabForRoute('/unknown'), AppShellTab.habits);
    expect(AppRoutes.tabForRoute(null), AppShellTab.habits);
  });
}

Widget _buildApp() {
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
          home: AppShell(
            tabs: <Widget>[
              const _LabelTab(label: 'habits-screen'),
              const _CounterTab(),
              const _LabelTab(label: 'journal-screen'),
              const _LabelTab(label: 'settings-screen'),
            ],
          ),
        );
      },
    ),
  );
}

class _LabelTab extends StatelessWidget {
  const _LabelTab({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(label));
  }
}

class _CounterTab extends StatefulWidget {
  const _CounterTab();

  @override
  State<_CounterTab> createState() => _CounterTabState();
}

class _CounterTabState extends State<_CounterTab> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('overview-count-$_count'),
          TextButton(
            key: const Key('overview-increment'),
            onPressed: () => setState(() => _count++),
            child: const Text('overview-screen'),
          ),
        ],
      ),
    );
  }
}
