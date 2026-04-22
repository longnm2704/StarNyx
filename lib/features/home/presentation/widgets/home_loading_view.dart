import 'package:flutter/material.dart';
import 'package:starnyx/core/widgets/core_widgets.dart';
import 'package:starnyx/core/constants/core_constants.dart';

class HomeLoadingView extends StatelessWidget {
  const HomeLoadingView({this.accentColor, super.key});

  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    return CosmicBackground(
      accentColor: accentColor,
      child: Center(
        child: SizedBox(
          width: 56,
          height: 56,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: AppColors.accentLavender,
            backgroundColor: AppColors.outline,
          ),
        ),
      ),
    );
  }
}
