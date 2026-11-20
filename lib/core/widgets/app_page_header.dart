import 'package:flutter/material.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:starnyx/core/constants/core_constants.dart';

import 'app_icon.dart';

/// Back arrow + headline title for pushed pages (backup, about, journal
/// detail/editor, habit list). [trailing] holds actions such as Save;
/// [centerTitle] balances the back button so the title sits centered.
class AppPageHeader extends StatelessWidget {
  const AppPageHeader({
    required this.title,
    required this.onBack,
    super.key,
    this.backKey,
    this.backTooltip,
    this.subtitle,
    this.trailing,
    this.centerTitle = false,
  });

  final String title;
  final VoidCallback onBack;
  final Key? backKey;
  final String? backTooltip;
  final String? subtitle;
  final Widget? trailing;
  final bool centerTitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final align = centerTitle ? TextAlign.center : TextAlign.start;
    return Row(
      children: <Widget>[
        IconButton(
          key: backKey,
          tooltip:
              backTooltip ??
              MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: onBack,
          icon: const AppIcon(
            icon: HugeIconsStrokeRounded.strokeRoundedArrowLeft01,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Column(
            crossAxisAlignment: centerTitle
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: align,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontFamily: AppFonts.headline,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (subtitle != null) ...<Widget>[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  textAlign: align,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null)
          trailing!
        else if (centerTitle)
          // Mirrors the back button + gap so the title stays centered.
          const SizedBox(width: kMinInteractiveDimension + AppSpacing.xs),
      ],
    );
  }
}
