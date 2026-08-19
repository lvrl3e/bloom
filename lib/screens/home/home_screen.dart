import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/account_model.dart';
import '../../models/transaction_model.dart';
import '../../services/account_service.dart';
import '../../services/analytics_service.dart';
import '../../services/goal_service.dart';
import '../../services/transaction_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/formatters.dart';
import '../../widgets/bloom_logo.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/goal_card.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stat_tile.dart';
import '../../widgets/theme_toggle_button.dart';
import '../../widgets/transaction_tile.dart';
import '../accounts/accounts_screen.dart';
import '../accounts/add_account_sheet.dart';
import '../goals/add_goal_sheet.dart';
import '../goals/goal_detail_screen.dart';
import '../goals/goals_screen.dart';
import '../transactions/add_transaction_sheet.dart';
import '../transactions/transactions_screen.dart';

const _analytics = AnalyticsService();

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accountService = context.watch<AccountService>();
    final txService = context.watch<TransactionService>();
    final goalService = context.watch<GoalService>();

    final isLoading = accountService.isLoading || txService.isLoading || goalService.isLoading;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const BloomLogo(size: 26),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('BLOOM', style: AppTextStyles.title),
                Text(
                  'Track. Save. Bloom.',
                  style: AppTextStyles.caption.copyWith(color: AppColors.mutedGray),
                ),
              ],
            ),
          ],
        ),
        actions: const [ThemeToggleButton()],
      ),
      body: SafeArea(
        child: isLoading
            ? const LoadingView()
            : RefreshIndicator(
                color: AppColors.bloomPink,
                onRefresh: () => Future.wait([
                  accountService.load(),
                  txService.load(),
                  goalService.load(),
                ]),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 100),
                  children: [
                    _BalanceCard(total: accountService.totalBalance),
                    const SizedBox(height: AppSpacing.lg),
                    _MonthlyOverview(transactions: txService.transactions),
                    const SizedBox(height: AppSpacing.xl),
                    ElevatedButton.icon(
                      onPressed: () => showAddTransactionSheet(context),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add Transaction'),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    SectionHeader(
                      title: 'Accounts',
                      actionLabel: accountService.accounts.isEmpty ? null : 'See all',
                      onAction: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AccountsScreen()),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (accountService.accounts.isEmpty)
                      EmptyState(
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'No accounts yet',
                        message: 'Add a bank, e-wallet, or cash account to get started.',
                        actionLabel: 'Add Account',
                        onAction: () => showAddAccountSheet(context),
                      )
                    else
                      SizedBox(
                        height: 108,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: accountService.accounts.length,
                          separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
                          itemBuilder: (context, index) {
                            final account = accountService.accounts[index];
                            return Container(
                              width: 160,
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(AppRadius.lg),
                                border: Border.all(color: Theme.of(context).dividerColor),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(account.type.icon, color: AppColors.bloomPink, size: 20),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        account.name,
                                        style: AppTextStyles.caption.copyWith(color: AppColors.mutedGray),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        Formatters.currency(account.balance),
                                        style: AppTextStyles.numericMedium,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: AppSpacing.xxl),
                    SectionHeader(
                      title: 'Recent Transactions',
                      actionLabel: txService.transactions.isEmpty ? null : 'See all',
                      onAction: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const TransactionsScreen()),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (txService.transactions.isEmpty)
                      EmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: 'No transactions yet',
                        message: 'Your income and expenses will show up here.',
                        actionLabel: 'Add Transaction',
                        onAction: () => showAddTransactionSheet(context),
                      )
                    else
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                          child: Column(
                            children: txService.recent.map((t) {
                              final accountName = accountService.byId(t.accountId)?.name ?? 'Unknown';
                              final toAccountName =
                                  t.toAccountId != null ? accountService.byId(t.toAccountId!)?.name : null;
                              return TransactionTile(
                                transaction: t,
                                accountName: accountName,
                                toAccountName: toAccountName,
                                onTap: () => showAddTransactionSheet(context, transaction: t),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.xxl),
                    SectionHeader(
                      title: 'Goal Progress',
                      actionLabel: goalService.goals.isEmpty ? null : 'See all',
                      onAction: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const GoalsScreen()),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (goalService.goals.isEmpty)
                      EmptyState(
                        icon: Icons.flag_outlined,
                        title: 'No goals yet',
                        message: 'Create a savings goal and track your progress here.',
                        actionLabel: 'Create Goal',
                        onAction: () => showAddGoalSheet(context),
                      )
                    else
                      ...goalService.activeGoals.take(2).map(
                            (goal) => Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.md),
                              child: GoalCard(
                                goal: goal,
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => GoalDetailScreen(goalId: goal.id)),
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final double total;
  const _BalanceCard({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.deepBlack,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TOTAL BALANCE', style: AppTextStyles.overline.copyWith(color: AppColors.softPink)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            Formatters.currency(total),
            style: AppTextStyles.numericLarge.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _MonthlyOverview extends StatelessWidget {
  final List<MoneyTransaction> transactions;
  const _MonthlyOverview({required this.transactions});

  @override
  Widget build(BuildContext context) {
    final income = _analytics.totalIncome(transactions, month: DateTime.now());
    final expenses = _analytics.totalExpenses(transactions, month: DateTime.now());
    final savings = income - expenses;
    final rate = income <= 0 ? 0.0 : (savings / income).clamp(-5.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(Formatters.monthYear(DateTime.now()), style: AppTextStyles.subtitle.copyWith(color: AppColors.mutedGray)),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: StatTile(
                label: 'Income',
                value: Formatters.currencyCompact(income),
                icon: Icons.arrow_downward_rounded,
                accentColor: AppColors.successGreen,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: StatTile(
                label: 'Expenses',
                value: Formatters.currencyCompact(expenses),
                icon: Icons.arrow_upward_rounded,
                accentColor: AppColors.expenseRed,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: StatTile(
                label: 'Saved',
                value: Formatters.currencyCompact(savings),
                icon: Icons.savings_rounded,
                accentColor: AppColors.bloomPink,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Container(
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
                        const Icon(Icons.percent_rounded, size: 16, color: AppColors.bloomPink),
                        const SizedBox(width: 6),
                        Text(
                          'Savings Rate',
                          style: AppTextStyles.caption.copyWith(color: AppColors.mutedGray),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(Formatters.percent(rate), style: AppTextStyles.numericMedium),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
