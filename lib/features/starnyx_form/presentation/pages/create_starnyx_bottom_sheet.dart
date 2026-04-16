import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:starnyx/app/di/service_locator.dart';
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:starnyx/core/widgets/core_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/core/utils/date_utils.dart' as core_date_utils;
import 'package:starnyx/features/starnyx_form/presentation/bloc/starnyx_form_bloc.dart';
import 'package:starnyx/features/starnyx_form/presentation/bloc/starnyx_form_event.dart';
import 'package:starnyx/features/starnyx_form/presentation/bloc/starnyx_form_state.dart';
import 'package:starnyx/features/starnyx_form/presentation/widgets/starnyx_form_widgets.dart';

const LinearGradient _sheetTopDownGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: <Color>[AppColors.sheetTop, AppColors.sheetMid, AppColors.background],
  stops: <double>[0.0, 0.48, 1.0],
);

class StarnyxFormResult {
  const StarnyxFormResult({this.savedStarnyx, this.deletedStarnyxId});

  final StarNyx? savedStarnyx;
  final String? deletedStarnyxId;

  bool get hasChanges => savedStarnyx != null || deletedStarnyxId != null;
}

Future<StarnyxFormResult?> showCreateStarnyxBottomSheet(BuildContext context) {
  return showStarnyxFormBottomSheet(context);
}

Future<StarnyxFormResult?> showEditStarnyxBottomSheet(
  BuildContext context,
  StarNyx initialStarnyx,
) {
  return showStarnyxFormBottomSheet(context, initialStarnyx: initialStarnyx);
}

Future<StarnyxFormResult?> showStarnyxFormBottomSheet(
  BuildContext context, {
  StarNyx? initialStarnyx,
}) {
  return showModalBottomSheet<StarnyxFormResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: false,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.black.withValues(alpha: 0.72),
    builder: (_) {
      return BlocProvider<StarnyxFormBloc>(
        create: (_) => serviceLocator<StarnyxFormBloc>(param1: initialStarnyx),
        child: const _StarnyxFormBottomSheetView(),
      );
    },
  );
}

class _StarnyxFormBottomSheetView extends StatefulWidget {
  const _StarnyxFormBottomSheetView();

  @override
  State<_StarnyxFormBottomSheetView> createState() =>
      _StarnyxFormBottomSheetViewState();
}

