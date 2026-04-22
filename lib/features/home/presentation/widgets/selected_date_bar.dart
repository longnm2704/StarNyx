import 'package:flutter/material.dart';
import 'package:starnyx/core/constants/core_constants.dart';

class SelectedDateBar extends StatelessWidget {
  const SelectedDateBar({
    required this.selectedDateLabel,
    required this.onPreviousDayPressed,
    required this.onNextDayPressed,
    required this.accentColor,
    this.onSelectedDatePressed,
    this.isCheckingIn = false,
    super.key,
  });

  final String selectedDateLabel;
  final VoidCallback? onPreviousDayPressed;
  final VoidCallback? onNextDayPressed;
  final Color accentColor;
  final VoidCallback? onSelectedDatePressed;
  final bool isCheckingIn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: <Widget>[
        _DayChevronButton(
          icon: Icons.chevron_left_rounded,
          buttonKey: const Key('home-previous-day-button'),
          onPressed: onPreviousDayPressed,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              key: const Key('home-selected-date-button'),
              onTap: isCheckingIn ? null : onSelectedDatePressed,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: Container(
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Color.lerp(accentColor, AppColors.surfaceGlass, 0.72)!,
                      Color.lerp(accentColor, AppColors.black, 0.88)!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.28),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.24),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Text(
                  selectedDateLabel,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary.withValues(alpha: 0.88),
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        _DayChevronButton(
          icon: Icons.chevron_right_rounded,
          buttonKey: const Key('home-next-day-button'),
          onPressed: onNextDayPressed,
        ),
      ],
    );
  }
}

class _DayChevronButton extends StatelessWidget {
  const _DayChevronButton({
    required this.icon,
    required this.buttonKey,
    required this.onPressed,
  });

  final IconData icon;
  final Key buttonKey;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final foreground = AppColors.textPrimary.withValues(
      alpha: onPressed == null ? 0.22 : 0.72,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: buttonKey,
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted.withValues(
              alpha: onPressed == null ? 0.28 : 0.58,
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.outlineSoft.withValues(
                alpha: onPressed == null ? 0.08 : 0.18,
              ),
            ),
          ),
          child: Icon(icon, color: foreground, size: 24),
        ),
      ),
    );
  }
}
