import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:starnyx/app/di/service_locator.dart';
import 'package:starnyx/app/router/app_routes.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/core/utils/date_utils.dart' as core_date_utils;
import 'package:starnyx/core/widgets/core_widgets.dart';
import 'package:starnyx/domain/entities/journal_entry.dart';
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:starnyx/domain/usecases/load_active_starnyx_use_case.dart';
import 'package:starnyx/features/journal/presentation/bloc/journal_bloc.dart';
import 'package:starnyx/features/journal/presentation/bloc/journal_event.dart';
import 'package:starnyx/features/journal/presentation/bloc/journal_state.dart';
import 'package:starnyx/features/journal/presentation/pages/journal_detail_page.dart';
import 'package:starnyx/features/journal/presentation/pages/journal_editor_page.dart';
import 'package:starnyx/features/journal/presentation/widgets/journal_metadata.dart';
import 'package:starnyx/features/starnyx_form/presentation/widgets/starnyx_form_color_utils.dart';

/// Full-screen Journal tab.
///
/// Shows the entries of the active habit. Tapping the habit name in the header
/// opens the habit switcher; [reloadToken] makes the page re-read the active
/// habit (the shell bumps it whenever the tab is shown).
class JournalPage extends StatefulWidget {
  const JournalPage({
    this.bloc,
    this.loadActiveStarNyxUseCase,
    this.reloadToken = 0,
    super.key,
  });

  final JournalBloc? bloc;
  final LoadActiveStarNyxUseCase? loadActiveStarNyxUseCase;
  final int reloadToken;

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  late final JournalBloc _bloc;
  late final bool _ownsBloc;
  late final LoadActiveStarNyxUseCase _loadActive;
  final TextEditingController _draftController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  StarNyx? _habit;
  bool _resolving = true;
  bool _searchOpen = false;

  @override
  void initState() {
    super.initState();
    _ownsBloc = widget.bloc == null;
    _bloc = widget.bloc ?? serviceLocator<JournalBloc>();
    _loadActive =
        widget.loadActiveStarNyxUseCase ??
        serviceLocator<LoadActiveStarNyxUseCase>();
    _resolveHabit();
  }

