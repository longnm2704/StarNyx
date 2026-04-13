import 'package:flutter/material.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/core/widgets/core_widgets.dart';

class HomeLoadingView extends StatelessWidget {
  const HomeLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const CosmicBackground(
      child: Center(
        child: CircularProgressIndicator(color: AppColors.accentPink),
      ),
    );
  }
}
