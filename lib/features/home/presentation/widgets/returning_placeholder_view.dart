import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/core/utils/date_utils.dart' as core_date_utils;
import 'package:starnyx/core/widgets/core_widgets.dart';
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:starnyx/features/starnyx_form/presentation/widgets/starnyx_form_color_utils.dart';

class ReturningPlaceholderView extends StatelessWidget {
  const ReturningPlaceholderView({
    required this.starnyxs,
    required this.onCreatePressed,
    required this.onEditPressed,
    super.key,
  });

  final List<StarNyx> starnyxs;
  final VoidCallback onCreatePressed;
  final ValueChanged<StarNyx> onEditPressed;

  @override
  Widget build(BuildContext context) {
    return CosmicBackground(
      bottomGlowColor: AppColors.accentOrange,
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: AppSpacing.pagePadding,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppLayout.contentMaxWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  AppSectionTitle(
                    title: 'home.returning_title'.tr(),
                    subtitle: 'home.returning_subtitle'.tr(
                      args: <String>[starnyxs.length.toString()],
                    ),
                    trailing: TextButton(
                      onPressed: onCreatePressed,
                      child: Text('home.new_constellation'.tr()),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.section),
                  AppEmptyState(
                    title: 'home.returning_empty_title'.tr(),
                    message: 'home.returning_empty_message'.tr(),
                  ),
                  const SizedBox(height: AppSpacing.section),
                  Text(
                    'home.constellation_list_title'.tr(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: starnyxs.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (BuildContext context, int index) {
                      final starnyx = starnyxs[index];
                      return _ReturningStarnyxCard(
                        starnyx: starnyx,
                        onEditPressed: () => onEditPressed(starnyx),
                      );
                    },
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

class _ReturningStarnyxCard extends StatelessWidget {
  const _ReturningStarnyxCard({
    required this.starnyx,
    required this.onEditPressed,
  });

  final StarNyx starnyx;
  final VoidCallback onEditPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.42)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 14,
                height: 14,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: starnyxColorFromHex(starnyx.color),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(starnyx.title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      starnyx.hasDescription
                          ? starnyx.description!
                          : 'home.constellation_no_description'.tr(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              OutlinedButton(
                onPressed: onEditPressed,
                child: Text('home.edit_constellation'.tr()),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              _MetaChip(
                icon: Icons.calendar_today_outlined,
                label: 'home.start_date_chip'.tr(
                  args: <String>[
                    core_date_utils.DateUtils.formatDdMmYyyy(starnyx.startDate),
                  ],
                ),
              ),
              _MetaChip(
                icon: Icons.notifications_none_rounded,
                label: starnyx.hasReminder
                    ? 'home.reminder_enabled_chip'.tr(
                        args: <String>[starnyx.reminderTime!],
                      )
                    : 'home.reminder_disabled_chip'.tr(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
