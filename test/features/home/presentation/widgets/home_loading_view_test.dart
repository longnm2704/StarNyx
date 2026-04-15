import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starnyx/features/home/presentation/widgets/home_loading_view.dart';

void main() {
  testWidgets(
    'home loading view shows a three-star cluster instead of a spinner',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: HomeLoadingView())),
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(_findStarImage(), findsNWidgets(3));
    },
  );

  testWidgets('home loading stars drift over time instead of staying fixed', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: HomeLoadingView())),
    );

    final starFinder = _findStarImageBySize(48);
    final before = tester.getCenter(starFinder);

    await tester.pump(const Duration(milliseconds: 700));

    final after = tester.getCenter(starFinder);
    expect(after, isNot(before));
  });
}

Finder _findStarImage() {
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

Finder _findStarImageBySize(double size) {
  return find.byWidgetPredicate((Widget widget) {
    if (widget is! Image) {
      return false;
    }

    final image = widget.image;
    return image is AssetImage &&
        image.assetName == 'assets/icons/ic_star.png' &&
        widget.width == size &&
        widget.height == size;
  });
}
