import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/core/widgets/app_icon.dart';
import 'package:starnyx/domain/entities/journal_entry.dart';
import 'package:starnyx/features/journal/presentation/bloc/journal_bloc.dart';
import 'package:starnyx/features/journal/presentation/bloc/journal_event.dart';
import 'package:starnyx/features/journal/presentation/bloc/journal_state.dart';

/// Full-screen journal editor.
///
/// Create mode ([entry] is null) edits the shared draft of [JournalBloc] and
/// saves it as a new entry for today. Edit mode updates [entry] in place,
/// keeping its `id` and `createdAt`. Pops with `true` once saved.
class JournalEditorPage extends StatefulWidget {
  const JournalEditorPage({this.entry, super.key});

  final JournalEntry? entry;

  /// Pushes the editor on top of the current route, sharing [bloc].
  static Future<bool?> open(
    BuildContext context, {
    required JournalBloc bloc,
    JournalEntry? entry,
  }) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => BlocProvider<JournalBloc>.value(
          value: bloc,
          child: JournalEditorPage(entry: entry),
        ),
      ),
    );
  }

  @override
  State<JournalEditorPage> createState() => _JournalEditorPageState();
}

class _JournalEditorPageState extends State<JournalEditorPage> {
  late final TextEditingController _controller;

  bool get _isEdit => widget.entry != null;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text:
          widget.entry?.content ??
          context.read<JournalBloc>().state.draftContent,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  AsyncStatus _status(JournalState state) =>
      _isEdit ? state.updateStatus : state.saveStatus;

  void _onChanged(String value) {
    // Create mode shares the inline input bar's draft.
    if (!_isEdit) context.read<JournalBloc>().add(JournalDraftChanged(value));
    setState(() {});
  }

  void _onSavePressed() {
    final bloc = context.read<JournalBloc>();
    final entry = widget.entry;
    if (entry == null) {
      bloc.add(const JournalSaveRequested());
    } else {
      bloc.add(JournalEntryUpdated(entry, content: _controller.text));
    }
  }

  void _onStateChanged(BuildContext context, JournalState state) {
    final status = _status(state);
    if (status == AsyncStatus.success) {
      Navigator.of(context).pop(true);
    } else if (_isEdit && status == AsyncStatus.failure) {
      // Create-mode failures are reported by JournalPage's listener.
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text('journal.save_general_error'.tr())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = widget.entry?.createdAt ?? DateTime.now();

    return BlocListener<JournalBloc, JournalState>(
      listenWhen: (previous, current) =>
          previous.feedbackCount != current.feedbackCount,
      listener: _onStateChanged,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          leading: IconButton(
            key: const Key('journal-editor-close'),
            tooltip: 'journal.editor_close'.tr(),
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const AppIcon(
              icon: HugeIconsStrokeRounded.strokeRoundedArrowLeft01,
              color: AppColors.textSecondary,
            ),
          ),
          title: Text(
            (_isEdit ? 'journal.editor_edit_title' : 'journal.editor_new_title')
                .tr(),
            style: theme.textTheme.titleMedium?.copyWith(
              fontFamily: AppFonts.headline,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          actions: <Widget>[
            BlocBuilder<JournalBloc, JournalState>(
              builder: (context, state) {
                final busy = _status(state) == AsyncStatus.inProgress;
                final enabled =
                    !busy &&
                    _controller.text.trim().isNotEmpty &&
                    (_isEdit || state.hasStarnyx);
                return TextButton(
                  key: const Key('journal-editor-save'),
                  onPressed: enabled ? _onSavePressed : null,
                  child: Text('journal.editor_save'.tr()),
                );
              },
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
        ),
        // ponytail: metadata (mood/energy/sleep/tags) slots in above the
        // field once STX-U014 lands.
        body: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageHorizontal,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(date),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontFamily: AppFonts.mono,
                    fontFeatures: AppFonts.tabularFigures,
                    letterSpacing: 0.6,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Expanded(
                  child: TextField(
                    key: const Key('journal-editor-input'),
                    controller: _controller,
                    onChanged: _onChanged,
                    autofocus: true,
                    expands: true,
                    minLines: null,
                    maxLines: null,
                    textAlignVertical: TextAlignVertical.top,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    inputFormatters: <TextInputFormatter>[
                      LengthLimitingTextInputFormatter(4000),
                    ],
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontFamily: AppFonts.body,
                      height: 1.6,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'journal.today_hint'.tr(),
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
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
}
