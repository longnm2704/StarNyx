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
    barrierColor: AppColors.black.withValues(alpha: 0.8),
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
            // Scroll to bottom when new message is added.
            // Since entries are DESC, top is newest.
            _scrollController.animateTo(
              0,
              duration: AppDurations.medium,
              curve: Curves.easeOut,
            );
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
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl * 1.25)),
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
                  _JournalHeader(),
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
                          reverse: true, // Newest at the bottom of the list view (above input)
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
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (showDateHeader) _DateHeader(date: entry.date),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                                  child: _JournalChatBubble(
                                    entry: entry,
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
                    isSaving: false, // Handled by BLoC state in listener/builder
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
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
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
              size: 20,
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

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Text(
          formattedDate,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
        ),
      ),
    );
  }
}

class _JournalChatBubble extends StatelessWidget {
  const _JournalChatBubble({required this.entry, required this.onDeletePressed});

  final JournalEntry entry;
  final VoidCallback onDeletePressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onDeletePressed,
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8E5BFF), Color(0xFFD875FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(4),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentViolet.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                entry.content,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('HH:mm').format(entry.createdAt),
                style: TextStyle(
                  color: AppColors.white.withValues(alpha: 0.7),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JournalInputArea extends StatelessWidget {
  const _JournalInputArea({
    required this.controller,
    required this.onChanged,
    required this.onSavePressed,
    required this.isSaving,
    required this.bottomPadding,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onSavePressed;
  final bool isSaving;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JournalBloc, JournalState>(
      builder: (context, state) {
        final canSave = state.canSaveDraft;

        return Container(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.md + bottomPadding,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.95),
            border: Border(top: BorderSide(color: AppColors.white.withValues(alpha: 0.08))),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.background.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.white.withValues(alpha: 0.1)),
                  ),
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    maxLines: 4,
                    minLines: 1,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'journal.today_hint'.tr(),
                      hintStyle: const TextStyle(color: AppColors.textMuted),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: canSave ? onSavePressed : null,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      gradient: canSave ? AppColors.accentGradient : null,
                      color: canSave ? null : AppColors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
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
                          : Icon(
                              Icons.send_rounded,
                              size: 20,
                              color: canSave ? AppColors.white : AppColors.textMuted,
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
