import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:starnyx/app/reminder_permission.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/core/widgets/core_widgets.dart';
import 'package:starnyx/features/onboarding/domain/create_onboarding_habits.dart';
import 'package:starnyx/features/onboarding/domain/onboarding_template.dart';
import 'package:starnyx/features/onboarding/presentation/widgets/onboarding_widgets.dart';
import 'package:starnyx/features/starnyx_form/presentation/widgets/starnyx_cupertino_picker.dart';
import 'package:starnyx/features/starnyx_form/presentation/widgets/starnyx_form_color_utils.dart';

/// Onboarding step 3/3: reminder setup (`thiet_lap_nhac_nho`).
///
/// Every picked template gets a daily reminder; the user can change each
/// time, or set one shared time for all of them. [onStart] saves the habits
/// and may throw — the page then shows an error and stays put.
///
/// Mockup rows left out on purpose: frequency chips (only daily reminders
/// exist), "Sound & haptics" (no such setting), "Smart notifications" (not a
/// feature) and the "Synced" pill (nothing is saved yet).
class OnboardingReminderPage extends StatefulWidget {
  const OnboardingReminderPage({
    required this.templates,
    required this.onBack,
    required this.onStart,
    super.key,
  });

  final List<OnboardingTemplate> templates;
  final VoidCallback onBack;

  /// Creates the habits; the header "skip" calls it too, with reminders off.
  final Future<void> Function(List<OnboardingHabitDraft> drafts) onStart;

  @override
  State<OnboardingReminderPage> createState() => _OnboardingReminderPageState();
}

class _OnboardingReminderPageState extends State<OnboardingReminderPage> {
  // Templates are const, so edited times live here keyed by template id.
  late final Map<String, String> _times = <String, String>{
    for (final template in widget.templates) template.id: template.reminderTime,
  };
  String _sharedTime = '21:30';
  bool _saving = false;

  Future<void> _pickTime(OnboardingTemplate template) async {
    final current = _parse(_times[template.id]!);
    final now = DateTime.now();
    final picked = await showStarnyxCupertinoDateTimePicker(
      context: context,
      mode: CupertinoDatePickerMode.time,
      initialDateTime: DateTime(
        now.year,
        now.month,
        now.day,
        current ~/ 60,
        current % 60,
      ),
    );
    if (picked == null || !mounted) return;
    setState(
      () => _times[template.id] = _format(picked.hour * 60 + picked.minute),
    );
  }

  void _shiftShared(int minutes) {
    setState(() => _sharedTime = _format(_parse(_sharedTime) + minutes));
  }

  void _applyShared() {
    setState(() => _times.updateAll((_, _) => _sharedTime));
  }

