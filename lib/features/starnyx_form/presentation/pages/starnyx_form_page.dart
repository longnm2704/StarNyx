import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:starnyx/app/confirm_discard.dart';
import 'package:starnyx/app/di/service_locator.dart';
import 'package:starnyx/app/reminder_permission.dart';
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:starnyx/core/widgets/core_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/core/utils/date_utils.dart' as core_date_utils;
import 'package:starnyx/features/starnyx_form/presentation/bloc/starnyx_form_bloc.dart';
import 'package:starnyx/features/starnyx_form/presentation/bloc/starnyx_form_event.dart';
import 'package:starnyx/features/starnyx_form/presentation/bloc/starnyx_form_state.dart';
import 'package:starnyx/features/starnyx_form/presentation/widgets/starnyx_form_widgets.dart';
import 'package:starnyx/features/starnyx_form/presentation/widgets/starnyx_form_color_utils.dart';

const _violet = Color(0xFF9D50FF);

class StarnyxFormResult {
  const StarnyxFormResult({this.savedStarnyx, this.deletedStarnyxId});

  final StarNyx? savedStarnyx;
  final String? deletedStarnyxId;

  bool get hasChanges => savedStarnyx != null || deletedStarnyxId != null;
}

/// Full-screen create/edit habit form (`them_thoi_quen` / `chinh_sua_thoi_quen`).
///
/// Open it with [StarnyxFormPage.open]: no [StarNyx] creates a habit, a
/// [StarNyx] edits it. Pops with a [StarnyxFormResult] after a save or delete,
/// or `null` when dismissed.
class StarnyxFormPage extends StatefulWidget {
  const StarnyxFormPage({super.key});

  static Future<StarnyxFormResult?> open(
    BuildContext context, {
    StarNyx? starnyx,
    String? initialColor,
  }) {
    return Navigator.of(context).push<StarnyxFormResult>(
      MaterialPageRoute<StarnyxFormResult>(
        // Edit slides up as a dismissible dialog (close X); create is a
        // regular push (back chevron).
        fullscreenDialog: starnyx != null,
        builder: (_) => BlocProvider<StarnyxFormBloc>(
          create: (_) => serviceLocator<StarnyxFormBloc>(
            param1: starnyx,
            param2: initialColor,
          ),
          child: const StarnyxFormPage(),
        ),
      ),
    );
  }

  @override
  State<StarnyxFormPage> createState() => _StarnyxFormPageState();
}

class _StarnyxFormPageState extends State<StarnyxFormPage> {
  // Title errors show once the user has typed, not on a fresh form.
  bool _titleTouched = false;

  /// The form as opened, to tell whether leaving would lose edits.
  late final StarnyxFormState _initial = context.read<StarnyxFormBloc>().state;

  bool _hasEdits(StarnyxFormState state) {
    return state.title != _initial.title ||
        state.description != _initial.description ||
        state.color != _initial.color ||
        state.icon != _initial.icon ||
        !core_date_utils.DateUtils.isSameDate(
          state.startDate,
          _initial.startDate,
        ) ||
        state.reminderEnabled != _initial.reminderEnabled ||
        (state.reminderEnabled && state.reminderTime != _initial.reminderTime);
  }

  Future<void> _pickReminderTime(StarnyxFormState state) async {
    final now = DateTime.now();
    final initialTime = _parseTime(state.reminderTime) ?? TimeOfDay.now();

    final picked = await showStarnyxCupertinoDateTimePicker(
      context: context,
      mode: CupertinoDatePickerMode.time,
      initialDateTime: DateTime(
        now.year,
        now.month,
        now.day,
        initialTime.hour,
        initialTime.minute,
      ),
    );

    if (picked == null || !mounted) {
      return;
    }

    context.read<StarnyxFormBloc>().add(
      StarnyxFormReminderTimeChanged(
        _formatTime(TimeOfDay.fromDateTime(picked)),
      ),
    );
  }

