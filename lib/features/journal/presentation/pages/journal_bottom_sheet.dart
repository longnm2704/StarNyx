import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:starnyx/app/di/service_locator.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/core/widgets/core_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:starnyx/domain/entities/journal_entry.dart';
import 'package:starnyx/features/journal/presentation/bloc/journal_bloc.dart';
import 'package:starnyx/features/journal/presentation/bloc/journal_event.dart';
import 'package:starnyx/features/journal/presentation/bloc/journal_state.dart';
import 'package:starnyx/features/starnyx_form/presentation/widgets/starnyx_form_header.dart';
import 'package:starnyx/features/starnyx_form/presentation/widgets/starnyx_form_pill_text_field.dart';

const LinearGradient _sheetTopDownGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: <Color>[AppColors.sheetTop, AppColors.sheetMid, AppColors.background],
  stops: <double>[0.0, 0.48, 1.0],
);

Future<void> showJournalBottomSheet(BuildContext context, String starnyxId, Color accentColor) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: false,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.black.withValues(alpha: 0.72),
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
  late final ScrollController _scrollController;
  String _draftContent = '';

  @override
  void initState() {
    super.initState();
    _journalBloc = serviceLocator<JournalBloc>()..add(JournalStarted(widget.starnyxId));
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _journalBloc.close();
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
    final topInset = mediaQuery.viewPadding.top > 0 ? mediaQuery.viewPadding.top : mediaQuery.padding.top;
    final headerTopPadding = (topInset < 24 ? 24.0 : topInset) + AppSpacing.lg;
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
            setState(() {
              _draftContent = '';
            });
            FocusScope.of(context).unfocus();
            
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
          heightFactor: 1.0,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: _sheetTopDownGradient,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl * 1.5)),
            ),
            child: SafeArea(
              top: false,
              bottom: false,
              child: Stack(
                children: [
                  const Positioned.fill(child: CosmicBackground(child: SizedBox.expand())),
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.pageHorizontal,
                          headerTopPadding,
                          AppSpacing.pageHorizontal,
                          AppSpacing.md,
                        ),
                        child: StarnyxFormHeader(
                          title: 'journal.title'.tr(),
                          onClosePressed: () => Navigator.of(context).pop(),
                        ),
                      ),
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
                              return const SizedBox.expand();
                            }

                            return ListView.builder(
                              controller: _scrollController,
                              reverse: true,
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.pageHorizontal,
                                AppSpacing.md,
                                AppSpacing.pageHorizontal,
                                AppSpacing.xl,
                              ),
                              itemCount: state.entries.length,
                              itemBuilder: (context, index) {
                                final entry = state.entries[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                                  child: _JournalEntryCard(
                                    entry: entry,
                                    accentColor: widget.accentColor,
                                    onDeletePressed: () => _onDeletePressed(entry),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      _JournalInputArea(
                        initialValue: _draftContent,
                        onChanged: (value) {
                          _draftContent = value;
                          _journalBloc.add(JournalDraftChanged(value));
                        },
                        onSavePressed: _onSavePressed,
                        accentColor: widget.accentColor,
                        bottomPadding: bottomPadding,
                      ),
                    ],
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
    final formattedFullDate = DateFormat('dd/MM/yyyy HH:mm').format(entry.createdAt);

    return GestureDetector(
      onLongPress: onDeletePressed,
      behavior: HitTestBehavior.translucent,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.content,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textPrimary.withValues(alpha: 0.9),
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              formattedFullDate,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textMuted.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              height: 1,
              width: 40,
              color: AppColors.white.withValues(alpha: 0.05),
            ),
          ],
        ),
      ),
    );
  }
}

class _JournalInputArea extends StatelessWidget {
  const _JournalInputArea({
    required this.initialValue,
    required this.onChanged,
    required this.onSavePressed,
    required this.accentColor,
    required this.bottomPadding,
  });

  final String initialValue;
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
            AppSpacing.md + bottomPadding,
          ),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border(top: BorderSide(color: AppColors.white.withValues(alpha: 0.05))),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: StarnyxFormPillTextField(
                  initialValue: initialValue,
                  hintText: 'journal.today_hint'.tr(),
                  maxLines: 1,
                  onChanged: onChanged,
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
