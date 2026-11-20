import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/core/widgets/core_widgets.dart';

const int _kGridColumns = 6;
const double _kPreviewSize = 30;

/// Symbol section of the create/edit form: title + helper, category filter
/// chips ([HabitSymbols.groups]), a 6-column symbol grid and a live 7-day
/// streak preview using the selected symbol and [color].
class StarnyxFormSymbolPicker extends StatefulWidget {
  const StarnyxFormSymbolPicker({
    required this.selectedSymbol,
    required this.color,
    required this.onSymbolSelected,
    super.key,
  });

  /// Currently selected habit symbol key (e.g. 'star', 'clover', 'flame').
  final String selectedSymbol;

  /// Accent color used for the selected symbol, chips and the preview.
  final Color color;

  /// Callback invoked when the user picks a different symbol.
  final ValueChanged<String> onSymbolSelected;

  @override
  State<StarnyxFormSymbolPicker> createState() =>
      _StarnyxFormSymbolPickerState();
}

class _StarnyxFormSymbolPickerState extends State<StarnyxFormSymbolPicker> {
  // Selected category id; null shows every symbol.
  String? _category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final keys = <String>[
      for (final group in HabitSymbols.groups)
        if (_category == null || _category == group.id) ...group.keys,
    ];

    return AppCard(
      radius: AppRadius.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'starnyx_form.symbol_label'.tr(),
            style: theme.textTheme.titleLarge?.copyWith(
              fontFamily: AppFonts.headline,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'starnyx_form.symbol_helper'.tr(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <Widget>[
                AppFilterChip(
                  label: 'starnyx_form.symbol_category_all'.tr(),
                  color: widget.color,
                  selected: _category == null,
                  onTap: () => setState(() => _category = null),
                ),
                for (final group in HabitSymbols.groups)
                  AppFilterChip(
                    label: 'starnyx_form.symbol_category_${group.id}'.tr(),
                    color: widget.color,
                    selected: _category == group.id,
                    onTap: () => setState(() => _category = group.id),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          GridView.count(
            crossAxisCount: _kGridColumns,
            mainAxisSpacing: AppSpacing.xs,
            crossAxisSpacing: AppSpacing.xs,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            children: <Widget>[
              for (final key in keys)
                _SymbolCell(
                  symbolKey: key,
                  color: widget.color,
                  isSelected: key == widget.selectedSymbol,
                  onTap: () => widget.onSymbolSelected(key),
                ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Divider(height: 1, color: AppColors.borderSubtle),
          ),
          _SevenDayPreview(
            symbolKey: widget.selectedSymbol,
            color: widget.color,
          ),
        ],
      ),
    );
  }
}

/// Selected: accent-filled circle with a dark glyph and soft glow.
/// Unselected: `#121215` circle with a muted glyph.
class _SymbolCell extends StatelessWidget {
  const _SymbolCell({
    required this.symbolKey,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final String symbolKey;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'starnyx_form.symbol_semantics'.tr(args: <String>[symbolKey]),
      button: true,
      selected: isSelected,
      child: GestureDetector(
        key: Key('starnyx-form-symbol-$symbolKey'),
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? color : AppColors.surfaceLevel2,
            boxShadow: isSelected
                ? <BoxShadow>[
                    BoxShadow(
                      color: color.withValues(alpha: 0.35),
                      blurRadius: 14,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: AppIcon(
              icon: HabitSymbols.iconFor(symbolKey),
              color: isSelected ? AppColors.black : AppColors.textSecondary,
              size: 20,
              strokeWidth: 2,
            ),
          ),
        ),
      ),
    );
  }
}

enum _DayState { future, missed, lit, today }

/// Live 7-day preview showing how the selected symbol renders in each day
/// state (future / missed / lit / today).
class _SevenDayPreview extends StatelessWidget {
  const _SevenDayPreview({required this.symbolKey, required this.color});

  final String symbolKey;
  final Color color;

  // Representative mix of day states across the 7-day preview window.
  static const List<_DayState> _states = <_DayState>[
    _DayState.future,
    _DayState.missed,
    _DayState.lit,
    _DayState.lit,
    _DayState.today,
    _DayState.missed,
    _DayState.future,
  ];

  @override
  Widget build(BuildContext context) {
    final iconData = HabitSymbols.iconFor(symbolKey);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AppSectionLabel('starnyx_form.preview_label'.tr()),
        const SizedBox(height: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.black,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              for (final state in _states)
                _PreviewDayCell(state: state, iconData: iconData, color: color),
            ],
          ),
        ),
      ],
    );
  }
}

class _PreviewDayCell extends StatelessWidget {
  const _PreviewDayCell({
    required this.state,
    required this.iconData,
    required this.color,
  });

  final _DayState state;
  final List<List<dynamic>> iconData;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final glyph = switch (state) {
      _DayState.future => null,
      _DayState.missed => color.withValues(alpha: 0.2),
      _DayState.lit => AppColors.black,
      _DayState.today => color,
    };

    return Container(
      width: _kPreviewSize,
      height: _kPreviewSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: state == _DayState.lit ? color : null,
        border: state == _DayState.today
            ? Border.all(color: color, width: 1.5)
            : null,
        boxShadow: state == _DayState.lit
            ? <BoxShadow>[
                BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 10),
              ]
            : null,
      ),
      child: Center(
        child: glyph == null
            // Future / before-start day: a small dot.
            ? Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceLevel3,
                ),
              )
            : AppIcon(icon: iconData, color: glyph, size: 16, strokeWidth: 2),
      ),
    );
  }
}
