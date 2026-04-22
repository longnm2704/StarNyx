import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/features/home/presentation/widgets/home_loading_view.dart';

void main() {
  testWidgets('home loading view shows a circular spinner', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: HomeLoadingView())),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(_findLegacyLoadingStarImage(), findsNothing);

    final progress = tester.widget<CircularProgressIndicator>(
      find.byType(CircularProgressIndicator),
    );
    expect(progress.strokeWidth, 3);
    expect(progress.color, AppColors.accentLavender);
    expect(progress.backgroundColor, AppColors.outline);
  });
}

Finder _findLegacyLoadingStarImage() {
  return find.byWidgetPredicate((Widget widget) {
    if (widget is! Image) {
      return false;
    }

    final image = widget.image;
    return image is AssetImage &&
        image.assetName == 'assets/icons/ic_star.png' &&
        <double>{24, 30, 48}.contains(widget.width) &&
        <double>{24, 30, 48}.contains(widget.height);
  });
}
