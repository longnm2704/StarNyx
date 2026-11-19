import 'package:flutter/material.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:starnyx/core/constants/core_constants.dart';

import 'app_icon.dart';

Future<bool?> showAppConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String cancelLabel,
  required String confirmLabel,
  List<List<dynamic>> icon = HugeIconsStrokeRounded.strokeRoundedTrash,
  AppConfirmActionStyle actionStyle = AppConfirmActionStyle.neutral,
  Color? accentColor,
}) {
  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: cancelLabel,
    barrierColor: AppColors.black.withValues(alpha: 0.78),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (_, _, _) {
      return AppConfirmDialog(
        title: title,
        message: message,
        cancelLabel: cancelLabel,
        confirmLabel: confirmLabel,
        icon: icon,
        actionStyle: actionStyle,
        accentColor: accentColor,
      );
    },
    transitionBuilder:
        (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child,
        ) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );

          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
              child: child,
            ),
          );
        },
  );
}

class AppConfirmDialog extends StatelessWidget {
  const AppConfirmDialog({
    required this.title,
    required this.message,
    required this.cancelLabel,
    required this.confirmLabel,
    super.key,
    this.icon = HugeIconsStrokeRounded.strokeRoundedTrash,
    this.actionStyle = AppConfirmActionStyle.neutral,
    this.accentColor,
  });

  final String title;
  final String message;
  final String cancelLabel;
  final String confirmLabel;
  final List<List<dynamic>> icon;
  final AppConfirmActionStyle actionStyle;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveAccentColor = accentColor ?? _defaultAccentColor;

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surfaceLevel2,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: effectiveAccentColor.withValues(alpha: 0.12),
                        border: Border.all(
                          color: effectiveAccentColor.withValues(alpha: 0.36),
                        ),
                      ),
                      child: Center(
                        child: AppIcon(
                          icon: icon,
                          color: effectiveAccentColor,
                          size: 22,
                          semanticsLabel: title,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _AppDialogGhostButton(
                            label: cancelLabel,
                            onPressed: () => Navigator.of(context).pop(false),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _AppDialogActionButton(
                            label: confirmLabel,
                            onPressed: () => Navigator.of(context).pop(true),
                            actionStyle: actionStyle,
                            accentColor: accentColor,
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
    );
  }

  Color get _defaultAccentColor => switch (actionStyle) {
    AppConfirmActionStyle.neutral => AppColors.textPrimary,
    AppConfirmActionStyle.destructive => AppColors.error,
  };
}

class _AppDialogGhostButton extends StatelessWidget {
  const _AppDialogGhostButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: onPressed,
        child: Ink(
          height: AppSize.ctaHeight,
          decoration: BoxDecoration(
            color: AppColors.surfaceLevel1,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppDialogActionButton extends StatelessWidget {
  const _AppDialogActionButton({
    required this.label,
    required this.onPressed,
    required this.actionStyle,
    this.accentColor,
  });

  final String label;
  final VoidCallback onPressed;
  final AppConfirmActionStyle actionStyle;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final fill = accentColor ?? _fillColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: onPressed,
        child: Ink(
          height: AppSize.ctaHeight,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color get _fillColor => switch (actionStyle) {
    AppConfirmActionStyle.neutral => AppColors.white,
    AppConfirmActionStyle.destructive => AppColors.error,
  };
}
