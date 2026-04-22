import 'package:flutter/material.dart';
import 'package:starnyx/core/widgets/core_widgets.dart';
import 'package:starnyx/core/constants/core_constants.dart';

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
              fontWeight: FontWeight.w800,
              letterSpacing: -0.35,
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
        color: AppColors.surfaceMuted.withValues(alpha: 0.92),
        border: Border.all(color: AppColors.outlineSoft.withValues(alpha: 0.4)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.22),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
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
