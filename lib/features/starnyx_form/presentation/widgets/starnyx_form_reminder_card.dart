import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/core/widgets/core_widgets.dart';

/// "Nhắc nhở hằng ngày" card: bell squircle, title + subtitle, switch. When
/// on, a "Giờ nhắc nhở" row shows the time and opens the time picker.
class StarnyxFormReminderCard extends StatelessWidget {
  const StarnyxFormReminderCard({
    required this.reminderEnabled,
    required this.reminderTime,
    required this.onToggle,
    required this.onTapTime,
    super.key,
  });

  final bool reminderEnabled;
  final String reminderTime;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTapTime;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      radius: AppRadius.lg,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Center(
                  child: AppIcon(
                    icon: HugeIconsStrokeRounded.strokeRoundedNotification01,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'starnyx_form.reminder_label'.tr(),
                      style: textTheme.titleMedium?.copyWith(
                        fontFamily: AppFonts.body,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'starnyx_form.reminder_subtitle'.tr(),
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                key: const Key('starnyx-form-reminder-switch'),
                value: reminderEnabled,
                onChanged: onToggle,
              ),
            ],
          ),
          if (reminderEnabled) ...<Widget>[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Divider(height: 1, color: AppColors.borderSubtle),
            ),
            InkWell(
              key: const Key('starnyx-form-reminder-time'),
              onTap: onTapTime,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'starnyx_form.reminder_time_label'.tr(),
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Text(
                      reminderTime,
                      style: textTheme.titleMedium?.copyWith(
                        fontFamily: AppFonts.mono,
                        fontFeatures: AppFonts.tabularFigures,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    const AppIcon(
                      icon: HugeIconsStrokeRounded.strokeRoundedClock01,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
