import 'package:flutter/material.dart';
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:starnyx/core/widgets/core_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/features/starnyx_form/presentation/widgets/starnyx_form_color_utils.dart';

class ConstellationSwitcherSheetAction {
  const ConstellationSwitcherSheetAction._(this.type, [this.starnyx]);

  const ConstellationSwitcherSheetAction.createRequested()
    : this._(ConstellationSwitcherSheetActionType.createRequested);

  const ConstellationSwitcherSheetAction.editRequested(StarNyx starnyx)
    : this._(ConstellationSwitcherSheetActionType.editRequested, starnyx);

  final ConstellationSwitcherSheetActionType type;
  final StarNyx? starnyx;
}

class ConstellationSwitcherSheet extends StatefulWidget {
  const ConstellationSwitcherSheet({
    required this.starnyxs,
    required this.activeStarnyxId,
    required this.onSelectPressed,
    super.key,
  });

  final List<StarNyx> starnyxs;
  final String? activeStarnyxId;
  final ValueChanged<StarNyx> onSelectPressed;

  @override
  State<ConstellationSwitcherSheet> createState() =>
      _ConstellationSwitcherSheetState();
}

class _ConstellationSwitcherSheetState
    extends State<ConstellationSwitcherSheet> {
  late List<StarNyx> _orderedStarnyxs;
  bool _isReorderMode = false;

  @override
  void initState() {
    super.initState();
    _orderedStarnyxs = List<StarNyx>.of(widget.starnyxs);
  }

  @override
  void didUpdateWidget(covariant ConstellationSwitcherSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.starnyxs != widget.starnyxs) {
      _orderedStarnyxs = List<StarNyx>.of(widget.starnyxs);
    }
  }

  void _toggleReorderMode() {
    setState(() {
      _isReorderMode = !_isReorderMode;
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _orderedStarnyxs.removeAt(oldIndex);
      _orderedStarnyxs.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topInset = mediaQuery.viewPadding.top > 0
        ? mediaQuery.viewPadding.top
        : mediaQuery.padding.top;
    final activeStarnyx = _orderedStarnyxs.firstWhere(
      (StarNyx item) => item.id == widget.activeStarnyxId,
      orElse: () => _orderedStarnyxs.first,
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
                      const Expanded(
                        child: _SheetActionPill(
                          assetPath: 'assets/icons/ic_settings.svg',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      const Expanded(
                        child: _SheetActionPill(
                          assetPath: 'assets/icons/ic_book.svg',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _SheetActionPill(
                          assetPath: 'assets/icons/ic_plus.svg',
                          onPressed: () => Navigator.of(context).pop(
                            const ConstellationSwitcherSheetAction.createRequested(),
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
                        onPressed: _toggleReorderMode,
                        child: Text(
                          _isReorderMode
                              ? 'starnyx_form.picker_done'.tr()
                              : 'home.edit_constellation'.tr(),
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
                    child: _isReorderMode
                        ? ReorderableListView.builder(
                            buildDefaultDragHandles: false,
                            padding: EdgeInsets.zero,
                            itemCount: _orderedStarnyxs.length,
                            onReorder: _onReorder,
                            proxyDecorator:
                                (
                                  Widget child,
                                  int index,
                                  Animation<double> animation,
                                ) {
                                  return Material(
                                    color: Colors.transparent,
                                    child: FadeTransition(
                                      opacity: animation.drive(
                                        Tween<double>(begin: 0.94, end: 1),
                                      ),
                                      child: child,
                                    ),
                                  );
                                },
                            itemBuilder: (BuildContext context, int index) {
                              final starnyx = _orderedStarnyxs[index];
                              return Padding(
                                key: ValueKey<String>(starnyx.id),
                                padding: EdgeInsets.only(
                                  bottom: index == _orderedStarnyxs.length - 1
                                      ? 0
                                      : AppSpacing.md,
                                ),
                                child: _ConstellationSwitcherCard(
                                  starnyx: starnyx,
                                  isActive:
                                      starnyx.id == widget.activeStarnyxId,
                                  reorderIndex: index,
                                  isReorderMode: true,
                                  onEditPressed: () {},
                                  onSelectPressed: () {},
                                ),
                              );
                            },
                          )
                        : ListView.separated(
                            padding: EdgeInsets.zero,
                            itemCount: _orderedStarnyxs.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: AppSpacing.md),
                            itemBuilder: (BuildContext context, int index) {
                              final starnyx = _orderedStarnyxs[index];
                              return _ConstellationSwitcherCard(
                                starnyx: starnyx,
                                isActive: starnyx.id == widget.activeStarnyxId,
                                reorderIndex: index,
                                isReorderMode: false,
                                onEditPressed: () => Navigator.of(context).pop(
                                  ConstellationSwitcherSheetAction.editRequested(
                                    starnyx,
                                  ),
                                ),
                                onSelectPressed: () {
                                  Navigator.of(context).pop();
                                  widget.onSelectPressed(starnyx);
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
  static const double _minCardHeight = 68;
  static const double _trailingSlotWidth = 40;

  const _ConstellationSwitcherCard({
    required this.starnyx,
    required this.isActive,
    required this.reorderIndex,
    required this.isReorderMode,
    required this.onEditPressed,
    required this.onSelectPressed,
  });

  final StarNyx starnyx;
  final bool isActive;
  final int reorderIndex;
  final bool isReorderMode;
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
        onTap: isReorderMode || isActive ? null : onSelectPressed,
        child: Container(
          constraints: const BoxConstraints(minHeight: _minCardHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Text(
                  starnyx.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: itemColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              SizedBox(
                width: _trailingSlotWidth,
                child: isReorderMode
                    ? ReorderableDragStartListener(
                        index: reorderIndex,
                        child: Center(
                          child: AppSvgIcon(
                            assetPath: 'assets/icons/ic_cursor.svg',
                            color: itemColor.withValues(alpha: 0.92),
                            size: 18,
                            semanticsLabel: 'Reorder ${starnyx.title}',
                          ),
                        ),
                      )
                    : IconButton(
                        onPressed: onEditPressed,
                        icon: AppSvgIcon(
                          assetPath: 'assets/icons/ic_edit.svg',
                          color: itemColor,
                          size: 18,
                          semanticsLabel: 'Edit ${starnyx.title}',
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
