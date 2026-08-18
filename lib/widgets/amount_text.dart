import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/formatters.dart';

class AmountText extends StatelessWidget {
  final double amount;
  final TransactionType type;
  final TextStyle? style;

  const AmountText({super.key, required this.amount, required this.type, this.style});

  @override
  Widget build(BuildContext context) {
    final color = switch (type) {
      TransactionType.income => AppColors.successGreen,
      TransactionType.expense => AppColors.expenseRed,
      TransactionType.transfer => AppColors.mutedGray,
    };
    final prefix = switch (type) {
      TransactionType.income => '+',
      TransactionType.expense => '-',
      TransactionType.transfer => '',
    };
    return Text(
      '$prefix${Formatters.currency(amount)}',
      style: (style ?? AppTextStyles.bodyStrong).copyWith(color: color),
    );
  }
}
