import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starnyx/app/theme/app_theme.dart';
import 'package:starnyx/core/constants/core_constants.dart';

void main() {
  testWidgets('AppTheme.dark renders without overflow at 320px', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: const Scaffold(
          body: Center(
            child: Text(
              'StarNyx Obsidian Lumina smoke test with a fairly long line of text',
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  test('AppTheme.dark text theme uses bundled Obsidian Lumina families', () {
    final theme = AppTheme.dark();
    expect(theme.textTheme.headlineLarge?.fontFamily, AppFonts.headline);
    expect(theme.textTheme.headlineMedium?.fontFamily, AppFonts.headline);
    expect(theme.textTheme.headlineSmall?.fontFamily, AppFonts.headline);
    expect(theme.textTheme.titleLarge?.fontFamily, AppFonts.body);
    expect(theme.textTheme.titleMedium?.fontFamily, AppFonts.body);
    expect(theme.textTheme.titleSmall?.fontFamily, AppFonts.body);
    expect(theme.textTheme.displaySmall?.fontFamily, AppFonts.headline);
    expect(theme.textTheme.bodyLarge?.fontFamily, AppFonts.body);
    expect(theme.textTheme.bodyMedium?.fontFamily, AppFonts.body);
    expect(theme.textTheme.bodySmall?.fontFamily, AppFonts.body);
    expect(theme.textTheme.labelLarge?.fontFamily, AppFonts.mono);
    expect(theme.textTheme.labelMedium?.fontFamily, AppFonts.mono);
    expect(theme.textTheme.labelSmall?.fontFamily, AppFonts.mono);
    expect(
      theme.textTheme.labelLarge?.fontFeatures,
      contains(const FontFeature.tabularFigures()),
    );
  });

  testWidgets('AppTheme.dark renders at 2.0 text scale without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2.0)),
          child: child!,
        ),
        home: const Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Headline', style: TextStyle(fontSize: 28)),
                  Text(
                    'Body copy that wraps across multiple lines when scaled up.',
                  ),
                  Text('LABEL 12', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
