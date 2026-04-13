import 'package:flutter/material.dart';
import 'package:starnyx/core/constants/core_constants.dart';

class StarnyxFormStartOnCard extends StatelessWidget {
  const StarnyxFormStartOnCard({
    required this.value,
    required this.onTap,
    super.key,
  });

  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 62,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
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
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: Color(0xFFA7A8AF),
            ),
          ],
        ),
      ),
    );
  }
}
