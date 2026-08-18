import 'package:flutter/material.dart';
import '../models/goal_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/formatters.dart';
import 'bloom_progress_bar.dart';
import 'icon_avatar.dart';
import 'status_badge.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback? onTap;

  const GoalCard({super.key, required this.goal, this.onTap});

  @override
  Widget build(BuildContext context) {
    final status = goal.status;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconAvatar(icon: GoalCategoryPreset.iconFor(goal.category), color: AppColors.bloomPink),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(goal.name, style: AppTextStyles.bodyStrong, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(
                          goal.category,
                          style: AppTextStyles.caption.copyWith(color: AppColors.mutedGray),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(label: status.label, color: status.color, emoji: status.emoji),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(Formatters.currency(goal.currentAmount), style: AppTextStyles.numericMedium),
                  Text(
                    ' / ${Formatters.currency(goal.targetAmount)}',
                    style: AppTextStyles.body.copyWith(color: AppColors.mutedGray),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              BloomProgressBar(value: goal.percentComplete, color: status.color),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${Formatters.percent(goal.percentComplete)} complete',
                    style: AppTextStyles.caption.copyWith(color: AppColors.mutedGray),
                  ),
                  Text(
                    goal.status == GoalStatus.completed
                        ? 'Goal reached!'
                        : '${Formatters.currency(goal.remainingAmount)} left',
                    style: AppTextStyles.caption.copyWith(color: AppColors.mutedGray),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                goal.status == GoalStatus.completed
                    ? 'Completed'
                    : 'Target: ${Formatters.monthYear(goal.targetDate)}',
                style: AppTextStyles.caption.copyWith(color: AppColors.mutedGray),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
