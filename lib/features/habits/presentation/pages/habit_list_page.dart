import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:starnyx/app/di/service_locator.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/core/widgets/core_widgets.dart';
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:starnyx/features/habits/presentation/bloc/habit_list_bloc.dart';
import 'package:starnyx/features/habits/presentation/bloc/habit_list_event.dart';
import 'package:starnyx/features/habits/presentation/bloc/habit_list_state.dart';
import 'package:starnyx/features/starnyx_form/presentation/pages/starnyx_form_page.dart';
import 'package:starnyx/features/starnyx_form/presentation/widgets/starnyx_form_color_utils.dart';

/// Result returned to the Habits tab when the habit list closes a tab-level
/// destination. Selecting or editing a habit returns `null`; the caller reloads
/// the home screen after every pop so ordering, titles, and the active accent
/// stay in sync.
enum HabitListExitAction { settingsRequested, journalRequested }

/// Full-screen habit list / switcher.
class HabitListPage extends StatefulWidget {
  const HabitListPage({this.bloc, super.key});

  /// Injectable for tests. When omitted the page resolves the factory from DI.
  final HabitListBloc? bloc;

  @override
  State<HabitListPage> createState() => _HabitListPageState();
}

class _HabitListPageState extends State<HabitListPage> {
  late final HabitListBloc _bloc;
  late final bool _ownsBloc;
  late List<StarNyx> _orderedHabits;
  bool _isReorderMode = false;
  int _lastSelectionFeedbackCount = 0;
  int _lastOrderFeedbackCount = 0;

  @override
  void initState() {
    super.initState();
    _ownsBloc = widget.bloc == null;
    _bloc = widget.bloc ?? serviceLocator<HabitListBloc>();
    _orderedHabits = <StarNyx>[];
    _bloc.add(const HabitListLoadRequested());
  }

  @override
  void dispose() {
    if (_ownsBloc) {
      _bloc.close();
    }
    super.dispose();
  }

