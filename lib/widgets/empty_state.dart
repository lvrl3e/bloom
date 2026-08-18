import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.xxxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.bloomPink.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: AppColors.bloomPink),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(title, style: AppTextStyles.title, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            style: AppTextStyles.body.copyWith(color: AppColors.mutedGray),
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: onAction,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(actionLabel!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
