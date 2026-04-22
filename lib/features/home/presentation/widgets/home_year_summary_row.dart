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
    final yearControl = _buildYearControl(theme);
    final jumpToTodayButton = _buildJumpToTodayButton(theme);
    final daysLeftLabel = _buildDaysLeftLabel(theme);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final isCompact = constraints.maxWidth < 320;

        if (isCompact) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: yearControl,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: daysLeftLabel,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Center(child: jumpToTodayButton),
            ],
          );
        }

        return Row(
          children: <Widget>[
            Expanded(
              child: Align(alignment: Alignment.centerLeft, child: yearControl),
            ),
            const SizedBox(width: AppSpacing.xs),
            Center(child: jumpToTodayButton),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: daysLeftLabel,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildYearControl(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted.withValues(alpha: 0.52),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(
          color: AppColors.outlineSoft.withValues(alpha: 0.16),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _YearChevronButton(
            buttonKey: const Key('home-previous-year-button'),
            icon: Icons.chevron_left_rounded,
            onPressed: onPreviousYearPressed,
          ),
          SizedBox(
            width: 44,
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  key: const Key('home-viewed-year-label'),
                  viewedYear.toString(),
                  maxLines: 1,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary.withValues(alpha: 0.82),
                    fontWeight: FontWeight.w800,
                  ),
                ),
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
    );
  }

  Widget _buildJumpToTodayButton(ThemeData theme) {
    return InkWell(
      key: const Key('home-jump-today-button'),
      onTap: onJumpToTodayPressed,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xxs,
        ),
        child: Text(
          'home.reset_current_date'.tr(),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: accentColor.withValues(alpha: 0.96),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildDaysLeftLabel(ThemeData theme) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerRight,
      child: Text.rich(
        textAlign: TextAlign.right,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        TextSpan(
          children: <TextSpan>[
            TextSpan(
              text: '$daysLeft ',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: accentColor.withValues(alpha: 0.95),
                fontWeight: FontWeight.w800,
              ),
            ),
            TextSpan(
              text: 'home.days_left_suffix'.tr(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary.withValues(alpha: 0.78),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
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
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}
