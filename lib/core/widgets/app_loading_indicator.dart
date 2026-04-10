import 'package:flutter/material.dart';
import 'package:starnyx/core/constants/core_constants.dart';

class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({super.key, this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const CircularProgressIndicator(),
          if (label != null) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            Text(label!),
          ],
        ],
      ),
    );
  }
}
