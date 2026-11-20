import 'package:flutter/material.dart';
import 'package:starnyx/core/constants/core_constants.dart';

import 'app_icon.dart';

/// Mono uppercase overline (`labelSmall`, w600, 1.1 tracking) above a card
/// or section. [trailing] is an emerald note on the right.
class AppSectionLabel extends StatelessWidget {
  const AppSectionLabel(
    this.text, {
    super.key,
    this.color = AppColors.textSecondary,
    this.icon,
    this.trailing,
    this.padding = EdgeInsets.zero,
  });

  /// Inset used when the label sits directly above an [AppCard].
  static const aboveCard = EdgeInsets.fromLTRB(
    AppSpacing.xxs,
    0,
    AppSpacing.xxs,
    AppSpacing.xs,
  );

  final String text;
  final Color color;
  final List<List<dynamic>>? icon;
  final String? trailing;
  final EdgeInsetsGeometry padding;

  static TextStyle? style(BuildContext context) =>
      Theme.of(context).textTheme.labelSmall?.copyWith(
        fontFamily: AppFonts.mono,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.1,
        color: AppColors.textSecondary,
      );

  @override
  Widget build(BuildContext context) {
    final overline = style(context);
    final label = Text(
      text.toUpperCase(),
      style: overline?.copyWith(color: color),
    );
    if (icon == null && trailing == null) {
      return Padding(padding: padding, child: label);
    }
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (icon != null) ...<Widget>[
                  AppIcon(icon: icon!, size: 16, color: color),
                  const SizedBox(width: AppSpacing.xxs),
                ],
                Flexible(child: label),
              ],
            ),
          ),
          if (trailing != null) ...<Widget>[
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                trailing!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: overline?.copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
