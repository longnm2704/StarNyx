import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:starnyx/app/di/service_locator.dart';
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:starnyx/core/widgets/core_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:starnyx/core/constants/core_constants.dart';
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

Future<StarNyx?> showCreateStarnyxBottomSheet(BuildContext context) {
  return showModalBottomSheet<StarNyx>(
    context: context,
    isScrollControlled: true,
    useSafeArea: false,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.black.withValues(alpha: 0.72),
    builder: (_) {
      return BlocProvider<StarnyxFormBloc>(
        create: (_) => serviceLocator<StarnyxFormBloc>(),
        child: const _CreateStarnyxBottomSheetView(),
      );
    },
  );
}

class _CreateStarnyxBottomSheetView extends StatefulWidget {
  const _CreateStarnyxBottomSheetView();

  @override
  State<_CreateStarnyxBottomSheetView> createState() =>
      _CreateStarnyxBottomSheetViewState();
}

class _CreateStarnyxBottomSheetViewState
    extends State<_CreateStarnyxBottomSheetView> {
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

    final picked = await showStarnyxCupertinoDateTimePicker(
      context: context,
      mode: CupertinoDatePickerMode.date,
      initialDateTime: state.startDate,
      minimumDate: DateTime(2000),
      maximumDate: DateTime(now.year, now.month, now.day),
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

  void _onSubmissionChanged(BuildContext context, StarnyxFormState state) {
    if (state.submissionStatus == StarnyxFormSubmissionStatus.success &&
        state.savedStarnyx != null) {
      Navigator.of(context).pop(state.savedStarnyx);
      return;
    }

    if (state.submissionStatus == StarnyxFormSubmissionStatus.failure) {
      final message =
          state.submissionErrorMessage ?? 'starnyx_form.save_error'.tr();
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
                previous.submissionStatus != current.submissionStatus,
            listener: _onSubmissionChanged,
            child: BlocBuilder<StarnyxFormBloc, StarnyxFormState>(
              buildWhen: (StarnyxFormState previous, StarnyxFormState current) {
                return previous.submissionStatus != current.submissionStatus ||
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
                final isSaving =
                    state.submissionStatus ==
                    StarnyxFormSubmissionStatus.inProgress;
                final formattedStartDate = _formatDate(state.startDate);

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
                          title: 'starnyx_form.sheet_title'.tr(),
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
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              StarnyxFormPillTextField(
                                initialValue: state.title,
                                hintText: 'starnyx_form.title_hint'.tr(),
                                maxLines: 1,
                                height: AppSize.inputMinHeight,
                                hasError: titleHasError,
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
                                    'starnyx_form.title_error_required'.tr(),
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: AppColors.accentPink),
                                  ),
                                ),
                              ],
                              const SizedBox(height: AppSpacing.lg),
                              StarnyxFormFieldLabel(
                                label: 'starnyx_form.description_label'.tr(),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              StarnyxFormPillTextField(
                                initialValue: state.description,
                                hintText: 'starnyx_form.description_hint'.tr(),
                                maxLines: 3,
                                height: 118,
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
                              if (isSaving)
                                const SizedBox(
                                  height: AppSize.ctaHeight,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.accentPink,
                                    ),
                                  ),
                                )
                              else
                                GradientOutlineButton(
                                  label: 'starnyx_form.save_button'.tr(),
                                  onPressed: _submitForm,
                                ),
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

String _formatDate(DateTime date) {
  final d = date.day.toString().padLeft(2, '0');
  final m = date.month.toString().padLeft(2, '0');
  final y = date.year.toString();
  return '$d/$m/$y';
}
