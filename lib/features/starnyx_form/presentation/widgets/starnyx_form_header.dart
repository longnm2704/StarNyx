import 'package:flutter/material.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/core/widgets/core_widgets.dart';

class StarnyxFormHeader extends StatelessWidget {
  const StarnyxFormHeader({
    required this.title,
    required this.onClosePressed,
    super.key,
  });

  final String title;
  final VoidCallback onClosePressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: _CloseButton(onPressed: onClosePressed),
          ),
          Text(
            title,
            style: textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.accentViolet.withValues(alpha: 0.18),
        border: Border.all(
          color: AppColors.accentViolet.withValues(alpha: 0.7),
        ),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: const AppSvgIcon(
          assetPath: 'assets/icons/ic_close.svg',
          size: 18,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
