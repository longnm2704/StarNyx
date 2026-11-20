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
  return _showAppDialog<bool>(
    context: context,
    barrierLabel: cancelLabel,
    child: AppConfirmDialog(
      title: title,
      message: message,
      cancelLabel: cancelLabel,
      confirmLabel: confirmLabel,
      icon: icon,
      actionStyle: actionStyle,
      subject: subject,
    ),
  );
}

/// Same shell as [showAppConfirmDialog] with form fields in place of the
/// subject chip. [content] gets a `setState` for validation messages;
/// [onConfirm] returns the value to pop with, or null to stay open.
/// Resolves to null on cancel or dismiss.
Future<T?> showAppFormDialog<T>({
  required BuildContext context,
  required String title,
  required String message,
  required String cancelLabel,
  required String confirmLabel,
  required Widget Function(BuildContext context, StateSetter setState) content,
  required T? Function(StateSetter setState) onConfirm,
  List<List<dynamic>> icon = HugeIconsStrokeRounded.strokeRoundedLockPassword,
}) {
  return _showAppDialog<T>(
    context: context,
    barrierLabel: cancelLabel,
    child: StatefulBuilder(
      builder: (dialogContext, setState) => _DialogCard(
        title: title,
        message: message,
        icon: icon,
        accent: AppColors.textPrimary,
        body: content(dialogContext, setState),
        actions: _DialogActions(
          cancelLabel: cancelLabel,
          confirmLabel: confirmLabel,
          actionStyle: AppConfirmActionStyle.neutral,
          onCancel: () => Navigator.of(dialogContext).pop(),
          onConfirm: () {
            final value = onConfirm(setState);
            if (value != null) Navigator.of(dialogContext).pop(value);
          },
        ),
      ),
    ),
  );
}

// Black ~78% barrier with a subtle blur; the card scales 0.94→1 and fades
// in, or appears instantly when the platform asks for reduced motion.
Future<T?> _showAppDialog<T>({
  required BuildContext context,
  required String barrierLabel,
  required Widget child,
}) {
  final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: barrierLabel,
    barrierColor: AppColors.black.withValues(alpha: 0.78),
    transitionDuration: reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 220),
    pageBuilder: (_, _, _) => child,
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
    return _DialogCard(
      title: title,
      message: message,
      icon: icon,
      accent: _accent,
      subject: subject,
      actions: _DialogActions(
        cancelLabel: cancelLabel,
        confirmLabel: confirmLabel,
        actionStyle: actionStyle,
        onCancel: () => Navigator.of(context).pop(false),
        onConfirm: () => Navigator.of(context).pop(true),
      ),
    );
  }
}

class _DialogCard extends StatelessWidget {
  const _DialogCard({
    required this.title,
    required this.message,
    required this.icon,
    required this.accent,
    required this.actions,
    this.subject,
    this.body,
  });

  final String title;
  final String message;
  final List<List<dynamic>> icon;
  final Color accent;
  final Widget? subject;
  final Widget? body;
  final Widget actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg + MediaQuery.viewInsetsOf(context).bottom,
          ),
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
                          color: accent.withValues(alpha: 0.3),
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: accent.withValues(alpha: 0.2),
                            blurRadius: 24,
                          ),
                        ],
                      ),
                      child: Center(
                        child: AppIcon(icon: icon, color: accent, size: 26),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
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
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                    ),
                    if (body != null) ...<Widget>[
                      const SizedBox(height: AppSpacing.md),
                      body!,
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    actions,
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

class _DialogActions extends StatelessWidget {
  const _DialogActions({
    required this.cancelLabel,
    required this.confirmLabel,
    required this.actionStyle,
    required this.onCancel,
    required this.onConfirm,
  });

  final String cancelLabel;
  final String confirmLabel;
  final AppConfirmActionStyle actionStyle;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _DialogButton(
            key: const Key('app-confirm-cancel'),
            label: cancelLabel,
            fill: _ghostFill,
            labelColor: AppColors.textPrimary,
            outlined: true,
            onPressed: onCancel,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _DialogButton(
            key: const Key('app-confirm-confirm'),
            label: confirmLabel,
            fill: switch (actionStyle) {
              AppConfirmActionStyle.neutral => AppColors.white,
              AppConfirmActionStyle.destructive => AppColors.error,
            },
            labelColor: AppColors.black,
            glow: actionStyle == AppConfirmActionStyle.destructive,
            onPressed: onConfirm,
          ),
        ),
      ],
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
