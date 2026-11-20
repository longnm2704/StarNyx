import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/core/widgets/core_widgets.dart';

// Pieces shared by the onboarding steps 2/3 and 3/3.

/// Back chevron, mono step label and "Skip".
class OnboardingHeader extends StatelessWidget {
  const OnboardingHeader({
    required this.step,
    required this.onBack,
    required this.onSkip,
    this.skipLabel,
    super.key,
  });

  /// Localized step label, e.g. "BƯỚC 2/3".
  final String step;

  /// Null while a step is busy (disables both actions).
  final VoidCallback? onBack;
  final VoidCallback? onSkip;

  /// Defaults to "Skip".
  final String? skipLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            key: const Key('onboarding-back'),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: onBack,
            icon: const AppIcon(
              icon: HugeIconsStrokeRounded.strokeRoundedArrowLeft01,
              color: AppColors.textPrimary,
            ),
          ),
          Expanded(
            child: Text(
              step,
              style: Theme.of(context).textTheme.labelLarge,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Flexible(
            child: TextButton(
              key: const Key('onboarding-skip'),
              onPressed: onSkip,
              child: Text(
                skipLabel ?? 'onboarding.skip'.tr(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Emerald status dot followed by a mono label.
class OnboardingDotLabel extends StatelessWidget {
  const OnboardingDotLabel({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Flexible(child: child),
      ],
    );
  }
}

class OnboardingSymbolTile extends StatelessWidget {
  const OnboardingSymbolTile({
    required this.symbol,
    required this.color,
    super.key,
  });

  final String symbol;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      alignment: Alignment.center,
      child: AppIcon(icon: HabitSymbols.iconFor(symbol), color: color),
    );
  }
}
