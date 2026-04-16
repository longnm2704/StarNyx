import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:starnyx/app/di/service_locator.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/core/utils/date_utils.dart' as core_date_utils;
import 'package:starnyx/core/widgets/core_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:starnyx/domain/entities/journal_entry.dart';
import 'package:starnyx/features/journal/presentation/bloc/journal_bloc.dart';
import 'package:starnyx/features/journal/presentation/bloc/journal_event.dart';
import 'package:starnyx/features/journal/presentation/bloc/journal_state.dart';

Future<void> showJournalBottomSheet(BuildContext context, String starnyxId) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: false,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.black.withValues(alpha: 0.72),
    builder: (BuildContext context) {
      return JournalBottomSheet(starnyxId: starnyxId);
    },
  );
}

class JournalBottomSheet extends StatefulWidget {
  const JournalBottomSheet({required this.starnyxId, super.key});

  final String starnyxId;

  @override
  State<JournalBottomSheet> createState() => _JournalBottomSheetState();
}

class _JournalBottomSheetState extends State<JournalBottomSheet> {
  late final JournalBloc _journalBloc;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _journalBloc = serviceLocator<JournalBloc>()..add(JournalStarted(widget.starnyxId));
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _journalBloc.close();
    _controller.dispose();
    super.dispose();
  }

  void _onSavePressed() {
    _journalBloc.add(const JournalSaveRequested());
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
      _journalBloc.add(JournalDeleteRequested(entry.date));
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topInset = mediaQuery.viewPadding.top > 0
        ? mediaQuery.viewPadding.top
        : mediaQuery.padding.top;

    return BlocProvider<JournalBloc>.value(
      value: _journalBloc,
      child: BlocListener<JournalBloc, JournalState>(
        listenWhen: (previous, current) =>
            previous.saveStatus != current.saveStatus ||
            previous.deleteStatus != current.deleteStatus ||
            previous.feedbackCount != current.feedbackCount,
        listener: (context, state) {
          if (state.saveStatus == AsyncStatus.success) {
            _controller.clear();
          } else if (state.saveStatus == AsyncStatus.failure && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
          if (state.deleteStatus == AsyncStatus.failure && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        child: FractionallySizedBox(
          heightFactor: 0.92,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
            ),
            child: Column(
              children: [
                _JournalHeader(topInset: topInset),
                Expanded(
                  child: BlocBuilder<JournalBloc, JournalState>(
                    builder: (context, state) {
                      if (state.status == JournalStatus.loading) {
                        return const Center(child: AppLoadingIndicator());
                      }

                      if (state.status == JournalStatus.failure) {
                        return Center(
                          child: AppErrorState(
                            title: 'journal.load_error_title'.tr(),
                            message: state.errorMessage ?? 'journal.load_error_message'.tr(),
                            retryLabel: 'home.retry'.tr(),
                            onRetry: () => _journalBloc.add(JournalStarted(widget.starnyxId)),
                          ),
                        );
                      }

                      final today = core_date_utils.DateUtils.nowDate();
                      final hasEntryForToday = state.entries.any(
                        (entry) => core_date_utils.DateUtils.isSameDate(entry.date, today),
                      );

                      return CustomScrollView(
                        slivers: [
                          if (!hasEntryForToday)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
                                child: _TodayEntryInput(
                                  controller: _controller,
                                  onChanged: (value) =>
                                      _journalBloc.add(JournalDraftChanged(value)),
                                  onSavePressed: _onSavePressed,
                                  isSaving: state.saveStatus == AsyncStatus.inProgress,
                                  isEnabled: state.canSaveDraft,
                                ),
                              ),
                            ),
                          if (state.entries.isEmpty)
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: Center(
                                child: AppEmptyState(
                                  title: 'journal.title'.tr(),
                                  message: 'journal.no_entries'.tr(),
                                ),
                              ),
                            )
                          else
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.pageHorizontal,
                                vertical: AppSpacing.md,
                              ),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final entry = state.entries[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                                      child: _JournalEntryCard(
                                        entry: entry,
                                        onDeletePressed: () => _onDeletePressed(entry),
                                      ),
                                    );
                                  },
                                  childCount: state.entries.length,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _JournalHeader extends StatelessWidget {
  const _JournalHeader({required this.topInset});

  final double topInset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        (topInset < 16 ? 16.0 : topInset * 0.5) + AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.4),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'journal.title'.tr(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const AppSvgIcon(
              assetPath: 'assets/icons/ic_close.svg',
              color: AppColors.textSecondary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayEntryInput extends StatelessWidget {
  const _TodayEntryInput({
    required this.controller,
    required this.onChanged,
    required this.onSavePressed,
    required this.isSaving,
    required this.isEnabled,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onSavePressed;
  final bool isSaving;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: controller,
            onChanged: onChanged,
            maxLines: 4,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textPrimary,
                ),
            decoration: InputDecoration(
              hintText: 'journal.today_hint'.tr(),
              hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textMuted,
                  ),
              border: InputBorder.none,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerRight,
            child: isSaving
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : TextButton(
                    onPressed: isEnabled ? onSavePressed : null,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.accentPink,
                      disabledForegroundColor: AppColors.textMuted,
                      textStyle: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    child: Text('journal.save_button'.tr()),
                  ),
          ),
        ],
      ),
    );
  }
}

class _JournalEntryCard extends StatelessWidget {
  const _JournalEntryCard({required this.entry, required this.onDeletePressed});

  final JournalEntry entry;
  final VoidCallback onDeletePressed;

  @override
  Widget build(BuildContext context) {
    final formattedDate = core_date_utils.DateUtils.formatDdMmYyyy(entry.date);
    final isToday = core_date_utils.DateUtils.isSameDate(
      entry.date,
      core_date_utils.DateUtils.nowDate(),
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isToday ? AppColors.accentPink.withValues(alpha: 0.3) : AppColors.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  isToday ? '$formattedDate (Today)' : formattedDate,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isToday ? AppColors.accentPink : AppColors.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              IconButton(
                onPressed: onDeletePressed,
                icon: const AppSvgIcon(
                  assetPath: 'assets/icons/ic_trash.svg',
                  color: AppColors.textMuted,
                  size: 16,
                ),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            entry.content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
