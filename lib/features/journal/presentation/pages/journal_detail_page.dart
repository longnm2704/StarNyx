import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:starnyx/app/di/service_locator.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/core/utils/streak_utils.dart';
import 'package:starnyx/core/widgets/core_widgets.dart';
import 'package:starnyx/domain/entities/journal_entry.dart';
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:starnyx/domain/repositories/completion_repository.dart';
import 'package:starnyx/features/journal/presentation/bloc/journal_bloc.dart';
import 'package:starnyx/features/journal/presentation/bloc/journal_event.dart';
import 'package:starnyx/features/journal/presentation/bloc/journal_state.dart';
import 'package:starnyx/features/journal/presentation/pages/journal_editor_page.dart';
import 'package:starnyx/features/journal/presentation/widgets/journal_metadata.dart';
import 'package:starnyx/features/starnyx_form/presentation/widgets/starnyx_form_color_utils.dart';

/// First line written as a quote (`> text`, `“text”` or `"text"`), or null.
String? journalPullQuote(String content) {
  for (final raw in content.split('\n')) {
    final line = raw.trim();
    if (line.startsWith('>')) {
      final quote = line.substring(1).trim();
      if (quote.isNotEmpty) return quote;
    } else if (line.length > 2 &&
        ((line.startsWith('“') && line.endsWith('”')) ||
            (line.startsWith('"') && line.endsWith('"')))) {
      return line.substring(1, line.length - 1).trim();
    }
  }
  return null;
}

/// Read-only view of one journal entry with its metadata, habit context and
/// edit / delete actions. Reads the entry from [JournalBloc] so edits show up
/// right away; deleting dispatches to the bloc and pops.
class JournalDetailPage extends StatefulWidget {
  const JournalDetailPage({
    required this.entry,
    required this.habit,
    this.completionRepository,
    super.key,
  });

  final JournalEntry entry;
  final StarNyx habit;
  final CompletionRepository? completionRepository;

  static Future<void> open(
    BuildContext context, {
    required JournalBloc bloc,
    required JournalEntry entry,
    required StarNyx habit,
    CompletionRepository? completionRepository,
  }) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider<JournalBloc>.value(
          value: bloc,
          child: JournalDetailPage(
            entry: entry,
            habit: habit,
            completionRepository: completionRepository,
          ),
        ),
      ),
    );
  }

  @override
  State<JournalDetailPage> createState() => _JournalDetailPageState();
}

class _JournalDetailPageState extends State<JournalDetailPage> {
  late final Future<(int, int)> _stats = _loadStats();

