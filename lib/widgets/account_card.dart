import 'package:flutter/material.dart';
import '../models/account_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/formatters.dart';
import 'icon_avatar.dart';

class AccountCard extends StatelessWidget {
  final Account account;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AccountCard({
    super.key,
    required this.account,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isNegative = account.balance < 0;
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
                  IconAvatar(icon: account.type.icon, color: AppColors.bloomPink),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(account.name, style: AppTextStyles.bodyStrong, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(
                          account.type.label,
                          style: AppTextStyles.caption.copyWith(color: AppColors.mutedGray),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded, color: AppColors.mutedGray),
                    onSelected: (value) {
                      if (value == 'edit') onEdit?.call();
                      if (value == 'delete') onDelete?.call();
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                Formatters.currency(account.balance),
                style: AppTextStyles.numericMedium.copyWith(
                  color: isNegative ? AppColors.expenseRed : Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Updated ${Formatters.relativeDay(account.updatedAt)}',
                style: AppTextStyles.caption.copyWith(color: AppColors.mutedGray),
              ),
              if (account.notes != null && account.notes!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  account.notes!,
                  style: AppTextStyles.caption.copyWith(color: AppColors.mutedGray),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
