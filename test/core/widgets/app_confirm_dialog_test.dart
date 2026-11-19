import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/core/widgets/app_confirm_dialog.dart';

void main() {
  bool? result;

  Future<void> openDialog(
    WidgetTester tester, {
    bool disableAnimations = false,
  }) async {
    result = null;
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: disableAnimations),
          child: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await showAppConfirmDialog(
                  context: context,
                  title: 'Delete this habit?',
                  message: 'Gone for good.',
                  cancelLabel: 'Cancel',
                  confirmLabel: 'Delete',
                  actionStyle: AppConfirmActionStyle.destructive,
                  subject: const Text('Gym'),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
  }

  testWidgets('confirm resolves true', (tester) async {
    await openDialog(tester);
    await tester.pumpAndSettle();

    expect(find.text('Delete this habit?'), findsOneWidget);
    expect(find.text('Gym'), findsOneWidget);

    await tester.tap(find.byKey(const Key('app-confirm-confirm')));
    await tester.pumpAndSettle();

    expect(find.text('Delete this habit?'), findsNothing);
    expect(result, isTrue);
  });

  testWidgets('cancel resolves false', (tester) async {
    await openDialog(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('app-confirm-cancel')));
    await tester.pumpAndSettle();

    expect(find.text('Delete this habit?'), findsNothing);
    expect(result, isFalse);
  });

  testWidgets('reduced motion shows the dialog without a transition', (
    tester,
  ) async {
    await openDialog(tester, disableAnimations: true);
    await tester.pump();
    await tester.pump();

    final scale = tester.widget<ScaleTransition>(
      find.ancestor(
        of: find.byType(AppConfirmDialog),
        matching: find.byType(ScaleTransition),
      ),
    );
    expect(scale.scale.value, 1);
  });
}
