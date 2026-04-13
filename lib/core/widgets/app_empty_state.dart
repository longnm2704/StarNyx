import 'package:flutter/material.dart';
import 'package:starnyx/core/constants/core_constants.dart';

// Shared empty-state card for screens that have no content yet.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    required this.title,
    required this.message,
    super.key,
    this.icon = Icons.auto_awesome_outlined,
    this.actionLabel,
    this.onActionPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: AppSpacing.xxl, color: colorScheme.primary),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: textTheme.titleLarge, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null && onActionPressed != null) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            FilledButton(onPressed: onActionPressed, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
