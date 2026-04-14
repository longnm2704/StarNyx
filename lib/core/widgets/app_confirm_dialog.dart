import 'package:flutter/material.dart';
import 'package:starnyx/core/constants/core_constants.dart';

import 'app_svg_icon.dart';

const LinearGradient _appConfirmDialogGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: <Color>[Color(0xFF32284B), Color(0xFF1A1526)],
);

enum AppConfirmActionStyle { neutral, destructive }

Future<bool?> showAppConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String cancelLabel,
  required String confirmLabel,
  String iconAssetPath = 'assets/icons/ic_trash.svg',
  AppConfirmActionStyle actionStyle = AppConfirmActionStyle.neutral,
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
        iconAssetPath: iconAssetPath,
        actionStyle: actionStyle,
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
    this.iconAssetPath = 'assets/icons/ic_trash.svg',
    this.actionStyle = AppConfirmActionStyle.neutral,
  });

  final String title;
  final String message;
  final String cancelLabel;
  final String confirmLabel;
  final String iconAssetPath;
  final AppConfirmActionStyle actionStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: _appConfirmDialogGradient,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(
                  color: AppColors.outline.withValues(alpha: 0.58),
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.32),
                    blurRadius: 34,
                    offset: const Offset(0, 20),
                  ),
                  BoxShadow(
                    color: _accentColor.withValues(alpha: 0.12),
                    blurRadius: 28,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _accentColor.withValues(alpha: 0.12),
                        border: Border.all(
                          color: _accentColor.withValues(alpha: 0.36),
                        ),
                      ),
                      child: AppSvgIcon(
                        assetPath: iconAssetPath,
                        color: _iconColor,
                        size: 28,
                        semanticsLabel: title,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
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

  Color get _accentColor => switch (actionStyle) {
    AppConfirmActionStyle.neutral => AppColors.accentLavender,
    AppConfirmActionStyle.destructive => AppColors.accentPink,
  };

  Color get _iconColor => switch (actionStyle) {
    AppConfirmActionStyle.neutral => AppColors.accentLavender,
    AppConfirmActionStyle.destructive => AppColors.accentLavender,
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
            color: AppColors.surface.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: AppColors.outline.withValues(alpha: 0.5)),
          ),
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
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
  });

  final String label;
  final VoidCallback onPressed;
  final AppConfirmActionStyle actionStyle;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: _gradient,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: _shadowColor.withValues(alpha: 0.22),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          onTap: onPressed,
          child: SizedBox(
            height: AppSize.ctaHeight,
            child: Center(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  LinearGradient get _gradient => switch (actionStyle) {
    AppConfirmActionStyle.neutral => const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: <Color>[AppColors.accentBlue, AppColors.accentViolet],
    ),
    AppConfirmActionStyle.destructive => const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: <Color>[Color(0xFFFF7E9D), AppColors.accentPink],
    ),
  };

  Color get _shadowColor => switch (actionStyle) {
    AppConfirmActionStyle.neutral => AppColors.accentViolet,
    AppConfirmActionStyle.destructive => AppColors.accentPink,
  };
}