  @override
  void didUpdateWidget(covariant JournalPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reloadToken != oldWidget.reloadToken) {
      _resolveHabit();
    }
  }

  @override
  void dispose() {
    if (_ownsBloc) {
      _bloc.close();
    }
    _draftController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _resolveHabit() async {
    StarNyx? habit;
    try {
      habit = await _loadActive();
    } catch (_) {
      habit = null;
    }
    if (!mounted) return;
    final changed = habit?.id != _habit?.id;
    setState(() {
      _habit = habit;
      _resolving = false;
    });
    if (habit != null && (changed || _bloc.state.starnyxId != habit.id)) {
      _bloc.add(JournalStarted(habit.id));
    }
  }

  Future<void> _openHabitSwitcher() async {
    await Navigator.of(context).pushNamed<Object?>(AppRoutes.habitList);
    if (mounted) await _resolveHabit();
  }

  void _toggleSearch() {
    setState(() {
      _searchOpen = !_searchOpen;
      if (!_searchOpen) _searchController.clear();
    });
  }

  void _onSendPressed() {
    if (!_bloc.state.canSaveDraft) return;
    _bloc.add(const JournalSaveRequested());
  }

  Future<void> _openEditor() async {
    await JournalEditorPage.open(context, bloc: _bloc);
    // The editor shares the bloc draft; mirror it back into the input bar.
    if (mounted) _draftController.text = _bloc.state.draftContent;
  }

  Future<void> _onDeletePressed(JournalEntry entry) async {
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: 'journal.delete_confirm_title'.tr(),
      message: 'journal.delete_confirm_message'.tr(),
      confirmLabel: 'journal.delete_confirm'.tr(),
      cancelLabel: 'journal.delete_cancel'.tr(),
      actionStyle: AppConfirmActionStyle.destructive,
    );
    if (confirmed == true && mounted) {
      _bloc.add(JournalDeleteRequested(entry));
    }
  }

  void _onStateChanged(BuildContext context, JournalState state) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (state.saveStatus == AsyncStatus.success) {
      _draftController.clear();
    } else if (state.saveStatus == AsyncStatus.failure) {
      messenger?.showSnackBar(
        SnackBar(content: Text('journal.save_general_error'.tr())),
      );
    } else if (state.deleteStatus == AsyncStatus.failure) {
      messenger?.showSnackBar(
        SnackBar(content: Text('journal.delete_general_error'.tr())),
      );
    } else if (state.deleteStatus == AsyncStatus.success &&
        state.recentlyDeletedEntry != null) {
      messenger?.showSnackBar(
        SnackBar(
          content: Text('journal.delete_undo_message'.tr()),
          action: SnackBarAction(
            label: 'journal.delete_undo_action'.tr(),
            onPressed: () => _bloc.add(const JournalDeleteUndoRequested()),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<JournalBloc>.value(
      value: _bloc,
      child: BlocListener<JournalBloc, JournalState>(
        listenWhen: (previous, current) =>
            previous.feedbackCount != current.feedbackCount,
        listener: _onStateChanged,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: <Widget>[
                _JournalHeader(
                  habit: _habit,
                  searchOpen: _searchOpen,
                  onSearchPressed: _toggleSearch,
                  onHabitPressed: _openHabitSwitcher,
                ),
                if (_searchOpen)
                  _JournalSearchField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                  ),
                Expanded(child: _buildBody()),
                if (_habit != null)
                  _JournalInputBar(
                    controller: _draftController,
                    onChanged: (value) => _bloc.add(JournalDraftChanged(value)),
                    onSendPressed: _onSendPressed,
                    onExpandPressed: _openEditor,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_resolving) {
      return const Center(child: AppLoadingIndicator());
    }
    final habit = _habit;
    if (habit == null) {
      return _CenteredPadding(
        child: AppEmptyState(
          title: 'habits.empty_title'.tr(),
          message: 'habits.empty_message'.tr(),
          icon: HugeIconsStrokeRounded.strokeRoundedBookOpen01,
        ),
      );
    }

    return BlocBuilder<JournalBloc, JournalState>(
      builder: (context, state) {
        if (state.status == JournalStatus.initial ||
            state.status == JournalStatus.loading) {
          return const Center(child: AppLoadingIndicator());
        }
        if (state.status == JournalStatus.failure) {
          return _CenteredPadding(
            child: AppErrorState(
              title: 'journal.load_error_title'.tr(),
              message: 'journal.load_error_message'.tr(),
              retryLabel: 'home.retry'.tr(),
              onRetry: () => _bloc.add(JournalStarted(habit.id)),
            ),
          );
        }
        if (state.entries.isEmpty) {
          return _CenteredPadding(
            child: AppEmptyState(
              title: 'journal.empty_title'.tr(),
              message: 'journal.empty_message'.tr(),
              icon: HugeIconsStrokeRounded.strokeRoundedBookOpen01,
            ),
          );
        }

        // ponytail: in-memory substring match on content and tags, fine for one
        // habit's notes.
        final query = _searchController.text.trim().toLowerCase();
        final entries = query.isEmpty
            ? state.entries
            : state.entries
                  .where(
                    (e) =>
                        e.content.toLowerCase().contains(query) ||
                        e.tags.any((t) => t.toLowerCase().contains(query)),
                  )
                  .toList(growable: false);
        if (entries.isEmpty) {
          return Center(
            child: Text(
              'journal.search_empty'.tr(),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          );
        }

        final accent = starnyxColorFromHex(habit.color);
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageHorizontal,
            AppSpacing.xs,
            AppSpacing.pageHorizontal,
            AppSpacing.lg,
          ),
          itemCount: entries.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final entry = entries[index];
            return JournalEntryCard(
              key: ValueKey<int>(entry.id),
              entry: entry,
              habitStartDate: habit.startDate,
              accentColor: accent,
              onTap: () => JournalDetailPage.open(
                context,
                bloc: _bloc,
                entry: entry,
                habit: habit,
              ),
              onLongPress: () => _onDeletePressed(entry),
            );
          },
        );
      },
    );
  }
}

class _CenteredPadding extends StatelessWidget {
  const _CenteredPadding({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
        child: child,
      ),
    );
  }
}

class _JournalHeader extends StatelessWidget {
  const _JournalHeader({
    required this.habit,
    required this.searchOpen,
    required this.onSearchPressed,
    required this.onHabitPressed,
  });

  final StarNyx? habit;
  final bool searchOpen;
  final VoidCallback onSearchPressed;
  final VoidCallback onHabitPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final habit = this.habit;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.sm,
        AppSpacing.pageHorizontal,
        AppSpacing.md,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'journal.title'.tr(),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontFamily: AppFonts.headline,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (habit != null)
                  Semantics(
                    button: true,
                    label: 'journal.switch_habit_semantics'.tr(),
                    child: InkWell(
                      key: const Key('journal-habit-switcher'),
                      onTap: onHabitPressed,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.xxs,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                habit.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontFamily: AppFonts.mono,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            const AppIcon(
                              icon: HugeIconsStrokeRounded
                                  .strokeRoundedArrowDown01,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (habit != null)
            _CircleIconButton(
              key: const Key('journal-search-button'),
              icon: searchOpen
                  ? HugeIconsStrokeRounded.strokeRoundedCancel01
                  : HugeIconsStrokeRounded.strokeRoundedSearch01,
              semanticsLabel: searchOpen
                  ? 'journal.search_close_semantics'.tr()
                  : 'journal.search_semantics'.tr(),
              onPressed: onSearchPressed,
            ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.semanticsLabel,
    required this.onPressed,
    super.key,
  });

  final List<List<dynamic>> icon;
  final String semanticsLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: Material(
        color: AppColors.surfaceLevel2,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox.square(
            dimension: AppSize.iconButton,
            child: Center(
              child: AppIcon(
                icon: icon,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _JournalSearchField extends StatelessWidget {
  const _JournalSearchField({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        0,
        AppSpacing.pageHorizontal,
        AppSpacing.md,
      ),
      child: TextField(
        key: const Key('journal-search-field'),
        controller: controller,
        autofocus: true,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(hintText: 'journal.search_hint'.tr()),
      ),
    );
  }
}

/// One journal entry card: accent dot, title, mono timestamp, clamped body,
/// then mood and tag chips when the entry has them.
class JournalEntryCard extends StatelessWidget {
  const JournalEntryCard({
    required this.entry,
    required this.habitStartDate,
    required this.accentColor,
    this.onTap,
    this.onLongPress,
    super.key,
  });

  static const int collapsedMaxLines = 4;

  final JournalEntry entry;
  final DateTime habitStartDate;
  final Color accentColor;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (title, body) = journalTitleAndBody(entry, habitStartDate);
    final mood = entry.mood;
    final tags = entry.tags;
    final bodyStyle = theme.textTheme.bodyMedium?.copyWith(
      fontFamily: AppFonts.body,
      height: 1.6,
      color: AppColors.textSecondary,
    );

    return Material(
      color: AppColors.surfaceLevel1,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: AppSpacing.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.7),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontFamily: AppFonts.headline,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    core_date_utils.DateUtils.formatShortDateTime(
                      entry.createdAt,
                      context.locale.toLanguageTag(),
                    ),
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontFamily: AppFonts.mono,
                      fontFeatures: AppFonts.tabularFigures,
                      letterSpacing: 0.6,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              LayoutBuilder(
                builder: (context, constraints) {
                  final overflows = (TextPainter(
                    text: TextSpan(text: body, style: bodyStyle),
                    maxLines: JournalEntryCard.collapsedMaxLines,
                    textDirection: Directionality.of(context),
                    textScaler: MediaQuery.textScalerOf(context),
                  )..layout(maxWidth: constraints.maxWidth)).didExceedMaxLines;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        body,
                        maxLines: JournalEntryCard.collapsedMaxLines,
                        overflow: TextOverflow.ellipsis,
                        style: bodyStyle,
                      ),
                      if (overflows)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.xxs),
                          child: Text(
                            'journal.read_more'.tr(),
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              if (mood != null || tags.isNotEmpty) ...<Widget>[
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: <Widget>[
                    if (mood != null)
                      JournalMetaChip(
                        label: mood.label,
                        color: mood.color,
                        icon: mood.icon,
                      ),
                    for (final tag in tags)
                      JournalMetaChip(
                        label: '#$tag',
                        color: AppColors.textSecondary,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _JournalInputBar extends StatelessWidget {
  const _JournalInputBar({
    required this.controller,
    required this.onChanged,
    required this.onSendPressed,
    required this.onExpandPressed,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onSendPressed;
  final VoidCallback onExpandPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.xs,
        AppSpacing.pageHorizontal,
        AppSpacing.sm,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceLevel3.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: AppColors.borderSubtle),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.8),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Row(
            children: <Widget>[
              IconButton(
                key: const Key('journal-expand-button'),
                tooltip: 'journal.editor_open_semantics'.tr(),
                onPressed: onExpandPressed,
                icon: const AppIcon(
                  icon: HugeIconsStrokeRounded.strokeRoundedArrowExpand01,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
              ),
              Expanded(
                child: TextField(
                  key: const Key('journal-input'),
                  controller: controller,
                  onChanged: onChanged,
                  minLines: 1,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  inputFormatters: <TextInputFormatter>[
                    LengthLimitingTextInputFormatter(4000),
                  ],
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: AppFonts.body,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'journal.today_hint'.tr(),
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              BlocBuilder<JournalBloc, JournalState>(
                buildWhen: (previous, current) =>
                    previous.canSaveDraft != current.canSaveDraft ||
                    previous.saveStatus != current.saveStatus,
                builder: (context, state) {
                  final enabled = state.canSaveDraft;
                  return Semantics(
                    button: true,
                    enabled: enabled,
                    label: 'journal.send_semantics'.tr(),
                    child: Material(
                      color: enabled
                          ? AppColors.tertiary
                          : AppColors.surfaceLevel2,
                      shape: const CircleBorder(),
                      child: InkWell(
                        key: const Key('journal-send-button'),
                        onTap: enabled ? onSendPressed : null,
                        customBorder: const CircleBorder(),
                        child: SizedBox.square(
                          dimension: AppSize.iconButton,
                          child: Center(
                            child: state.saveStatus == AsyncStatus.inProgress
                                ? const SizedBox.square(
                                    dimension: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.onTertiary,
                                    ),
                                  )
                                : AppIcon(
                                    icon: HugeIconsStrokeRounded
                                        .strokeRoundedSent,
                                    size: 20,
                                    color: enabled
                                        ? AppColors.onTertiary
                                        : AppColors.textTertiary,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
