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
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Color.lerp(accentColor, AppColors.black, 0.82),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.22),
                  ),
                ),
                child: Text(
                  selectedDateLabel,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: accentColor.withValues(alpha: 0.58),
                    fontWeight: FontWeight.w700,
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
    return IconButton(
      key: buttonKey,
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: AppColors.textPrimary.withValues(
          alpha: onPressed == null ? 0.3 : 0.6,
        ),
        size: 26,
      ),
    );
  }
}
