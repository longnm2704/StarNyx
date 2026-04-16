import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:starnyx/core/constants/core_constants.dart';

class HomeYearSummaryRow extends StatelessWidget {
  const HomeYearSummaryRow({
    required this.viewedYear,
    required this.daysLeft,
    required this.accentColor,
    required this.onPreviousYearPressed,
    required this.onNextYearPressed,
    required this.onJumpToTodayPressed,
    super.key,
  });

  final int viewedYear;
  final int daysLeft;
  final Color accentColor;
  final VoidCallback? onPreviousYearPressed;
  final VoidCallback? onNextYearPressed;
  final VoidCallback? onJumpToTodayPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: <Widget>[
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _YearChevronButton(
                  buttonKey: const Key('home-previous-year-button'),
                  icon: Icons.chevron_left_rounded,
                  onPressed: onPreviousYearPressed,
                ),
                Flexible(
                  child: Text(
                    viewedYear.toString(),
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _YearChevronButton(
                  buttonKey: const Key('home-next-year-button'),
                  icon: Icons.chevron_right_rounded,
                  onPressed: onNextYearPressed,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: GestureDetector(
              key: const Key('home-jump-today-button'),
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
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Text.rich(
              textAlign: TextAlign.right,
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
          ),
        ),
      ],
    );
  }
}

class _YearChevronButton extends StatelessWidget {
  static const double _buttonSize = 36;

  const _YearChevronButton({
    required this.buttonKey,
    required this.icon,
    required this.onPressed,
  });

  final Key buttonKey;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.textPrimary.withValues(
      alpha: onPressed == null ? 0.3 : 0.6,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: buttonKey,
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: SizedBox(
          width: _buttonSize,
          height: _buttonSize,
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}
