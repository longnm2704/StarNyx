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
        ? Color.lerp(accentColor, AppColors.sheet, 0.72)!
        : AppColors.surfaceLevel2.withValues(alpha: 0.5);
    final Color bottomColor = canShowActiveState
        ? Color.lerp(accentColor, AppColors.black, 0.88)!
        : AppColors.surfaceLevel2.withValues(alpha: 0.28);
    final iconData = HabitSymbols.iconFor(symbolKey);
    final actionText = isLit
        ? 'home.checkin_lit'.tr()
        : 'home.checkin_light_today'.tr();
    final actionSemantics = isLit
        ? 'home.checkin_lit_semantics'.tr()
        : 'home.checkin_light_today_semantics'.tr();

    return Row(
      children: <Widget>[
        _DayChevronButton(
          icon: HugeIconsStrokeRounded.strokeRoundedChevronLeft,
          buttonKey: const Key('home-previous-day-button'),
          onPressed: onPreviousDayPressed,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              key: const Key('home-selected-date-button'),
              onTap: canTap ? onSelectedDatePressed : null,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: Container(
                height: 52,
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
                        ? accentColor.withValues(alpha: 0.28)
                        : AppColors.borderFocus.withValues(alpha: 0.12),
                  ),
                  boxShadow: <BoxShadow>[
                    if (canShowActiveState)
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.24),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                  ],
                ),
                child: Semantics(
                  label: actionSemantics,
                  button: canTap,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Flexible(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              selectedDateLabel,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: AppColors.textPrimary.withValues(
                                  alpha: canShowActiveState ? 0.88 : 0.34,
                                ),
                                fontWeight: FontWeight.w800,
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
                                  color: AppColors.textPrimary.withValues(
                                    alpha: canShowActiveState ? 0.88 : 0.34,
                                  ),
                                  size: 16,
                                  strokeWidth: 2,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    actionText,
                                    style: theme.textTheme.bodySmall
                                        ?.copyWith(
                                      color: AppColors.textPrimary.withValues(
                                        alpha:
                                            canShowActiveState ? 0.88 : 0.34,
                                      ),
                                      fontWeight: FontWeight.w700,
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
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
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
            color: AppColors.surfaceLevel2.withValues(
              alpha: onPressed == null ? 0.28 : 0.58,
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.borderFocus.withValues(
                alpha: onPressed == null ? 0.08 : 0.18,
              ),
            ),
          ),
          child: AppIcon(icon: icon, color: foreground, size: 24),
        ),
      ),
    );
  }
}
