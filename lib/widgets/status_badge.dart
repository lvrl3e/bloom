import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final String? emoji;

  const StatusBadge({super.key, required this.label, required this.color, this.emoji});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (emoji != null) ...[
            Text(emoji!, style: const TextStyle(fontSize: 10)),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
