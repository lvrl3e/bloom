import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/formatters.dart';
import 'amount_text.dart';
import 'icon_avatar.dart';

class TransactionTile extends StatelessWidget {
  final MoneyTransaction transaction;
  final String accountName;
  final String? toAccountName;
  final VoidCallback? onTap;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.accountName,
    this.toAccountName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final category = transaction.type == TransactionType.transfer
        ? TransactionCategory.transferCategory
        : TransactionCategory.findByName(transaction.category);

    final subtitle = transaction.type == TransactionType.transfer
        ? '$accountName → ${toAccountName ?? '—'}'
        : accountName;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: 4),
        child: Row(
          children: [
            IconAvatar(icon: category.icon, color: category.color, size: 42),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description?.isNotEmpty == true
                        ? transaction.description!
                        : transaction.category,
                    style: AppTextStyles.bodyStrong,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$subtitle · ${Formatters.relativeDay(transaction.date)}',
                    style: AppTextStyles.caption.copyWith(color: AppColors.mutedGray),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            AmountText(amount: transaction.amount, type: transaction.type),
          ],
        ),
      ),
    );
  }
}
