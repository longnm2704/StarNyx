import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/core/widgets/app_icon.dart';

const double _kSymbolSize = 44;
const double _kSelectedSize = 52;
const double _kPreviewSize = 34;

/// A symbol picker for the StarNyx create/edit form.
///
/// Displays the curated habit symbol catalog in grouped rows of 6 columns,
/// with a live 7-day preview row below using the selected symbol and color.
///
/// Tapping a symbol calls [onSymbolSelected] with the stable symbol key.
class StarnyxFormSymbolPicker extends StatelessWidget {
  const StarnyxFormSymbolPicker({
    required this.selectedSymbol,
    required this.color,
    required this.onSymbolSelected,
    super.key,
  });

  /// Currently selected habit symbol key (e.g. 'star', 'clover', 'flame').
  final String selectedSymbol;

  /// Accent color used to render the symbol and the 7-day preview.
  final Color color;

/// Callback invoked when the user picks a different symbol.
final ValueChanged<String> onSymbolSelected;

@override
Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[AppColors.formCardStart, AppColors.formCardEndAlt],
        ),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.62)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, AppSpacing.sm),
            child: Row(
              children: <Widget>[
                Text(
                  'starnyx_form.symbol_label'.tr(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'starnyx_form.symbol_helper'.tr(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _SymbolGrid(
            selectedSymbol: selectedSymbol,
            color: color,
            onSymbolSelected: onSymbolSelected,
          ),
          const SizedBox(height: AppSpacing.lg),
          _SevenDayPreview(
            symbolKey: selectedSymbol,
            color: color,
          ),
        ],
      ),
    );
  }
}

/// Grouped symbol grid rendered with 6 columns per group.
class _SymbolGrid extends StatelessWidget {
  const _SymbolGrid({
    required this.selectedSymbol,
    required this.color,
    required this.onSymbolSelected,
  });

  final String selectedSymbol;
  final Color color;
  final ValueChanged<String> onSymbolSelected;

  @override
  Widget build(BuildContext context) {
    final cells = <Widget>[];

    for (final group in HabitSymbols.groups) {
      cells.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, AppSpacing.xs),
          child: Text(
            group.label.toUpperCase(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
            ),
          ),
        ),
      );

      for (final key in group.keys) {
        final isSelected = key == selectedSymbol;
        cells.add(
          _SymbolCell(
            symbolKey: key,
            iconData: HabitSymbols.iconFor(key),
            color: color,
            isSelected: isSelected,
            size: _kSymbolSize,
            selectedSize: _kSelectedSize,
            onTap: () => onSymbolSelected(key),
          ),
        );
      }
    }

    return GridView.extent(
      maxCrossAxisExtent: _kSelectedSize + 16,
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      childAspectRatio: 1,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      children: cells,
    );
  }
}

/// A single selectable symbol cell in the symbol grid.
class _SymbolCell extends StatelessWidget {
  const _SymbolCell({
    required this.symbolKey,
    required this.iconData,
    required this.color,
    required this.isSelected,
    required this.size,
    required this.selectedSize,
    required this.onTap,
  });

  final String symbolKey;
  final List<List<dynamic>> iconData;
  final Color color;
  final bool isSelected;
  final double size;
  final double selectedSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final displaySize = isSelected ? selectedSize : size;

    return Semantics(
      label: 'starnyx_form.symbol_semantics'.tr(args: <String>[symbolKey]),
      button: true,
      selected: isSelected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          width: displaySize,
          height: displaySize,
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.18)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: isSelected
                  ? color
                  : AppColors.outline.withValues(alpha: 0.35),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: AppIcon(
              icon: iconData,
              color: isSelected ? color : AppColors.textSecondary,
              size: size,
              strokeWidth: 2,
            ),
          ),
        ),
      ),
    );
  }
}

/// Live 7-day preview row showing how the selected symbol renders in each
/// day state (future / missed / lit / today).
class _SevenDayPreview extends StatelessWidget {
  const _SevenDayPreview({
    required this.symbolKey,
    required this.color,
  });

  final String symbolKey;
  final Color color;

  static const int _dayCount = 7;

  // Representative mix of day states across the 7-day preview window.
  static const List<_DayState> _states = <_DayState>[
    _DayState.future,
    _DayState.missed,
    _DayState.lit,
    _DayState.today,
    _DayState.lit,
    _DayState.missed,
    _DayState.future,
  ];

  @override
  Widget build(BuildContext context) {
    final iconData = HabitSymbols.iconFor(symbolKey);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, AppSpacing.xs),
          child: Text(
            'starnyx_form.preview_label'.tr(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        SizedBox(
          height: _kPreviewSize + 8,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _dayCount,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
            itemBuilder: (_, index) {
              final state = _states[index % _dayCount];
              return _PreviewDayCell(
                state: state,
                iconData: iconData,
                color: color,
                size: _kPreviewSize,
              );
            },
          ),
        ),
      ],
    );
  }
}

/// A single day cell in the 7-day preview.
class _PreviewDayCell extends StatelessWidget {
  const _PreviewDayCell({
    required this.state,
    required this.iconData,
    required this.color,
    required this.size,
  });

  final _DayState state;
  final List<List<dynamic>> iconData;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case _DayState.future:
        return _FutureCell(size: size);
      case _DayState.missed:
        return _MissedCell(
          iconData: iconData,
          color: color,
          size: size,
        );
      case _DayState.lit:
        return _LitCell(
          iconData: iconData,
          color: color,
          size: size,
        );
      case _DayState.today:
        return _TodayCell(
          iconData: iconData,
          color: color,
          size: size,
        );
    }
  }
}

enum _DayState { future, missed, lit, today }

/// Future / before-start day: a small dot.
class _FutureCell extends StatelessWidget {
  const _FutureCell({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.outline.withValues(alpha: 0.35),
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Missed day: symbol stroke at low opacity, no glow.
class _MissedCell extends StatelessWidget {
  const _MissedCell({
    required this.iconData,
    required this.color,
    required this.size,
  });

  final List<List<dynamic>> iconData;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      child: AppIcon(
        icon: iconData,
        color: color.withValues(alpha: 0.15),
        size: size,
        strokeWidth: 2,
      ),
    );
  }
}

/// Lit day: filled accent-colored disc with soft glow, symbol drawn dark.
class _LitCell extends StatelessWidget {
  const _LitCell({
    required this.iconData,
    required this.color,
    required this.size,
  });

  final List<List<dynamic>> iconData;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: color.withValues(alpha: 0.45),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: AppIcon(
          icon: iconData,
          color: AppColors.black,
          size: size * 0.55,
          strokeWidth: 2,
        ),
      ),
    );
  }
}

/// Today day (not lit): ring outline, keeps size emphasis.
class _TodayCell extends StatelessWidget {
  const _TodayCell({
    required this.iconData,
    required this.color,
    required this.size,
  });

  final List<List<dynamic>> iconData;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: AppIcon(
        icon: iconData,
        color: color,
        size: size * 0.55,
        strokeWidth: 2,
      ),
    );
  }
}
