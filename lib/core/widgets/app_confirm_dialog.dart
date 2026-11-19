import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:starnyx/core/constants/core_constants.dart';

import 'app_icon.dart';

const _ghostFill = Color(0xFF1F1E24);

/// Shows the shared confirmation dialog (`xac_nhan_xoa_thoi_quen`).
///
/// Black ~78% barrier with a subtle blur; the card scales 0.94→1 and fades
/// in, or appears instantly when the platform asks for reduced motion.
/// [subject] is an optional chip under the title naming what is affected.
/// Resolves to `true` on confirm, `false` on cancel, `null` when dismissed.
Future<bool?> showAppConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String cancelLabel,
  required String confirmLabel,
  List<List<dynamic>> icon = HugeIconsStrokeRounded.strokeRoundedDelete02,
  AppConfirmActionStyle actionStyle = AppConfirmActionStyle.neutral,
  Widget? subject,
}) {
  final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: cancelLabel,
    barrierColor: AppColors.black.withValues(alpha: 0.78),
    transitionDuration: reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 220),
    pageBuilder: (_, _, _) {
      return AppConfirmDialog(
        title: title,
        message: message,
        cancelLabel: cancelLabel,
        confirmLabel: confirmLabel,
        icon: icon,
        actionStyle: actionStyle,
        subject: subject,
      );
    },
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      return BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 6 * animation.value,
          sigmaY: 6 * animation.value,
        ),
        child: FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
            child: child,
          ),
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
    this.icon = HugeIconsStrokeRounded.strokeRoundedDelete02,
    this.actionStyle = AppConfirmActionStyle.neutral,
    this.subject,
  });

  final String title;
  final String message;
  final String cancelLabel;
  final String confirmLabel;
  final List<List<dynamic>> icon;
  final AppConfirmActionStyle actionStyle;
  final Widget? subject;

  Color get _accent => switch (actionStyle) {
    AppConfirmActionStyle.neutral => AppColors.textPrimary,
    AppConfirmActionStyle.destructive => AppColors.error,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Material(
              color: AppColors.sheet,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.sheet),
                side: const BorderSide(color: AppColors.borderSubtle),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceLevel3,
                        border: Border.all(
                          color: _accent.withValues(alpha: 0.3),
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: _accent.withValues(alpha: 0.2),
                            blurRadius: 24,
                          ),
                        ],
                      ),
                      child: Center(
                        child: AppIcon(icon: icon, color: _accent, size: 26),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontFamily: AppFonts.headline,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (subject != null) ...<Widget>[
                      const SizedBox(height: AppSpacing.sm),
                      subject!,
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _DialogButton(
                            key: const Key('app-confirm-cancel'),
                            label: cancelLabel,
                            fill: _ghostFill,
                            labelColor: AppColors.textPrimary,
                            outlined: true,
                            onPressed: () => Navigator.of(context).pop(false),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _DialogButton(
                            key: const Key('app-confirm-confirm'),
                            label: confirmLabel,
                            fill: switch (actionStyle) {
                              AppConfirmActionStyle.neutral => AppColors.white,
                              AppConfirmActionStyle.destructive =>
                                AppColors.error,
                            },
                            labelColor: AppColors.black,
                            glow:
                                actionStyle ==
                                AppConfirmActionStyle.destructive,
                            onPressed: () => Navigator.of(context).pop(true),
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
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.fill,
    required this.labelColor,
    required this.onPressed,
    super.key,
    this.glow = false,
    this.outlined = false,
  });

  final String label;
  final Color fill;
  final Color labelColor;
  final VoidCallback onPressed;
  final bool glow;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final shape = BorderRadius.circular(AppRadius.pill);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: shape,
        boxShadow: glow
            ? <BoxShadow>[
                BoxShadow(color: fill.withValues(alpha: 0.35), blurRadius: 20),
              ]
            : null,
      ),
      child: Material(
        color: fill,
        shape: RoundedRectangleBorder(
          borderRadius: shape,
          side: outlined
              ? const BorderSide(color: AppColors.borderSubtle)
              : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: shape,
          onTap: onPressed,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppSize.ctaHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              child: Center(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: labelColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
