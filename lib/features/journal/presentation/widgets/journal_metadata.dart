import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/core/widgets/app_icon.dart';
import 'package:starnyx/domain/entities/journal_entry.dart';

/// Icon, accent and label for each [JournalMood]; shared by the journal list,
/// the editor and the journal detail screen.
extension JournalMoodUi on JournalMood {
  List<List<dynamic>> get icon => switch (this) {
    JournalMood.calm => HugeIconsStrokeRounded.strokeRoundedLeaf01,
    JournalMood.energized => HugeIconsStrokeRounded.strokeRoundedFlash,
    JournalMood.focused => HugeIconsStrokeRounded.strokeRoundedCoffee01,
    JournalMood.tired => HugeIconsStrokeRounded.strokeRoundedCloudAngledRain,
  };

  Color get color => switch (this) {
    JournalMood.calm => AppColors.primary,
    JournalMood.energized => AppColors.tertiary,
    JournalMood.focused => AppColors.secondary,
    JournalMood.tired => AppColors.textSecondary,
  };

  String get label => 'journal.mood_$name'.tr();
}

/// "7h 45m" style sleep duration.
String formatSleepMinutes(int minutes) => 'journal.sleep_value'.tr(
  args: <String>['${minutes ~/ 60}', '${minutes % 60}'.padLeft(2, '0')],
);

/// Small mono pill used for mood and tag chips on journal cards.
class JournalMetaChip extends StatelessWidget {
  const JournalMetaChip({
    required this.label,
    required this.color,
    this.icon,
    super.key,
  });

  final String label;
  final Color color;
  final List<List<dynamic>>? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceLevel3,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            AppIcon(icon: icon!, size: 12, color: color),
            const SizedBox(width: AppSpacing.xxs),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontFamily: AppFonts.mono,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
