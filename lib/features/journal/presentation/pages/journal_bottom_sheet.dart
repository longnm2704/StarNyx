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

Future<void> showJournalBottomSheet(BuildContext context, String starnyxId, Color accentColor) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: false,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.black.withValues(alpha: 0.8),
    builder: (BuildContext context) {
      return JournalBottomSheet(starnyxId: starnyxId, accentColor: accentColor);
    },
  );
}

class JournalBottomSheet extends StatefulWidget {
  const JournalBottomSheet({required this.starnyxId, required this.accentColor, super.key});

  final String starnyxId;
  final Color accentColor;

  @override
  State<JournalBottomSheet> createState() => _JournalBottomSheetState();
}

class _JournalBottomSheetState extends State<JournalBottomSheet> {
  late final JournalBloc _journalBloc;
  late final TextEditingController _controller;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _journalBloc = serviceLocator<JournalBloc>()..add(JournalStarted(widget.starnyxId));
    _controller = TextEditingController();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _journalBloc.close();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSavePressed() {
    if (_journalBloc.state.saveStatus == AsyncStatus.inProgress) {
      return;
    }
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
      _journalBloc.add(JournalDeleteRequested(entry.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.viewInsets.bottom;

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
            // Close keyboard after success
            FocusScope.of(context).unfocus();
            
            // Ensure the list is updated and attached before scrolling
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  0,
                  duration: AppDurations.medium,
                  curve: Curves.easeOut,
                );
              }
            });
          } else if (state.saveStatus == AsyncStatus.failure && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        child: FractionallySizedBox(
          heightFactor: 0.94,
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl * 1.5)),
            ),
            child: CosmicBackground(
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.sm),
                  Center(
                    child: Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                  ),
                  _JournalHeader(accentColor: widget.accentColor),
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

                        if (state.entries.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 64),
                              child: AppEmptyState(
                                title: 'journal.title'.tr(),
                                message: 'journal.no_entries'.tr(),
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          controller: _scrollController,
                          reverse: true, // Newest at the bottom (above input)
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.pageHorizontal,
                            AppSpacing.md,
                            AppSpacing.pageHorizontal,
                            AppSpacing.xl,
                          ),
                          itemCount: state.entries.length,
                          itemBuilder: (context, index) {
                            final entry = state.entries[index];
                            final showDateHeader = index == state.entries.length - 1 ||
                                !core_date_utils.DateUtils.isSameDate(
                                  entry.date,
                                  state.entries[index + 1].date,
                                );

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (showDateHeader) _DateHeader(date: entry.date),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                                  child: _JournalEntryCard(
                                    entry: entry,
                                    accentColor: widget.accentColor,
                                    onDeletePressed: () => _onDeletePressed(entry),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                  _JournalInputArea(
                    controller: _controller,
                    onChanged: (value) => _journalBloc.add(JournalDraftChanged(value)),
                    onSavePressed: _onSavePressed,
                    accentColor: widget.accentColor,
                    bottomPadding: bottomPadding,
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

class _JournalHeader extends StatelessWidget {
  const _JournalHeader({required this.accentColor});

  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'journal.title'.tr(),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 40,
                  height: 3,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white.withValues(alpha: 0.1)),
                ),
                child: const AppSvgIcon(
                  assetPath: 'assets/icons/ic_close.svg',
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final formattedDate = core_date_utils.DateUtils.isSameDate(
      date,
      core_date_utils.DateUtils.nowDate(),
    )
        ? 'Today'
        : core_date_utils.DateUtils.formatDdMmYyyy(date);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              formattedDate.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.white.withValues(alpha: 0.05),
            ),
          ),
        ],
      ),
    );
  }
}

class _JournalEntryCard extends StatelessWidget {
  const _JournalEntryCard({
    required this.entry,
    required this.accentColor,
    required this.onDeletePressed,
  });

  final JournalEntry entry;
  final Color accentColor;
  final VoidCallback onDeletePressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                DateFormat('HH:mm').format(entry.createdAt),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: accentColor.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const Spacer(),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onDeletePressed,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: AppSvgIcon(
                      assetPath: 'assets/icons/ic_trash.svg',
                      color: AppColors.textMuted.withValues(alpha: 0.4),
                      size: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            entry.content,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textPrimary.withValues(alpha: 0.9),
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }
}

class _JournalInputArea extends StatelessWidget {
  const _JournalInputArea({
    required this.controller,
    required this.onChanged,
    required this.onSavePressed,
    required this.accentColor,
    required this.bottomPadding,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onSavePressed;
  final Color accentColor;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JournalBloc, JournalState>(
      builder: (context, state) {
        final canSave = state.canSaveDraft;

        return Container(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.pageHorizontal,
            AppSpacing.md,
            AppSpacing.pageHorizontal,
            AppSpacing.lg + bottomPadding,
          ),
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: 0.8),
            border: Border(top: BorderSide(color: AppColors.white.withValues(alpha: 0.05))),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(
                      color: canSave ? accentColor.withValues(alpha: 0.3) : AppColors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    maxLines: 5,
                    minLines: 1,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'journal.today_hint'.tr(),
                      hintStyle: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.6)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: canSave ? onSavePressed : null,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: AnimatedContainer(
                    duration: AppDurations.fast,
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: canSave ? accentColor : AppColors.white.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                      boxShadow: canSave ? [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ] : null,
                    ),
                    child: Center(
                      child: state.saveStatus == AsyncStatus.inProgress
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                              ),
                            )
                          : const Icon(
                              Icons.send_rounded,
                              size: 22,
                              color: AppColors.white,
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