  void _showMessage(String key) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(SnackBar(content: Text(key.tr())));
  }

  void _onStateChanged(BuildContext context, HabitListState state) {
    if (state.selectionFeedbackCount != _lastSelectionFeedbackCount) {
      _lastSelectionFeedbackCount = state.selectionFeedbackCount;
      if (state.selectionStatus == AsyncStatus.success) {
        Navigator.of(context).pop();
      } else if (state.selectionStatus == AsyncStatus.failure) {
        _showMessage('habits.select_error');
      }
    }

    if (state.orderFeedbackCount != _lastOrderFeedbackCount) {
      _lastOrderFeedbackCount = state.orderFeedbackCount;
      if (state.orderStatus == AsyncStatus.failure) {
        _showMessage('habits.order_error');
      }
    }
  }

  void _toggleReorderMode(List<StarNyx> habits) {
    if (_isReorderMode) {
      final orderedIds = _orderedHabits
          .map((habit) => habit.id)
          .toList(growable: false);
      setState(() {
        _isReorderMode = false;
      });
      _bloc.add(HabitListOrderChanged(orderedIds));
      return;
    }

    setState(() {
      _orderedHabits = List<StarNyx>.of(habits);
      _isReorderMode = true;
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (!_isReorderMode) {
      return;
    }
    setState(() {
      final habit = _orderedHabits.removeAt(oldIndex);
      _orderedHabits.insert(newIndex, habit);
    });
  }

  Future<void> _openCreate() async {
    if (_isReorderMode) {
      setState(() {
        _isReorderMode = false;
      });
    }
    final result = await StarnyxFormPage.open(context);
    if (!mounted || result == null || !result.hasChanges) {
      return;
    }
    _bloc.add(const HabitListReloadRequested());
  }

  Future<void> _openEdit(StarNyx habit) async {
    final result = await StarnyxFormPage.open(context, starnyx: habit);
    if (!mounted || result == null || !result.hasChanges) {
      return;
    }
    _bloc.add(const HabitListReloadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HabitListBloc>.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: BlocConsumer<HabitListBloc, HabitListState>(
                listener: _onStateChanged,
                builder: (BuildContext context, HabitListState state) {
                  if (state.status == HabitListStatus.failure) {
                    return _HabitListMessageView(
                      icon: HugeIconsStrokeRounded.strokeRoundedAlert01,
                      title: 'habits.load_error_title'.tr(),
                      message: 'habits.load_error_message'.tr(),
                      actionLabel: 'habits.retry'.tr(),
                      onActionPressed: () =>
                          _bloc.add(const HabitListReloadRequested()),
                    );
                  }

                  final isLoading =
                      state.status == HabitListStatus.initial ||
                      state.status == HabitListStatus.loading;
                  if (isLoading && state.habits.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.habits.isEmpty) {
                    return _HabitListMessageView(
                      icon:
                          HugeIconsStrokeRounded.strokeRoundedCheckmarkCircle02,
                      title: 'habits.empty_title'.tr(),
                      message: 'habits.empty_message'.tr(),
                      actionLabel: 'habits.empty_action'.tr(),
                      onActionPressed: _openCreate,
                      header: _buildHeader(context, state),
                    );
                  }

                  final habits = _isReorderMode ? _orderedHabits : state.habits;

                  return ReorderableListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.pageHorizontal,
                      AppSpacing.xs,
                      AppSpacing.pageHorizontal,
                      AppSpacing.xl,
                    ),
                    buildDefaultDragHandles: false,
                    header: _buildHeader(context, state),
                    itemCount: habits.length,
                    onReorderItem: _onReorder,
                    proxyDecorator:
                        (Widget child, int index, Animation<double> _) {
                          return Material(
                            color: Colors.transparent,
                            elevation: 8,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            child: child,
                          );
                        },
                    itemBuilder: (BuildContext context, int index) {
                      final habit = habits[index];
                      return Padding(
                        key: ValueKey<String>('habit-list-row-${habit.id}'),
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _HabitRow(
                          habit: habit,
                          isActive: habit.id == state.activeHabitId,
                          isReorderMode: _isReorderMode,
                          dragIndex: index,
                          onTap: () =>
                              _bloc.add(HabitListHabitSelected(habit.id)),
                          onEditPressed: () => _openEdit(habit),
                        ),
                      );
                    },
                    footer: _buildFooter(context, state),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, HabitListState state) {
    final activeHabit = state.activeHabit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _HabitListTitleBar(onBackPressed: () => Navigator.of(context).pop()),
        const SizedBox(height: AppSpacing.lg),
        if (activeHabit != null) ...<Widget>[
          _ActiveHabitPill(habit: activeHabit),
          const SizedBox(height: AppSpacing.md),
        ],
        Row(
          children: <Widget>[
            Expanded(
              child: _ActionTile(
                tileKey: const Key('habit-list-settings'),
                icon: HugeIconsStrokeRounded.strokeRoundedSettings01,
                semanticsLabel: 'habits.settings_action'.tr(),
                onPressed: () => Navigator.of(
                  context,
                ).pop(HabitListExitAction.settingsRequested),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _ActionTile(
                tileKey: const Key('habit-list-journal'),
                icon: HugeIconsStrokeRounded.strokeRoundedBookOpen01,
                semanticsLabel: 'habits.journal_action'.tr(),
                onPressed: () => Navigator.of(
                  context,
                ).pop(HabitListExitAction.journalRequested),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _ActionTile(
                tileKey: const Key('habit-list-add'),
                icon: HugeIconsStrokeRounded.strokeRoundedPlus,
                semanticsLabel: 'habits.add_action'.tr(),
                onPressed: _openCreate,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'habits.your_habits'.tr(),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            TextButton.icon(
              key: const Key('habit-list-edit-toggle'),
              onPressed: state.habits.length > 1
                  ? () => _toggleReorderMode(state.habits)
                  : null,
              icon: AppIcon(
                icon: _isReorderMode
                    ? HugeIconsStrokeRounded.strokeRoundedCheckmarkCircle02
                    : HugeIconsStrokeRounded.strokeRoundedDragDropVertical,
                size: 16,
                color: _isReorderMode ? AppColors.primary : AppColors.tertiary,
              ),
              label: Text(
                _isReorderMode ? 'habits.done'.tr() : 'habits.edit'.tr(),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: _isReorderMode
                      ? AppColors.primary
                      : AppColors.tertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
      ],
    );
  }

  Widget _buildFooter(BuildContext context, HabitListState state) {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      padding: const EdgeInsets.only(top: AppSpacing.md),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xxs,
        children: <Widget>[
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
          ),
          Text(
            'habits.footer'.tr(
              args: <String>[
                state.completedTodayCount.toString(),
                state.habits.length.toString(),
              ],
            ),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              fontFamily: AppFonts.mono,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitListTitleBar extends StatelessWidget {
  const _HabitListTitleBar({required this.onBackPressed});

  final VoidCallback onBackPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Material(
          color: Colors.transparent,
          child: InkWell(
            key: const Key('habit-list-back'),
            onTap: onBackPressed,
            customBorder: const CircleBorder(),
            child: const SizedBox.square(
              dimension: 44,
              child: Center(
                child: AppIcon(
                  icon: HugeIconsStrokeRounded.strokeRoundedArrowLeft01,
                  size: 22,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xxs),
        Expanded(
          child: Column(
            children: <Widget>[
              Text(
                'habits.title'.tr(),
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontFamily: AppFonts.headline,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                'habits.subtitle'.tr(),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }
}

class _ActiveHabitPill extends StatelessWidget {
  const _ActiveHabitPill({required this.habit});

  final StarNyx habit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'habits.active_habit_semantics'.tr(args: <String>[habit.title]),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.secondary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: AppColors.secondary.withValues(alpha: 0.7),
            width: 1.2,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.12),
              blurRadius: 18,
            ),
          ],
        ),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xxs,
          children: <Widget>[
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary,
              ),
            ),
            Text(
              'habits.active_pill'.tr(),
              style: theme.textTheme.titleSmall?.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              habit.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.tileKey,
    required this.icon,
    required this.semanticsLabel,
    required this.onPressed,
  });

  final Key tileKey;
  final List<List<dynamic>> icon;
  final String semanticsLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: Material(
        color: AppColors.surfaceLevel1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: const BorderSide(color: AppColors.borderSubtle),
        ),
        child: InkWell(
          key: tileKey,
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: SizedBox(
            height: 56,
            child: Center(
              child: AppIcon(
                icon: icon,
                size: 24,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HabitRow extends StatelessWidget {
  const _HabitRow({
    required this.habit,
    required this.isActive,
    required this.isReorderMode,
    required this.dragIndex,
    required this.onTap,
    required this.onEditPressed,
  });

  final StarNyx habit;
  final bool isActive;
  final bool isReorderMode;
  final int dragIndex;
  final VoidCallback onTap;
  final VoidCallback onEditPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = starnyxColorFromHex(habit.color);
    final subtitle = _subtitle();

    return Semantics(
      button: !isReorderMode,
      child: Material(
        color: accent.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(
            color: accent.withValues(alpha: isActive ? 0.55 : 0.22),
          ),
        ),
        child: InkWell(
          onTap: isReorderMode ? null : onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              children: <Widget>[
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Center(
                    child: AppIcon(
                      icon: HabitSymbols.iconFor(habit.icon),
                      color: accent,
                      size: 22,
                      strokeWidth: 2,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              habit.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: accent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (isActive) ...<Widget>[
                            const SizedBox(width: AppSpacing.xs),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                if (isReorderMode)
                  ReorderableDragStartListener(
                    key: Key('habit-list-drag-${habit.id}'),
                    index: dragIndex,
                    child: Semantics(
                      label: 'habits.reorder_habit_semantics'.tr(
                        args: <String>[habit.title],
                      ),
                      child: const SizedBox.square(
                        dimension: 40,
                        child: Center(
                          child: AppIcon(
                            icon: HugeIconsStrokeRounded
                                .strokeRoundedDragDropVertical,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Semantics(
                    button: true,
                    label: 'habits.edit_habit_semantics'.tr(
                      args: <String>[habit.title],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        key: Key('habit-list-edit-${habit.id}'),
                        onTap: onEditPressed,
                        customBorder: const CircleBorder(),
                        child: const SizedBox.square(
                          dimension: 40,
                          child: Center(
                            child: AppIcon(
                              icon: HugeIconsStrokeRounded
                                  .strokeRoundedPencilEdit02,
                              size: 20,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _subtitle() {
    final description = habit.hasDescription
        ? habit.description!.trim()
        : 'habits.no_description'.tr();
    if (habit.hasReminder && habit.reminderTime != null) {
      return '${habit.reminderTime} · $description';
    }
    return description;
  }
}

class _HabitListMessageView extends StatelessWidget {
  const _HabitListMessageView({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onActionPressed,
    this.header,
  });

  final List<List<dynamic>> icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onActionPressed;
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.xs,
        AppSpacing.pageHorizontal,
        AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (header != null) ...<Widget>[
            header!,
            const SizedBox(height: AppSpacing.lg),
          ],
          AppEmptyState(
            icon: icon,
            title: title,
            message: message,
            actionLabel: actionLabel,
            onActionPressed: onActionPressed,
          ),
        ],
      ),
    );
  }
}
