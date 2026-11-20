import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:starnyx/app/confirm_discard.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/core/utils/date_utils.dart' as core_date_utils;
import 'package:starnyx/core/widgets/app_icon.dart';
import 'package:starnyx/domain/entities/journal_entry.dart';
import 'package:starnyx/domain/usecases/save_journal_entry_use_case.dart';
import 'package:starnyx/features/journal/presentation/bloc/journal_bloc.dart';
import 'package:starnyx/features/journal/presentation/bloc/journal_event.dart';
import 'package:starnyx/features/journal/presentation/bloc/journal_state.dart';
import 'package:starnyx/features/journal/presentation/widgets/journal_metadata.dart';

/// Full-screen journal editor.
///
/// Create mode ([entry] is null) edits the shared draft of [JournalBloc] and
/// saves it as a new entry for today. Edit mode updates [entry] in place,
/// keeping its `id` and `createdAt`. Pops with `true` once saved.
///
/// Below the text sit the optional metadata inputs: mood, energy (1–5), sleep
/// duration and tags. Tapping a selected mood or energy dot clears it.
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
  final TextEditingController _tagController = TextEditingController();
  late JournalMood? _mood = widget.entry?.mood;
  late int? _energy = widget.entry?.energy;
  late int? _sleepMinutes = widget.entry?.sleepMinutes;
  late List<String> _tags = widget.entry?.tags ?? const <String>[];

  bool get _isEdit => widget.entry != null;

  /// Edits that leaving would lose. Create mode keeps its text in the shared
  /// draft, so only the metadata counts there.
  bool get _hasUnsavedEdits {
    final entry = widget.entry;
    if (entry == null) {
      return _mood != null ||
          _energy != null ||
          _sleepMinutes != null ||
          _tags.isNotEmpty;
    }
    return _controller.text != entry.content ||
        _mood != entry.mood ||
        _energy != entry.energy ||
        _sleepMinutes != entry.sleepMinutes ||
        !listEquals(_tags, entry.tags);
  }

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
    _tagController.dispose();
    super.dispose();
  }

  // Adds the typed tag; invalid input (too many/too long) is left in the field.
  void _addTag(String value) {
    try {
      final tags = SaveJournalEntryUseCase.normalizeTags(<String>[
        ..._tags,
        value,
      ]);
      setState(() => _tags = tags);
      _tagController.clear();
    } on FormatException {
      // Field limits make this unreachable in practice.
    }
  }

  Future<void> _pickSleep() async {
    // CupertinoTimerPicker needs a value on its 5-minute grid.
    var minutes = ((_sleepMinutes ?? 7 * 60) ~/ 5) * 5;
    final picked = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: AppColors.sheet,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                key: const Key('journal-sleep-done'),
                onPressed: () => Navigator.of(sheetContext).pop(minutes),
                child: Text('journal.sleep_done'.tr()),
              ),
            ),
            SizedBox(
              height: 216,
              child: CupertinoTheme(
                data: const CupertinoThemeData(brightness: Brightness.dark),
                child: CupertinoTimerPicker(
                  mode: CupertinoTimerPickerMode.hm,
                  minuteInterval: 5,
                  initialTimerDuration: Duration(minutes: minutes),
                  onTimerDurationChanged: (value) => minutes = value.inMinutes,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    if (picked != null && mounted) setState(() => _sleepMinutes = picked);
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
    // A tag still in the field is saved too.
    final tags = <String>[..._tags, _tagController.text];
    if (entry == null) {
      bloc.add(
        JournalSaveRequested(
          mood: _mood,
          energy: _energy,
          sleepMinutes: _sleepMinutes,
          tags: tags,
        ),
      );
    } else {
      bloc.add(
        JournalEntryUpdated(
          entry,
          content: _controller.text,
          mood: _mood,
          energy: _energy,
          sleepMinutes: _sleepMinutes,
          tags: tags,
        ),
      );
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
      child: DiscardChangesScope(
        dirty: _hasUnsavedEdits,
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
              (_isEdit
                      ? 'journal.editor_edit_title'
                      : 'journal.editor_new_title')
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
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal,
                0,
                AppSpacing.pageHorizontal,
                AppSpacing.xl,
              ),
              children: <Widget>[
                Text(
                  core_date_utils.DateUtils.formatShortDateTime(
                    date,
                    context.locale.toLanguageTag(),
                  ),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontFamily: AppFonts.mono,
                    fontFeatures: AppFonts.tabularFigures,
                    letterSpacing: 0.6,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                // ponytail: text first, metadata after; the list scrolls instead
                // of an expanding field so the inputs fit small screens.
                TextField(
                  key: const Key('journal-editor-input'),
                  controller: _controller,
                  onChanged: _onChanged,
                  autofocus: true,
                  minLines: 8,
                  maxLines: null,
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
                const SizedBox(height: AppSpacing.lg),
                _MetaSection(
                  title: 'journal.mood_title'.tr(),
                  child: Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: <Widget>[
                      for (final mood in JournalMood.values)
                        ChoiceChip(
                          key: Key('journal-mood-${mood.name}'),
                          selected: _mood == mood,
                          showCheckmark: false,
                          avatar: AppIcon(
                            icon: mood.icon,
                            size: 16,
                            color: mood.color,
                          ),
                          label: Text(mood.label),
                          labelStyle: theme.textTheme.labelMedium?.copyWith(
                            color: _mood == mood
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                          backgroundColor: AppColors.surfaceLevel1,
                          selectedColor: AppColors.surfaceLevel3,
                          side: BorderSide(
                            color: _mood == mood
                                ? mood.color
                                : AppColors.borderSubtle,
                          ),
                          shape: const StadiumBorder(),
                          onSelected: (selected) =>
                              setState(() => _mood = selected ? mood : null),
                        ),
                    ],
                  ),
                ),
                _MetaSection(
                  title: 'journal.energy_title'.tr(),
                  child: Row(
                    children: <Widget>[
                      for (
                        var level = JournalEntry.minEnergy;
                        level <= JournalEntry.maxEnergy;
                        level++
                      )
                        Semantics(
                          button: true,
                          selected: _energy == level,
                          label: 'journal.energy_level_semantics'.tr(
                            args: <String>['$level'],
                          ),
                          child: InkResponse(
                            key: Key('journal-energy-$level'),
                            radius: 22,
                            onTap: () => setState(
                              () => _energy = _energy == level ? null : level,
                            ),
                            child: SizedBox.square(
                              dimension: 44,
                              child: Center(
                                child: Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: (_energy ?? 0) >= level
                                        ? AppColors.primary
                                        : AppColors.surfaceLevel3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                _MetaSection(
                  title: 'journal.sleep_title'.tr(),
                  child: Row(
                    children: <Widget>[
                      ActionChip(
                        key: const Key('journal-sleep-button'),
                        avatar: const AppIcon(
                          icon: HugeIconsStrokeRounded.strokeRoundedMoon02,
                          size: 16,
                          color: AppColors.tertiary,
                        ),
                        label: Text(
                          _sleepMinutes == null
                              ? 'journal.sleep_empty'.tr()
                              : formatSleepMinutes(_sleepMinutes!),
                        ),
                        labelStyle: theme.textTheme.labelMedium?.copyWith(
                          fontFamily: AppFonts.mono,
                          fontFeatures: AppFonts.tabularFigures,
                          color: AppColors.textPrimary,
                        ),
                        backgroundColor: AppColors.surfaceLevel1,
                        side: const BorderSide(color: AppColors.borderSubtle),
                        shape: const StadiumBorder(),
                        onPressed: _pickSleep,
                      ),
                      if (_sleepMinutes != null)
                        IconButton(
                          key: const Key('journal-sleep-clear'),
                          tooltip: 'journal.sleep_clear'.tr(),
                          onPressed: () => setState(() => _sleepMinutes = null),
                          icon: const AppIcon(
                            icon: HugeIconsStrokeRounded.strokeRoundedCancel01,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                _MetaSection(
                  title: 'journal.tags_title'.tr(),
                  child: Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      for (final tag in _tags)
                        InputChip(
                          label: Text('#$tag'),
                          labelStyle: theme.textTheme.labelMedium?.copyWith(
                            fontFamily: AppFonts.mono,
                            color: AppColors.textPrimary,
                          ),
                          backgroundColor: AppColors.surfaceLevel1,
                          side: const BorderSide(color: AppColors.borderSubtle),
                          shape: const StadiumBorder(),
                          deleteButtonTooltipMessage:
                              'journal.tag_remove_semantics'.tr(
                                args: <String>[tag],
                              ),
                          onDeleted: () => setState(
                            () => _tags = <String>[
                              for (final t in _tags)
                                if (t != tag) t,
                            ],
                          ),
                        ),
                      if (_tags.length < JournalEntry.maxTags)
                        SizedBox(
                          width: 160,
                          child: TextField(
                            key: const Key('journal-tag-input'),
                            controller: _tagController,
                            onSubmitted: _addTag,
                            textInputAction: TextInputAction.done,
                            inputFormatters: <TextInputFormatter>[
                              LengthLimitingTextInputFormatter(
                                JournalEntry.maxTagLength,
                              ),
                            ],
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: 'journal.tags_hint'.tr(),
                              isDense: true,
                            ),
                          ),
                        ),
                    ],
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

/// Overline title + content, spaced like the rest of the editor.
class _MetaSection extends StatelessWidget {
  const _MetaSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontFamily: AppFonts.mono,
              letterSpacing: 1.2,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          child,
        ],
      ),
    );
  }
}
