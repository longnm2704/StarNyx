import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:starnyx/core/constants/core_constants.dart';

class HomeYearSummaryRow extends StatelessWidget {
  const HomeYearSummaryRow({
    required this.viewedYear,
    required this.daysLeft,
    required this.accentColor,
    required this.onYearPressed,
    required this.onJumpToTodayPressed,
    super.key,
  });

  final int viewedYear;
  final int daysLeft;
  final Color accentColor;
  final VoidCallback? onYearPressed;
  final VoidCallback? onJumpToTodayPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: <Widget>[
        InkWell(
          onTap: onYearPressed,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.chevron_left_rounded,
                  size: 18,
                  color: AppColors.textPrimary.withValues(alpha: 0.6),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  viewedYear.toString(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppColors.textPrimary.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: GestureDetector(
              onTap: onJumpToTodayPressed,
              child: Text(
                'home.reset_current_date'.tr(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: accentColor.withValues(alpha: 0.95),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        Text.rich(
          TextSpan(
            children: <TextSpan>[
              TextSpan(
                text: '$daysLeft ',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: accentColor.withValues(alpha: 0.95),
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(
                text: 'home.days_left_suffix'.tr(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
