import 'package:flutter/material.dart';
import 'package:starnyx/core/constants/core_constants.dart';

class StarnyxFormReminderCard extends StatelessWidget {
  const StarnyxFormReminderCard({
    required this.reminderEnabled,
    required this.reminderTime,
    required this.label,
    required this.onToggle,
    required this.onTapTime,
    super.key,
  });

  final bool reminderEnabled;
  final String reminderTime;
  final String label;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTapTime;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: reminderEnabled ? onTapTime : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: <Color>[Color(0xFF1F2024), Color(0xFF28292F)],
          ),
          border: Border.all(color: AppColors.outline.withValues(alpha: 0.62)),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                reminderEnabled ? '$label • $reminderTime' : label,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Transform.scale(
              scale: 1.08,
              child: Switch.adaptive(
                value: reminderEnabled,
                onChanged: onToggle,
                activeThumbColor: Colors.white,
                activeTrackColor: const Color(0xFF666874),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xFF666874),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
