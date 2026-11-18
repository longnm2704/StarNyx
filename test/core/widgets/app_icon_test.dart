import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:starnyx/core/widgets/app_icon.dart';

void main() {
  testWidgets('AppIcon renders the given glyph at the requested size',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppIcon(
            icon: HugeIconsStrokeRounded.strokeRoundedStar,
            size: 32,
            color: Colors.amber,
          ),
        ),
      ),
    );

    expect(find.byType(AppIcon), findsOneWidget);
  });

  testWidgets('AppIcon exposes a semantics label when provided',
      (WidgetTester tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppIcon(
            icon: HugeIconsStrokeRounded.strokeRoundedStar,
            semanticsLabel: 'star',
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel('star'), findsOneWidget);
    handle.dispose();
  });

  test('buildSvg bumps stroke width below the small-size threshold', () {
    const icon = HugeIconsStrokeRounded.strokeRoundedStar;
    final small =
        AppIcon.buildSvg(icon, Colors.white, AppIcon.smallStrokeWidth);
    final regular = AppIcon.buildSvg(icon, Colors.white, null);

    expect(small, contains('stroke-width="2.0"'));
    expect(regular, contains('stroke-width="1.5"'));
  });

  test('buildSvg substitutes currentColor with the given color', () {
    const icon = HugeIconsStrokeRounded.strokeRoundedStar;
    final svg = AppIcon.buildSvg(icon, const Color(0xFFFF0000), null);

    expect(svg, contains('#ff0000'));
    expect(svg, isNot(contains('currentColor')));
  });
}
