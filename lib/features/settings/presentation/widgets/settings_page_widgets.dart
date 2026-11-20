import 'package:flutter/material.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/core/widgets/core_widgets.dart';

/// Back arrow + headline title used by the screens pushed from Settings.
class SettingsBackHeader extends StatelessWidget {
  const SettingsBackHeader({
    required this.title,
    required this.onBack,
    this.backKey,
    super.key,
  });

  final String title;
  final VoidCallback onBack;
  final Key? backKey;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          key: backKey,
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: onBack,
          icon: const AppIcon(
            icon: HugeIconsStrokeRounded.strokeRoundedArrowLeft01,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontFamily: AppFonts.headline,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// Mono uppercase overline above a settings card.
class SettingsSectionLabel extends StatelessWidget {
  const SettingsSectionLabel(this.text, {this.color, this.icon, super.key});

  final String text;
  final Color? color;
  final List<List<dynamic>>? icon;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.textSecondary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxs,
        0,
        AppSpacing.xxs,
        AppSpacing.xs,
      ),
      child: Row(
        children: <Widget>[
          if (icon != null) ...<Widget>[
            AppIcon(icon: icon!, size: 16, color: effectiveColor),
            const SizedBox(width: AppSpacing.xxs),
          ],
          Flexible(
            child: Text(
              text.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontFamily: AppFonts.mono,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.1,
                color: effectiveColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// `#0A0A0C` card with a hairline border and 16px padding.
class SettingsCard extends StatelessWidget {
  const SettingsCard({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceLevel1,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: child,
    );
  }
}
