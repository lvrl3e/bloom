import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({super.key, required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.title),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.bloomPink,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}
