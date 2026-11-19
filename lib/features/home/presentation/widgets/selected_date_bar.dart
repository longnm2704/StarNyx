import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/core/widgets/app_icon.dart';
import 'package:starnyx/core/widgets/core_widgets.dart';

class SelectedDateBar extends StatelessWidget {
  const SelectedDateBar({
    required this.selectedDateLabel,
    required this.onPreviousDayPressed,
    required this.onNextDayPressed,
    required this.accentColor,
    required this.symbolKey,
    required this.isLit,
    this.onSelectedDatePressed,
    this.isCheckingIn = false,
    super.key,
  });

  final String selectedDateLabel;
  final VoidCallback? onPreviousDayPressed;
  final VoidCallback? onNextDayPressed;
  final Color accentColor;

  /// Stable habit symbol key (e.g. 'star', 'clover', 'flame').
  final String symbolKey;

  /// Whether the selected date is completed (lit).
  final bool isLit;

  final VoidCallback? onSelectedDatePressed;
  final bool isCheckingIn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool canShowActiveState = onSelectedDatePressed != null;
    final bool canTap = canShowActiveState && !isCheckingIn;
    final Color topColor = canShowActiveState
        ? Color.lerp(AppColors.surfaceLevel2, accentColor, 0.12)!
        : AppColors.surfaceLevel1.withValues(alpha: 0.6);
    final Color bottomColor = canShowActiveState
        ? Color.lerp(AppColors.surfaceLevel1, accentColor, 0.04)!
        : AppColors.surfaceLevel1.withValues(alpha: 0.4);
    final iconData = HabitSymbols.iconFor(symbolKey);
    final actionText = isLit
        ? 'home.checkin_lit'.tr()
        : 'home.checkin_light_today'.tr();
    final actionSemantics = isLit
        ? 'home.checkin_lit_semantics'.tr()
        : 'home.checkin_light_today_semantics'.tr();
    final textOpacity = canShowActiveState ? 1.0 : 0.34;

    return Row(
      children: <Widget>[
        _DayChevronButton(
          icon: HugeIconsStrokeRounded.strokeRoundedChevronLeft,
          buttonKey: const Key('home-previous-day-button'),
          onPressed: onPreviousDayPressed,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              key: const Key('home-selected-date-button'),
              onTap: canTap ? onSelectedDatePressed : null,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: Container(
                constraints: const BoxConstraints(minHeight: 56),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[topColor, bottomColor],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(
                    color: canShowActiveState
                        ? accentColor.withValues(alpha: 0.24)
                        : AppColors.borderSubtle,
                  ),
                  boxShadow: <BoxShadow>[
                    if (canShowActiveState)
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.12),
                        blurRadius: 24,
                        spreadRadius: 1,
                      ),
                  ],
                ),
                child: Semantics(
                  label: actionSemantics,
                  button: canTap,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        selectedDateLabel,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontFamily: AppFonts.headline,
                          color: AppColors.textPrimary.withValues(
                            alpha: textOpacity,
                          ),
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          AppIcon(
                            icon: iconData,
                            color: accentColor.withValues(
                              alpha: canShowActiveState ? 0.92 : 0.34,
                            ),
                            size: 14,
                            strokeWidth: 2,
                          ),
                          const SizedBox(width: AppSpacing.xxs),
                          Flexible(
                            child: Text(
                              actionText,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: accentColor.withValues(
                                  alpha: canShowActiveState ? 0.92 : 0.34,
                                ),
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        _DayChevronButton(
          icon: HugeIconsStrokeRounded.strokeRoundedChevronRight,
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

  final List<List<dynamic>> icon;
  final Key buttonKey;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final foreground = AppColors.textSecondary.withValues(
      alpha: onPressed == null ? 0.3 : 1,
    );

    return Material(
      color: AppColors.surfaceLevel1,
      shape: const CircleBorder(
        side: BorderSide(color: AppColors.borderSubtle),
      ),
      child: InkWell(
        key: buttonKey,
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox.square(
          dimension: 48,
          child: Center(
            child: AppIcon(icon: icon, color: foreground, size: 22),
          ),
        ),
      ),
    );
  }
}
