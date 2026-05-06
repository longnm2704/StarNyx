import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/features/home/presentation/widgets/home_loading_view.dart';

void main() {
  testWidgets(
    'home loading view renders constellation skeleton with active color',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HomeLoadingView(accentColor: AppColors.accentOrange),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(HomeLoadingView), findsOneWidget);
    },
  );
}
