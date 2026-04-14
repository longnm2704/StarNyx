import 'package:flutter/material.dart';
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:starnyx/core/widgets/core_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/features/starnyx_form/presentation/widgets/starnyx_form_color_utils.dart';

enum ConstellationSwitcherSheetAction { createRequested }

class ConstellationSwitcherSheet extends StatelessWidget {
  const ConstellationSwitcherSheet({
    required this.starnyxs,
    required this.activeStarnyxId,
    required this.onEditPressed,
    required this.onSelectPressed,
    super.key,
  });

  final List<StarNyx> starnyxs;
  final String? activeStarnyxId;
  final ValueChanged<StarNyx> onEditPressed;
  final ValueChanged<StarNyx> onSelectPressed;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topInset = mediaQuery.viewPadding.top > 0
        ? mediaQuery.viewPadding.top
        : mediaQuery.padding.top;
    final activeStarnyx = starnyxs.firstWhere(
      (StarNyx item) => item.id == activeStarnyxId,
      orElse: () => starnyxs.first,
    );
    final activeColor = starnyxColorFromHex(activeStarnyx.color);
    final panelColor = Color.lerp(AppColors.surface, AppColors.black, 0.38)!;
    final panelHighlight = Color.lerp(activeColor, AppColors.white, 0.2)!;
    const headerStartColor = AppColors.accentBlue;
    const headerEndColor = AppColors.accentPink;
    final sectionAccent = Color.lerp(
      activeColor,
      AppColors.accentOrange,
      0.22,
    )!;

    return FractionallySizedBox(
      heightFactor: 0.82,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: panelColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
          border: Border.all(color: panelHighlight.withValues(alpha: 0.28)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.34),
              blurRadius: 32,
              offset: const Offset(0, -12),
            ),
            BoxShadow(
              color: activeColor.withValues(alpha: 0.1),
              blurRadius: 28,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl),
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                panelHighlight.withValues(alpha: 0.08),
                Colors.transparent,
              ],
            ),
          ),
          child: SafeArea(
            top: false,
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal,
                (topInset < 16 ? 16.0 : topInset * 0.35) + AppSpacing.sm,
                AppSpacing.pageHorizontal,
                AppSpacing.lg + mediaQuery.viewInsets.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Container(
                      width: 52,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.24),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Center(
                    child: Text(
                      'home.sheet_title'.tr(),
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Center(
                    child: Text(
                      'home.sheet_manage_label'.tr(),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.86),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _ActiveConstellationPill(
                    label: 'home.sheet_active_label'.tr(),
                    startColor: headerStartColor,
                    endColor: headerEndColor,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _SheetActionPill(
                          assetPath: 'assets/icons/ic_settings.svg',
                          onPressed: () {
                            Navigator.of(context).pop();
                            onEditPressed(activeStarnyx);
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _SheetActionPill(
                          assetPath: 'assets/icons/ic_book.svg',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _SheetActionPill(
                          assetPath: 'assets/icons/ic_plus.svg',
                          onPressed: () => Navigator.of(context).pop(
                            ConstellationSwitcherSheetAction.createRequested,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 6,
                          children: <Widget>[
                            Text(
                              'home.sheet_constellations_title'.tr(),
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            Text(
                              'home.sheet_constellations_helper'.tr(),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'home.edit_constellation'.tr(),
                          style: TextStyle(
                            color: sectionAccent,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: starnyxs.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (BuildContext context, int index) {
                        final starnyx = starnyxs[index];
                        return _ConstellationSwitcherCard(
                          starnyx: starnyx,
                          isActive: starnyx.id == activeStarnyxId,
                          onEditPressed: () {
                            Navigator.of(context).pop();
                            onEditPressed(starnyx);
                          },
                          onSelectPressed: () {
                            Navigator.of(context).pop();
                            onSelectPressed(starnyx);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActiveConstellationPill extends StatelessWidget {
  const _ActiveConstellationPill({
    required this.label,
    required this.startColor,
    required this.endColor,
  });

  final String label;
  final Color startColor;
  final Color endColor;

  @override
  Widget build(BuildContext context) {
    final fillColor = Color.lerp(
      AppColors.surfaceElevated,
      AppColors.backgroundMid,
      0.35,
    )!;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[startColor, endColor],
        ),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: startColor.withValues(alpha: 0.2),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(AppRadius.pill - 2),
          ),
          child: SizedBox(
            height: 44,
            child: Center(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.accentPink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetActionPill extends StatelessWidget {
  const _SheetActionPill({required this.assetPath, this.onPressed});

  final String assetPath;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: onPressed,
        child: Ink(
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
              color: AppColors.white.withValues(alpha: isEnabled ? 0.14 : 0.08),
            ),
          ),
          child: Center(
            child: AppSvgIcon(
              assetPath: assetPath,
              size: 22,
              color: isEnabled
                  ? AppColors.white.withValues(alpha: 0.9)
                  : AppColors.textMuted,
              semanticsLabel: assetPath,
            ),
          ),
        ),
      ),
    );
  }
}

class _ConstellationSwitcherCard extends StatelessWidget {
  const _ConstellationSwitcherCard({
    required this.starnyx,
    required this.isActive,
    required this.onEditPressed,
    required this.onSelectPressed,
  });

  final StarNyx starnyx;
  final bool isActive;
  final VoidCallback onEditPressed;
  final VoidCallback onSelectPressed;

  @override
  Widget build(BuildContext context) {
    final itemColor = starnyxColorFromHex(starnyx.color);
    final borderColor = isActive
        ? itemColor
        : itemColor.withValues(alpha: 0.56);
    final backgroundColor = isActive
        ? Color.lerp(itemColor, AppColors.surface, 0.8)!
        : itemColor.withValues(alpha: 0.08);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: isActive ? null : onSelectPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: borderColor, width: isActive ? 2 : 1),
            boxShadow: isActive
                ? <BoxShadow>[
                    BoxShadow(
                      color: itemColor.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: itemColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  starnyx.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: itemColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                onPressed: onEditPressed,
                icon: AppSvgIcon(
                  assetPath: 'assets/icons/ic_edit.svg',
                  color: itemColor,
                  size: 18,
                  semanticsLabel: 'Edit ${starnyx.title}',
                ),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
