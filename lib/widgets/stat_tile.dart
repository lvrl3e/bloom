import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Small metric card used on Home and Analytics (Income / Expenses / Saved).
class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;

  const StatTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.accentColor = AppColors.bloomPink,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: accentColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.caption.copyWith(color: AppColors.mutedGray),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: AppTextStyles.numericMedium),
          ),
        ],
      ),
    );
  }
}
