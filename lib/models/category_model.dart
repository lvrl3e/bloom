import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A spending/income category. Kept as a static catalogue for now; can be
/// migrated to a database-backed, user-editable list later.
class TransactionCategory {
  final String name;
  final IconData icon;
  final Color color;

  const TransactionCategory({
    required this.name,
    required this.icon,
    required this.color,
  });

  static const List<TransactionCategory> incomeCategories = [
    TransactionCategory(name: 'Salary', icon: Icons.work_rounded, color: AppColors.successGreen),
    TransactionCategory(name: 'Business', icon: Icons.storefront_rounded, color: AppColors.bloomPink),
    TransactionCategory(name: 'Freelance', icon: Icons.laptop_mac_rounded, color: AppColors.softPink),
    TransactionCategory(name: 'Investment', icon: Icons.trending_up_rounded, color: AppColors.successGreen),
    TransactionCategory(name: 'Gift', icon: Icons.card_giftcard_rounded, color: AppColors.lightPink),
    TransactionCategory(name: 'Refund', icon: Icons.replay_rounded, color: AppColors.mutedGray),
    TransactionCategory(name: 'Other Income', icon: Icons.attach_money_rounded, color: AppColors.mutedGray),
  ];

  static const List<TransactionCategory> expenseCategories = [
    TransactionCategory(name: 'Food & Dining', icon: Icons.restaurant_rounded, color: AppColors.expenseRed),
    TransactionCategory(name: 'Groceries', icon: Icons.shopping_basket_rounded, color: Color(0xFFF59E0B)),
    TransactionCategory(name: 'Transport', icon: Icons.directions_car_filled_rounded, color: Color(0xFF3B82F6)),
    TransactionCategory(name: 'Bills & Utilities', icon: Icons.receipt_long_rounded, color: Color(0xFF8B5CF6)),
    TransactionCategory(name: 'Shopping', icon: Icons.shopping_bag_rounded, color: AppColors.bloomPink),
    TransactionCategory(name: 'Entertainment', icon: Icons.movie_filter_rounded, color: Color(0xFF06B6D4)),
    TransactionCategory(name: 'Health', icon: Icons.favorite_rounded, color: Color(0xFFF43F5E)),
    TransactionCategory(name: 'Education', icon: Icons.school_rounded, color: Color(0xFF6366F1)),
    TransactionCategory(name: 'Rent', icon: Icons.home_rounded, color: Color(0xFF0EA5E9)),
    TransactionCategory(name: 'Subscriptions', icon: Icons.subscriptions_rounded, color: Color(0xFFA855F7)),
    TransactionCategory(name: 'Travel', icon: Icons.flight_takeoff_rounded, color: AppColors.softPink),
    TransactionCategory(name: 'Other Expense', icon: Icons.more_horiz_rounded, color: AppColors.mutedGray),
  ];

  static const TransactionCategory transferCategory = TransactionCategory(
    name: 'Transfer',
    icon: Icons.swap_horiz_rounded,
    color: AppColors.mutedGray,
  );

  static TransactionCategory findByName(String name) {
    final all = [...incomeCategories, ...expenseCategories, transferCategory];
    return all.firstWhere(
      (c) => c.name == name,
      orElse: () => expenseCategories.last,
    );
  }
}