  /// (completion count up to and including the entry date, current streak).
  Future<(int, int)> _loadStats() async {
    final repository =
        widget.completionRepository ?? serviceLocator<CompletionRepository>();
    final days = (await repository.getCompletionsForStarnyx(
      widget.habit.id,
    )).where((c) => c.completed).map((c) => DateUtils.dateOnly(c.date)).toSet();
    final entryDay = DateUtils.dateOnly(widget.entry.date);
    return (
      days.where((d) => !d.isAfter(entryDay)).length,
      StreakUtils.currentStreak(completionDates: days),
    );
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
    if (confirmed != true || !mounted) return;
    // The journal list listens to the same bloc and offers undo.
    context.read<JournalBloc>().add(JournalDeleteRequested(entry));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<JournalBloc, JournalState>(
      builder: (context, state) {
        final entry =
            state.entries.where((e) => e.id == widget.entry.id).firstOrNull ??
            widget.entry;
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            leading: IconButton(
              key: const Key('journal-detail-back'),
              tooltip: 'journal.editor_close'.tr(),
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const AppIcon(
                icon: HugeIconsStrokeRounded.strokeRoundedArrowLeft01,
                color: AppColors.textSecondary,
              ),
            ),
            title: Text(
              'journal.detail_title'.tr(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontFamily: AppFonts.headline,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            actions: <Widget>[
              PopupMenuButton<bool>(
                key: const Key('journal-detail-menu'),
                onSelected: (_) => _onDeletePressed(entry),
                tooltip: 'journal.detail_menu_semantics'.tr(),
                color: AppColors.sheet,
                icon: const AppIcon(
                  icon: HugeIconsStrokeRounded.strokeRoundedMoreVertical,
                  color: AppColors.textSecondary,
                ),
                itemBuilder: (_) => <PopupMenuEntry<bool>>[
                  PopupMenuItem<bool>(
                    key: const Key('journal-detail-menu-delete'),
                    value: true,
                    child: Text(
                      'journal.detail_delete'.tr(),
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal,
                AppSpacing.xs,
                AppSpacing.pageHorizontal,
                AppSpacing.xl,
              ),
              children: <Widget>[
                _MetaRow(habit: widget.habit, entry: entry, stats: _stats),
                if (entry.mood != null ||
                    entry.energy != null ||
                    entry.sleepMinutes != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.lg),
                  _ReflectionCard(entry: entry),
                ],
                const SizedBox(height: AppSpacing.lg),
                _ContentCard(entry: entry, habit: widget.habit),
                _StreakSection(stats: _stats),
                if (entry.tags.isNotEmpty) ...<Widget>[
                  const SizedBox(height: AppSpacing.lg),
                  _SectionLabel('journal.tags_title'.tr()),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: <Widget>[
                      for (final tag in entry.tags)
                        JournalMetaChip(
                          label: '#$tag',
                          color: AppColors.textSecondary,
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                AppPrimaryButton(
                  key: const Key('journal-detail-edit'),
                  label: 'journal.editor_edit_title'.tr(),
                  onPressed: () => JournalEditorPage.open(
                    context,
                    bloc: context.read<JournalBloc>(),
                    entry: entry,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Center(
                  child: TextButton.icon(
                    key: const Key('journal-detail-delete'),
                    onPressed: () => _onDeletePressed(entry),
                    icon: const AppIcon(
                      icon: HugeIconsStrokeRounded.strokeRoundedDelete02,
                      size: 16,
                      color: AppColors.error,
                    ),
                    label: Text(
                      'journal.detail_delete'.tr(),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, {this.color = AppColors.textSecondary});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        fontFamily: AppFonts.mono,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        color: color,
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label, required this.color});

  final List<List<dynamic>> icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AppIcon(icon: icon, size: 14, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.habit,
    required this.entry,
    required this.stats,
  });

  final StarNyx habit;
  final JournalEntry entry;
  final Future<(int, int)> stats;

  @override
  Widget build(BuildContext context) {
    final locale = context.locale.toLanguageTag();
    final habitLabel = habit.hasReminder
        ? 'journal.detail_habit_goal'.tr(
            args: <String>[habit.title, habit.reminderTime!],
          )
        : habit.title;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: <Widget>[
            _Pill(
              icon: HabitSymbols.iconFor(habit.icon),
              label: habitLabel,
              color: starnyxColorFromHex(habit.color),
            ),
            FutureBuilder<(int, int)>(
              future: stats,
              builder: (context, snapshot) {
                final count = snapshot.data?.$1 ?? 0;
                if (count == 0) return const SizedBox.shrink();
                return _Pill(
                  icon: HugeIconsStrokeRounded.strokeRoundedSparkles,
                  label: 'journal.detail_lumen'.tr(args: <String>['$count']),
                  color: AppColors.primary,
                );
              },
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: <Widget>[
            const AppIcon(
              icon: HugeIconsStrokeRounded.strokeRoundedCalendar03,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                'journal.detail_saved_at'.tr(
                  args: <String>[
                    toBeginningOfSentenceCase(
                      DateFormat.yMMMMEEEEd(locale).format(entry.date),
                      locale,
                    ),
                    DateFormat('HH:mm').format(entry.createdAt),
                  ],
                ),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontFamily: AppFonts.mono,
                  fontFeatures: AppFonts.tabularFigures,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

BoxDecoration _cardDecoration() => BoxDecoration(
  color: AppColors.surfaceLevel1,
  borderRadius: BorderRadius.circular(AppRadius.lg),
  border: Border.all(color: AppColors.borderSubtle),
);

class _ReflectionCard extends StatelessWidget {
  const _ReflectionCard({required this.entry});

  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    final mood = entry.mood;
    final energy = entry.energy;
    final sleep = entry.sleepMinutes;
    return Container(
      key: const Key('journal-detail-reflection'),
      padding: AppSpacing.cardPadding,
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _SectionLabel('journal.detail_reflection_title'.tr()),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: <Widget>[
              if (mood != null)
                _ReflectionTile(
                  icon: mood.icon,
                  color: mood.color,
                  label: 'journal.mood_title'.tr(),
                  value: Text(mood.label, style: _valueStyle(context)),
                ),
              if (energy != null)
                _ReflectionTile(
                  icon: HugeIconsStrokeRounded.strokeRoundedFlash,
                  color: AppColors.primary,
                  label: 'journal.energy_title'.tr(),
                  value: Semantics(
                    label: 'journal.energy_level_semantics'.tr(
                      args: <String>['$energy'],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        for (var i = 1; i <= JournalEntry.maxEnergy; i++)
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: i <= energy
                                  ? AppColors.primary
                                  : AppColors.surfaceLevel3,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              if (sleep != null)
                _ReflectionTile(
                  icon: HugeIconsStrokeRounded.strokeRoundedMoon02,
                  color: AppColors.tertiary,
                  label: 'journal.sleep_title'.tr(),
                  value: Text(
                    formatSleepMinutes(sleep),
                    style: _valueStyle(context)?.copyWith(
                      fontFamily: AppFonts.mono,
                      fontFeatures: AppFonts.tabularFigures,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  TextStyle? _valueStyle(BuildContext context) => Theme.of(context)
      .textTheme
      .labelLarge
      ?.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary);
}

class _ReflectionTile extends StatelessWidget {
  const _ReflectionTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final List<List<dynamic>> icon;
  final Color color;
  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceLevel2,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: AppIcon(icon: icon, size: 18, color: color),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xxs),
            value,
          ],
        ),
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  const _ContentCard({required this.entry, required this.habit});

  final JournalEntry entry;
  final StarNyx habit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (title, rawBody) = journalTitleAndBody(entry, habit.startDate);
    final quote = journalPullQuote(entry.content);
    // The pull quote gets its own block below; don't print its line twice.
    final body = quote == null
        ? rawBody
        : rawBody
              .split('\n')
              .where((line) => journalPullQuote(line) != quote)
              .join('\n')
              .trim();
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const AppIcon(
                icon: HugeIconsStrokeRounded.strokeRoundedNoteEdit,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
              _SectionLabel('journal.detail_deep_title'.tr()),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontFamily: AppFonts.headline,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          if (body.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            SelectableText(
              body,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontFamily: AppFonts.body,
                height: 1.6,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (quote != null) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            Container(
              key: const Key('journal-detail-quote'),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xs,
                0,
                AppSpacing.xs,
              ),
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(color: AppColors.primary, width: 3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _SectionLabel(
                    'journal.detail_quote_title'.tr(),
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '“$quote”',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontFamily: AppFonts.headline,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StreakSection extends StatelessWidget {
  const _StreakSection({required this.stats});

  final Future<(int, int)> stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<(int, int)>(
      future: stats,
      builder: (context, snapshot) {
        final streak = snapshot.data?.$2;
        if (streak == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'journal.detail_stats_title'.tr(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: AppFonts.headline,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                key: const Key('journal-detail-streak'),
                padding: AppSpacing.cardPadding,
                decoration: _cardDecoration(),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'journal.detail_streak_label'.tr(),
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text.rich(
                            TextSpan(
                              text: '$streak',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontFamily: AppFonts.mono,
                                fontFeatures: AppFonts.tabularFigures,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              children: <InlineSpan>[
                                TextSpan(
                                  text: ' ${'journal.detail_streak_unit'.tr()}',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: AppColors.tertiary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const AppIcon(
                        icon: HugeIconsStrokeRounded.strokeRoundedFire,
                        size: 18,
                        color: AppColors.tertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