class _StarnyxFormBottomSheetViewState
    extends State<_StarnyxFormBottomSheetView> {
  bool _showValidationErrors = false;

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
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final picked = await showStarnyxCupertinoDateTimePicker(
      context: context,
      mode: CupertinoDatePickerMode.date,
      initialDateTime: state.startDate,
      minimumDate: today.subtract(const Duration(days: 7)),
      maximumDate: today,
    );

    if (picked == null || !mounted) {
      return;
    }

    context.read<StarnyxFormBloc>().add(StarnyxFormStartDateChanged(picked));
  }

  void _submitForm() {
    setState(() {
      _showValidationErrors = true;
    });
    context.read<StarnyxFormBloc>().add(const StarnyxFormSubmitted());
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: 'starnyx_form.delete_confirm_title'.tr(),
      message: 'starnyx_form.delete_confirm_message'.tr(),
      cancelLabel: 'starnyx_form.delete_cancel'.tr(),
      confirmLabel: 'starnyx_form.delete_confirm'.tr(),
      iconAssetPath: 'assets/icons/ic_trash.svg',
      actionStyle: AppConfirmActionStyle.destructive,
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

    if (state.submissionStatus == AsyncStatus.failure) {
      final message =
          state.submissionErrorMessage ?? 'starnyx_form.save_error'.tr();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }

    if (state.deletionStatus == AsyncStatus.success &&
        state.deletedStarnyxId != null) {
      Navigator.of(
        context,
      ).pop(StarnyxFormResult(deletedStarnyxId: state.deletedStarnyxId));
      return;
    }

    if (state.deletionStatus == AsyncStatus.failure) {
      final message =
          state.deletionErrorMessage ?? 'starnyx_form.delete_error'.tr();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topInset = mediaQuery.viewPadding.top > 0
        ? mediaQuery.viewPadding.top
        : mediaQuery.padding.top;
    final headerTopPadding = (topInset < 24 ? 24.0 : topInset) + AppSpacing.lg;

    return FractionallySizedBox(
      heightFactor: 1,
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: _sheetTopDownGradient),
        child: SafeArea(
          top: false,
          bottom: false,
          child: BlocListener<StarnyxFormBloc, StarnyxFormState>(
            listenWhen: (previous, current) =>
                previous.submissionStatus != current.submissionStatus ||
                previous.deletionStatus != current.deletionStatus,
            listener: _onSubmissionChanged,
            child: BlocBuilder<StarnyxFormBloc, StarnyxFormState>(
              buildWhen: (StarnyxFormState previous, StarnyxFormState current) {
                return previous.submissionStatus != current.submissionStatus ||
                    previous.deletionStatus != current.deletionStatus ||
                    previous.title != current.title ||
                    previous.description != current.description ||
                    previous.titleError != current.titleError ||
                    previous.color != current.color ||
                    previous.reminderEnabled != current.reminderEnabled ||
                    previous.reminderTime != current.reminderTime ||
                    previous.startDate != current.startDate;
              },
              builder: (BuildContext context, StarnyxFormState state) {
                final bloc = context.read<StarnyxFormBloc>();
                final titleHasError =
                    _showValidationErrors && state.titleError != null;
                final descriptionHasError =
                    _showValidationErrors && state.descriptionError != null;
                final isSaving =
                    state.submissionStatus == AsyncStatus.inProgress;
                final isDeleting =
                    state.deletionStatus == AsyncStatus.inProgress;
                final formattedStartDate =
                    core_date_utils.DateUtils.formatDdMmYyyy(state.startDate);
                final sheetTitle = state.isEditing
                    ? 'starnyx_form.edit_sheet_title'.tr()
                    : 'starnyx_form.create_sheet_title'.tr();
                final saveButtonLabel = state.isEditing
                    ? 'starnyx_form.update_button'.tr()
                    : 'starnyx_form.save_button'.tr();

                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    FocusScope.of(context).unfocus();
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.pageHorizontal,
                          headerTopPadding,
                          AppSpacing.pageHorizontal,
                          AppSpacing.md,
                        ),
                        child: StarnyxFormHeader(
                          title: sheetTitle,
                          onClosePressed: () =>
                              Navigator.of(context).maybePop(),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.pageHorizontal,
                            AppSpacing.sm,
                            AppSpacing.pageHorizontal,
                            AppSpacing.lg + mediaQuery.viewInsets.bottom,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              StarnyxFormFieldLabel(
                                label: 'starnyx_form.title_label'.tr(),
                                trailing: _CharacterCounter(
                                  currentLength: state.title.characters.length,
                                  maxLength: StarnyxFormBloc.maxTitleLength,
                                  hasError: titleHasError,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              StarnyxFormPillTextField(
                                initialValue: state.title,
                                hintText: 'starnyx_form.title_hint'.tr(),
                                maxLines: 1,
                                height: AppSize.inputMinHeight,
                                hasError: titleHasError,
                                inputFormatters: <TextInputFormatter>[
                                  LengthLimitingTextInputFormatter(
                                    StarnyxFormBloc.maxTitleLength,
                                  ),
                                ],
                                onChanged: (String value) {
                                  bloc.add(StarnyxFormTitleChanged(value));
                                },
                              ),
                              if (titleHasError) ...<Widget>[
                                const SizedBox(height: AppSpacing.xs),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                  ),
                                  child: Text(
                                    switch (state.titleError) {
                                      StarnyxFormTitleError.empty =>
                                        'starnyx_form.title_error_required'
                                            .tr(),
                                      StarnyxFormTitleError.tooLong =>
                                        'starnyx_form.title_error_too_long'
                                            .tr(),
                                      null => '',
                                    },
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: AppColors.accentPink),
                                  ),
                                ),
                              ],
                              const SizedBox(height: AppSpacing.lg),
                              StarnyxFormFieldLabel(
                                label: 'starnyx_form.description_label'.tr(),
                                trailing: _CharacterCounter(
                                  currentLength:
                                      state.description.characters.length,
                                  maxLength:
                                      StarnyxFormBloc.maxDescriptionLength,
                                  hasError: descriptionHasError,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              StarnyxFormPillTextField(
                                initialValue: state.description,
                                hintText: 'starnyx_form.description_hint'.tr(),
                                maxLines: 5,
                                height: 118,
                                hasError: descriptionHasError,
                                inputFormatters: <TextInputFormatter>[
                                  LengthLimitingTextInputFormatter(
                                    StarnyxFormBloc.maxDescriptionLength,
                                  ),
                                ],
                                onChanged: (String value) {
                                  bloc.add(
                                    StarnyxFormDescriptionChanged(value),
                                  );
                                },
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              StarnyxFormFieldLabel(
                                label: 'starnyx_form.color_label'.tr(),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              StarnyxFormColorCard(
                                selectedColorHex: state.color,
                                onColorSelected: (String colorHex) {
                                  bloc.add(StarnyxFormColorChanged(colorHex));
                                },
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              StarnyxFormFieldLabel(
                                label: 'starnyx_form.reminder_label'.tr(),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              StarnyxFormReminderCard(
                                reminderEnabled: state.reminderEnabled,
                                reminderTime: state.reminderTime,
                                label: 'starnyx_form.reminder_time_label'.tr(),
                                onToggle: (bool enabled) {
                                  bloc.add(StarnyxFormReminderToggled(enabled));
                                },
                                onTapTime: () => _pickReminderTime(state),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              StarnyxFormFieldLabel(
                                label: 'starnyx_form.start_on_label'.tr(),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              StarnyxFormStartOnCard(
                                value: formattedStartDate,
                                onTap: () => _pickStartDate(state),
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              if (isSaving || isDeleting)
                                const SizedBox(
                                  height: AppSize.ctaHeight,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.accentPink,
                                    ),
                                  ),
                                )
                              else ...<Widget>[
                                if (state.isEditing) ...<Widget>[
                                  TextButton(
                                    onPressed: state.canDelete
                                        ? _confirmDelete
                                        : null,
                                    child: Text(
                                      'starnyx_form.delete_button'.tr(),
                                      style: const TextStyle(
                                        color: AppColors.accentPink,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                ],
                                GradientOutlineButton(
                                  label: saveButtonLabel,
                                  onPressed: _submitForm,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
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
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: hasError ? AppColors.accentPink : AppColors.textMuted,
        fontWeight: FontWeight.w600,
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