  Future<void> _pickStartDate(StarnyxFormState state) async {
    final today = core_date_utils.DateUtils.nowDate();

    // Editing may keep an older start date (the domain allows it), so the
    // picker must accept it as its initial value; picking another day older
    // than 7 days shows the start date error.
    final picked = await showStarnyxCupertinoDateTimePicker(
      context: context,
      mode: CupertinoDatePickerMode.date,
      initialDateTime: state.startDate,
      minimumDate: core_date_utils.DateUtils.minDate(
        core_date_utils.DateUtils.dateOnly(state.startDate),
        core_date_utils.DateUtils.addDays(today, -7),
      ),
      maximumDate: today,
    );

    if (picked == null || !mounted) {
      return;
    }

    context.read<StarnyxFormBloc>().add(StarnyxFormStartDateChanged(picked));
  }

  Future<void> _confirmDelete() async {
    final state = context.read<StarnyxFormBloc>().state;

    final confirmed = await showAppConfirmDialog(
      context: context,
      title: 'starnyx_form.delete_confirm_title'.tr(),
      message: 'starnyx_form.delete_confirm_message'.tr(),
      cancelLabel: 'starnyx_form.delete_cancel'.tr(),
      confirmLabel: 'starnyx_form.delete_confirm'.tr(),
      actionStyle: AppConfirmActionStyle.destructive,
      subject: _DeleteSubjectChip(state: state),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    context.read<StarnyxFormBloc>().add(const StarnyxFormDeleted());
  }

  void _onSubmissionChanged(BuildContext context, StarnyxFormState state) {
    if (state.submissionStatus == AsyncStatus.success &&
        state.savedStarnyx != null) {
      Navigator.of(
        context,
      ).pop(StarnyxFormResult(savedStarnyx: state.savedStarnyx));
      return;
    }

    if (state.deletionStatus == AsyncStatus.success &&
        state.deletedStarnyxId != null) {
      Navigator.of(
        context,
      ).pop(StarnyxFormResult(deletedStarnyxId: state.deletedStarnyxId));
      return;
    }

    final String? message = switch (state) {
      _ when state.submissionStatus == AsyncStatus.failure =>
        'starnyx_form.save_error'.tr(),
      _ when state.deletionStatus == AsyncStatus.failure =>
        'starnyx_form.delete_error'.tr(),
      _ => null,
    };
    if (message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  String _startDateLabel(DateTime date) {
    final formatted = core_date_utils.DateUtils.formatShortDate(
      date,
      context.locale.toLanguageTag(),
    );
    final isToday = core_date_utils.DateUtils.isSameDate(
      date,
      core_date_utils.DateUtils.nowDate(),
    );
    return isToday
        ? 'starnyx_form.start_today'.tr(args: <String>[formatted])
        : formatted;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return BlocSelector<StarnyxFormBloc, StarnyxFormState, bool>(
      selector: _hasEdits,
      builder: (context, hasEdits) => DiscardChangesScope(
        dirty: hasEdits,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            bottom: false,
            child: BlocConsumer<StarnyxFormBloc, StarnyxFormState>(
              listenWhen: (previous, current) =>
                  previous.submissionStatus != current.submissionStatus ||
                  previous.deletionStatus != current.deletionStatus,
              listener: _onSubmissionChanged,
              builder: (BuildContext context, StarnyxFormState state) {
                final bloc = context.read<StarnyxFormBloc>();
                final accent = starnyxColorFromHex(state.color);
                final titleError = _titleTouched ? state.titleError : null;
                final descriptionError = state.descriptionError;
                final isBusy =
                    state.submissionStatus == AsyncStatus.inProgress ||
                    state.deletionStatus == AsyncStatus.inProgress;

                return Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.pageHorizontal,
                        AppSpacing.sm,
                        AppSpacing.pageHorizontal,
                        AppSpacing.sm,
                      ),
                      child: StarnyxFormHeader(
                        title:
                            (state.isEditing
                                    ? 'starnyx_form.edit_sheet_title'
                                    : 'starnyx_form.create_sheet_title')
                                .tr(),
                        leadingIcon: state.isEditing
                            ? HugeIconsStrokeRounded.strokeRoundedCancel01
                            : HugeIconsStrokeRounded.strokeRoundedArrowLeft01,
                        leadingTooltip: state.isEditing
                            ? MaterialLocalizations.of(
                                context,
                              ).closeButtonTooltip
                            : MaterialLocalizations.of(
                                context,
                              ).backButtonTooltip,
                        onClosePressed: () => Navigator.of(context).maybePop(),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () => FocusScope.of(context).unfocus(),
                        child: ListView(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.pageHorizontal,
                            AppSpacing.xs,
                            AppSpacing.pageHorizontal,
                            AppSpacing.lg + mediaQuery.padding.bottom,
                          ),
                          children: <Widget>[
                            StarnyxFormFieldLabel(
                              label: 'starnyx_form.title_label'.tr(),
                              trailing: _CharacterCounter(
                                currentLength: state.title.characters.length,
                                maxLength: StarnyxFormBloc.maxTitleLength,
                                hasError: titleError != null,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            StarnyxFormPillTextField(
                              key: const Key('starnyx-form-title'),
                              initialValue: state.title,
                              hintText: 'starnyx_form.title_hint'.tr(),
                              hasError: titleError != null,
                              inputFormatters: <TextInputFormatter>[
                                LengthLimitingTextInputFormatter(
                                  StarnyxFormBloc.maxTitleLength,
                                ),
                              ],
                              onChanged: (String value) {
                                if (!_titleTouched) {
                                  setState(() => _titleTouched = true);
                                }
                                bloc.add(StarnyxFormTitleChanged(value));
                              },
                            ),
                            if (titleError != null)
                              _ErrorText(
                                switch (titleError) {
                                  StarnyxFormTitleError.empty =>
                                    'starnyx_form.title_error_required',
                                  StarnyxFormTitleError.tooLong =>
                                    'starnyx_form.title_error_too_long',
                                }.tr(),
                              ),
                            const SizedBox(height: AppSpacing.lg),
                            StarnyxFormFieldLabel(
                              label: 'starnyx_form.description_label'.tr(),
                              trailing: _CharacterCounter(
                                currentLength:
                                    state.description.characters.length,
                                maxLength: StarnyxFormBloc.maxDescriptionLength,
                                hasError: descriptionError != null,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            StarnyxFormPillTextField(
                              key: const Key('starnyx-form-description'),
                              initialValue: state.description,
                              hintText: 'starnyx_form.description_hint'.tr(),
                              minLines: 3,
                              maxLines: 5,
                              hasError: descriptionError != null,
                              inputFormatters: <TextInputFormatter>[
                                LengthLimitingTextInputFormatter(
                                  StarnyxFormBloc.maxDescriptionLength,
                                ),
                              ],
                              onChanged: (String value) {
                                bloc.add(StarnyxFormDescriptionChanged(value));
                              },
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            StarnyxFormSymbolPicker(
                              selectedSymbol: state.icon,
                              color: accent,
                              onSymbolSelected: (String symbol) {
                                bloc.add(StarnyxFormIconChanged(symbol));
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),
                            StarnyxFormColorCard(
                              selectedColorHex: state.color,
                              onColorSelected: (String colorHex) {
                                bloc.add(StarnyxFormColorChanged(colorHex));
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),
                            StarnyxFormReminderCard(
                              reminderEnabled: state.reminderEnabled,
                              reminderTime: state.reminderTime,
                              onToggle: (bool enabled) {
                                bloc.add(StarnyxFormReminderToggled(enabled));
                                if (enabled) requestReminderPermission(context);
                              },
                              onTapTime: () => _pickReminderTime(state),
                            ),
                            if (state.reminderTimeError case final error?)
                              _ErrorText(
                                switch (error) {
                                  StarnyxFormReminderTimeError.missing =>
                                    'starnyx_form.reminder_time_error_missing',
                                  StarnyxFormReminderTimeError.invalid =>
                                    'starnyx_form.reminder_time_error_invalid',
                                }.tr(),
                              ),
                            const SizedBox(height: AppSpacing.md),
                            StarnyxFormStartOnCard(
                              value: _startDateLabel(state.startDate),
                              onTap: () => _pickStartDate(state),
                            ),
                            if (state.startDateError case final error?)
                              _ErrorText(
                                switch (error) {
                                  StarnyxFormStartDateError.inFuture =>
                                    'starnyx_form.start_date_error_future',
                                  StarnyxFormStartDateError.tooFarInPast =>
                                    'starnyx_form.start_date_error_too_old',
                                }.tr(),
                              ),
                            const SizedBox(height: AppSpacing.xl),
                            if (isBusy)
                              const SizedBox(
                                height: AppSize.ctaHeight,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primary,
                                  ),
                                ),
                              )
                            else ...<Widget>[
                              if (state.isEditing) ...<Widget>[
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: TextButton.icon(
                                    key: const Key('starnyx-form-delete'),
                                    onPressed: state.canDelete
                                        ? _confirmDelete
                                        : null,
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppColors.error,
                                    ),
                                    icon: const AppIcon(
                                      icon: HugeIconsStrokeRounded
                                          .strokeRoundedDelete02,
                                      size: 18,
                                      color: AppColors.error,
                                    ),
                                    label: Text(
                                      'starnyx_form.delete_button'.tr(),
                                      style: const TextStyle(
                                        fontFamily: AppFonts.body,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                              ],
                              _SubmitButton(
                                label:
                                    (state.isEditing
                                            ? 'starnyx_form.update_button'
                                            : 'starnyx_form.save_button')
                                        .tr(),
                                isEditing: state.isEditing,
                                onPressed: state.canSubmit
                                    ? () =>
                                          bloc.add(const StarnyxFormSubmitted())
                                    : null,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Full-width pill CTA: violet→emerald gradient (create) or solid emerald
/// (edit), black w700 label with a check icon. Dimmed when disabled.
class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.label,
    required this.isEditing,
    required this.onPressed,
  });

  final String label;
  final bool isEditing;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isEditing ? AppColors.primary : null,
          gradient: isEditing
              ? null
              : const LinearGradient(
                  colors: <Color>[_violet, AppColors.primary],
                ),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          boxShadow: enabled
              ? const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x4010B981), // emerald 25%
                    blurRadius: 24,
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: const Key('starnyx-form-submit'),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            onTap: onPressed,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: AppSize.ctaHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppColors.black,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    const AppIcon(
                      icon: HugeIconsStrokeRounded.strokeRoundedTick02,
                      size: 18,
                      color: AppColors.black,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Delete dialog chip: habit symbol + title + start date.
class _DeleteSubjectChip extends StatelessWidget {
  const _DeleteSubjectChip({required this.state});

  final StarnyxFormState state;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodySmall;
    final startedOn = 'starnyx_form.delete_started_on'.tr(
      args: <String>[
        core_date_utils.DateUtils.formatShortDate(
          state.startDate,
          context.locale.toLanguageTag(),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AppIcon(
            icon: HabitSymbols.iconFor(state.icon),
            size: 14,
            color: starnyxColorFromHex(state.color),
          ),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  TextSpan(
                    text: state.title.trim(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextSpan(
                    text: ' · $startedOn',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
              key: const Key('starnyx-form-delete-subject'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textStyle,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxs,
        AppSpacing.xs,
        AppSpacing.xxs,
        0,
      ),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppColors.error),
      ),
    );
  }
}

class _CharacterCounter extends StatelessWidget {
  const _CharacterCounter({
    required this.currentLength,
    required this.maxLength,
    this.hasError = false,
  });

  final int currentLength;
  final int maxLength;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$currentLength/$maxLength',
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        fontFamily: AppFonts.mono,
        fontFeatures: AppFonts.tabularFigures,
        color: hasError ? AppColors.error : AppColors.textSecondary,
      ),
    );
  }
}

TimeOfDay? _parseTime(String value) {
  final parts = value.split(':');
  if (parts.length != 2) {
    return null;
  }

  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) {
    return null;
  }

  if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
    return null;
  }

  return TimeOfDay(hour: hour, minute: minute);
}

String _formatTime(TimeOfDay time) {
  final h = time.hour.toString().padLeft(2, '0');
  final m = time.minute.toString().padLeft(2, '0');
  return '$h:$m';
}
