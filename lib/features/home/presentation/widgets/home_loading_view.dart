import 'package:flutter/material.dart';
import 'package:starnyx/core/widgets/core_widgets.dart';
import 'package:starnyx/core/constants/core_constants.dart';

class HomeLoadingView extends StatelessWidget {
  const HomeLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const CosmicBackground(
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
