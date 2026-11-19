import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/core/widgets/app_icon.dart';

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
        final textScale = MediaQuery.textScalerOf(context).scale(12) / 12;
        final isCompact = constraints.maxWidth < 340 || textScale > 1.35;

        if (isCompact) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Center(child: yearControl),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xxs,
                children: <Widget>[jumpToTodayButton, daysLeftLabel],
              ),
            ],
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageHorizontal,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: yearControl,
                ),
              ),
              jumpToTodayButton,
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: daysLeftLabel,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildYearControl(ThemeData theme) {
    final yearStyle = theme.textTheme.labelMedium?.copyWith(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.8,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _YearChevronButton(
          buttonKey: const Key('home-previous-year-button'),
          icon: HugeIconsStrokeRounded.strokeRoundedChevronLeft,
          onPressed: onPreviousYearPressed,
        ),
        SizedBox(
          width: 48,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                key: const Key('home-viewed-year-label'),
                viewedYear.toString(),
                maxLines: 1,
                style: yearStyle,
              ),
            ),
          ),
        ),
        _YearChevronButton(
          buttonKey: const Key('home-next-year-button'),
          icon: HugeIconsStrokeRounded.strokeRoundedChevronRight,
          onPressed: onNextYearPressed,
        ),
      ],
    );
  }

  Widget _buildJumpToTodayButton(ThemeData theme) {
    return InkWell(
      key: const Key('home-jump-today-button'),
      onTap: onJumpToTodayPressed,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs + 2,
        ),
        child: Text(
          'home.reset_current_date'.tr(),
          style: theme.textTheme.labelMedium?.copyWith(
            color: accentColor,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }

  Widget _buildDaysLeftLabel(ThemeData theme) {
    final numberStyle = theme.textTheme.labelMedium?.copyWith(
      color: accentColor,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.4,
    );
    final suffixStyle = theme.textTheme.labelMedium?.copyWith(
      color: AppColors.textPrimary.withValues(alpha: 0.78),
      fontWeight: FontWeight.w500,
      letterSpacing: 0.2,
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceLevel1.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerRight,
        child: Text.rich(
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          TextSpan(
            children: <TextSpan>[
              TextSpan(text: '$daysLeft ', style: numberStyle),
              TextSpan(text: 'home.days_left_suffix'.tr(), style: suffixStyle),
            ],
          ),
        ),
      ),
    );
  }
}

class _YearChevronButton extends StatelessWidget {
  static const double _buttonSize = 28;

  const _YearChevronButton({
    required this.buttonKey,
    required this.icon,
    required this.onPressed,
  });

  final Key buttonKey;
  final List<List<dynamic>> icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.textSecondary.withValues(
      alpha: onPressed == null ? 0.3 : 1,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: buttonKey,
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: _buttonSize,
          height: _buttonSize,
          child: AppIcon(icon: icon, size: 20, color: color),
        ),
      ),
    );
  }
}