  /// [withReminders] false is the header "skip": the habits are still
  /// created, just with reminders off.
  Future<void> _start({bool withReminders = true}) async {
    if (_saving) return;
    setState(() => _saving = true);
    // First reminder the user turns on: ask for notification permission now.
    if (withReminders) await requestReminderPermission(context);
    if (!mounted) return;
    try {
      await widget.onStart(<OnboardingHabitDraft>[
        for (final template in widget.templates)
          (
            title: template.titleKey.tr(),
            description: template.descriptionKey.tr(),
            icon: template.symbol,
            color: template.colorHex,
            reminderTime: _times[template.id]!,
            reminderEnabled: withReminders,
          ),
      ]);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('onboarding.reminder.create_error'.tr())),
        );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return PopScope<Object?>(
      canPop: !_saving,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              OnboardingHeader(
                step: 'onboarding.reminder.step'.tr(),
                // Leaving while habits are being saved would let the completion
                // screen appear on top of an earlier step later.
                onBack: _saving ? null : widget.onBack,
                onSkip: _saving ? null : () => _start(withReminders: false),
                skipLabel: 'onboarding.reminder.skip'.tr(),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageHorizontal,
                    AppSpacing.xs,
                    AppSpacing.pageHorizontal,
                    AppSpacing.lg,
                  ),
                  children: <Widget>[
                    OnboardingDotLabel(
                      child: Text.rich(
                        TextSpan(
                          children: <InlineSpan>[
                            TextSpan(
                              text: 'onboarding.reminder.overline_step'.tr(),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(
                              text:
                                  ' · ${'onboarding.reminder.overline_label'.tr()}',
                            ),
                          ],
                        ),
                        style: textTheme.labelMedium,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text.rich(
                      TextSpan(
                        children: <InlineSpan>[
                          TextSpan(text: 'onboarding.reminder.title_lead'.tr()),
                          TextSpan(
                            text: 'onboarding.reminder.title_emphasis'.tr(),
                            style: const TextStyle(color: AppColors.primary),
                          ),
                        ],
                      ),
                      style: textTheme.headlineLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'onboarding.reminder.subtitle'.tr(),
                      style: textTheme.bodyLarge,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'onboarding.reminder.selected_count'.tr(
                        args: <String>['${widget.templates.length}'],
                      ),
                      style: textTheme.labelMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    for (final template in widget.templates) ...<Widget>[
                      _ReminderRow(
                        template: template,
                        time: _times[template.id]!,
                        onEdit: () => _pickTime(template),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    _SharedTimeCard(
                      time: _sharedTime,
                      onEarlier: () => _shiftShared(-15),
                      onLater: () => _shiftShared(15),
                      onApply: _applyShared,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.sm,
                  AppSpacing.pageHorizontal,
                  AppSpacing.sm,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    AppPrimaryButton(
                      key: const Key('onboarding-reminder-start'),
                      label: '${'onboarding.reminder.cta'.tr()} →',
                      onPressed: _saving ? null : _start,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const AppIcon(
                          icon: HugeIconsStrokeRounded
                              .strokeRoundedSlidersHorizontal,
                          color: AppColors.textTertiary,
                          size: 14,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Flexible(
                          child: Text(
                            'onboarding.reminder.footer'.tr(),
                            textAlign: TextAlign.center,
                            style: textTheme.labelSmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Minutes since midnight for an `HH:mm` string.
int _parse(String time) {
  final parts = time.split(':');
  return int.parse(parts[0]) * 60 + int.parse(parts[1]);
}

/// `HH:mm` for minutes since midnight, wrapping around the day.
String _format(int minutes) {
  final wrapped = minutes % (24 * 60);
  String two(int value) => value.toString().padLeft(2, '0');
  return '${two(wrapped ~/ 60)}:${two(wrapped % 60)}';
}

String _daypartKey(String time) {
  final hour = _parse(time) ~/ 60;
  if (hour < 12) return 'onboarding.reminder.morning';
  if (hour < 18) return 'onboarding.reminder.afternoon';
  return 'onboarding.reminder.evening';
}

class _ReminderRow extends StatelessWidget {
  const _ReminderRow({
    required this.template,
    required this.time,
    required this.onEdit,
  });

  final OnboardingTemplate template;
  final String time;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final accent = starnyxColorFromHex(template.colorHex);

    return Container(
      key: Key('onboarding-reminder-${template.id}'),
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surfaceLevel2,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: <Widget>[
          OnboardingSymbolTile(symbol: template.symbol, color: accent),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(template.titleKey.tr(), style: textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xxs),
                Row(
                  children: <Widget>[
                    AppIcon(
                      icon: HugeIconsStrokeRounded.strokeRoundedClock01,
                      color: accent,
                      size: 14,
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                    Flexible(
                      child: Text(
                        'onboarding.reminder.time_label'.tr(
                          args: <String>[time, _daypartKey(time).tr()],
                        ),
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontFeatures: AppFonts.tabularFigures,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            key: Key('onboarding-reminder-edit-${template.id}'),
            tooltip: 'onboarding.reminder.edit_time'.tr(),
            onPressed: onEdit,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceLevel3,
            ),
            icon: const AppIcon(
              icon: HugeIconsStrokeRounded.strokeRoundedPencilEdit02,
              color: AppColors.textSecondary,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

/// One time for every picked habit: nudge it in 15-minute steps, then apply.
class _SharedTimeCard extends StatelessWidget {
  const _SharedTimeCard({
    required this.time,
    required this.onEarlier,
    required this.onLater,
    required this.onApply,
  });

  final String time;
  final VoidCallback onEarlier;
  final VoidCallback onLater;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surfaceLevel1,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'onboarding.reminder.shared_title'.tr(),
                      style: textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'onboarding.reminder.shared_subtitle'.tr(),
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              OnboardingDotLabel(
                child: Text(
                  'onboarding.reminder.daily'.tr(),
                  style: textTheme.labelMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: <Widget>[
                IconButton(
                  key: const Key('onboarding-shared-earlier'),
                  tooltip: 'onboarding.reminder.earlier'.tr(),
                  onPressed: onEarlier,
                  icon: const AppIcon(
                    icon: HugeIconsStrokeRounded.strokeRoundedArrowDown01,
                    color: AppColors.textSecondary,
                  ),
                ),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      time,
                      key: const Key('onboarding-shared-time'),
                      style: textTheme.headlineLarge?.copyWith(
                        fontSize: 44,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        fontFeatures: AppFonts.tabularFigures,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  key: const Key('onboarding-shared-later'),
                  tooltip: 'onboarding.reminder.later'.tr(),
                  onPressed: onLater,
                  icon: const AppIcon(
                    icon: HugeIconsStrokeRounded.strokeRoundedArrowUp01,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppPrimaryButton(
            key: const Key('onboarding-shared-apply'),
            label: 'onboarding.reminder.apply_all'.tr(),
            variant: AppPrimaryButtonVariant.ghost,
            height: AppSize.iconButton,
            onPressed: onApply,
          ),
        ],
      ),
    );
  }
}
