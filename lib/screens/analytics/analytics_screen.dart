import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/account_model.dart';
import '../../models/goal_model.dart';
import '../../models/transaction_model.dart';
import '../../services/account_service.dart';
import '../../services/analytics_service.dart';
import '../../services/goal_service.dart';
import '../../services/transaction_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/formatters.dart';
import '../../widgets/bloom_progress_bar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stat_tile.dart';

const _analytics = AnalyticsService();

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accountService = context.watch<AccountService>();
    final txService = context.watch<TransactionService>();
    final goalService = context.watch<GoalService>();

    final isLoading = accountService.isLoading || txService.isLoading || goalService.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: SafeArea(
        child: isLoading
            ? const LoadingView()
            : txService.transactions.isEmpty
                ? SingleChildScrollView(
                    child: EmptyState(
                      icon: Icons.pie_chart_outline_rounded,
                      title: 'No data yet',
                      message: 'Add transactions to see your spending trends and financial insights.',
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 100),
                    children: [
                      _SummaryGrid(accountService: accountService, txService: txService),
                      const SizedBox(height: AppSpacing.xxl),
                      const SectionHeader(title: 'Income vs Expenses'),
                      const SizedBox(height: AppSpacing.md),
                      _IncomeExpenseChart(transactions: txService.transactions),
                      const SizedBox(height: AppSpacing.xxl),
                      const SectionHeader(title: 'Net Worth Trend'),
                      const SizedBox(height: AppSpacing.md),
                      _NetWorthChart(
                        accounts: accountService.accounts,
                        transactions: txService.transactions,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      const SectionHeader(title: 'Spending by Category'),
                      const SizedBox(height: AppSpacing.md),
                      _CategoryBreakdown(transactions: txService.transactions),
                      const SizedBox(height: AppSpacing.xxl),
                      const SectionHeader(title: 'Account Balances'),
                      const SizedBox(height: AppSpacing.md),
                      _AccountBalanceBars(accounts: accountService.accounts),
                      if (goalService.goals.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xxl),
                        const SectionHeader(title: 'Goal Progress'),
                        const SizedBox(height: AppSpacing.md),
                        _GoalProgressList(goalService: goalService),
                      ],
                    ],
                  ),
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  final AccountService accountService;
  final TransactionService txService;

  const _SummaryGrid({required this.accountService, required this.txService});

  @override
  Widget build(BuildContext context) {
    final txs = txService.transactions;
    final totalIncome = _analytics.totalIncome(txs);
    final totalExpenses = _analytics.totalExpenses(txs);
    final savingsRate = _analytics.savingsRate(txs, month: DateTime.now());
    final avgSpending = _analytics.averageMonthlySpending(txs);
    final highest = _analytics.highestSpendingCategory(txs);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: StatTile(
                label: 'Total Income',
                value: Formatters.currencyCompact(totalIncome),
                icon: Icons.arrow_downward_rounded,
                accentColor: AppColors.successGreen,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: StatTile(
                label: 'Total Expenses',
                value: Formatters.currencyCompact(totalExpenses),
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
                label: 'Savings Rate',
                value: Formatters.percent(savingsRate),
                icon: Icons.percent_rounded,
                accentColor: AppColors.bloomPink,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: StatTile(
                label: 'Avg. Monthly Spend',
                value: Formatters.currencyCompact(avgSpending),
                icon: Icons.calendar_month_rounded,
                accentColor: AppColors.mutedGray,
              ),
            ),
          ],
        ),
        if (highest != null) ...[
          const SizedBox(height: AppSpacing.md),
          StatTile(
            label: 'Highest Spending Category',
            value: '${highest.category} · ${Formatters.currencyCompact(highest.amount)}',
            icon: Icons.local_fire_department_rounded,
            accentColor: AppColors.expenseRed,
          ),
        ],
      ],
    );
  }
}

class _IncomeExpenseChart extends StatelessWidget {
  final List<MoneyTransaction> transactions;
  const _IncomeExpenseChart({required this.transactions});

  @override
  Widget build(BuildContext context) {
    final trends = _analytics.monthlyTrends(transactions, monthsBack: 6);
    final maxValue = trends.fold<double>(
      0,
      (max, t) => [max, t.income, t.expense].reduce((a, b) => a > b ? a : b),
    );
    final chartMax = maxValue <= 0 ? 100.0 : maxValue * 1.2;

    return Container(
      height: 240,
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg, AppSpacing.md, AppSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: BarChart(
        BarChartData(
          maxY: chartMax,
          minY: 0,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => AppColors.surfaceElevatedDark,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  Formatters.currency(rod.toY),
                  const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= trends.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      Formatters.monthShort(trends[index].month),
                      style: AppTextStyles.caption.copyWith(color: AppColors.mutedGray),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < trends.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: trends[i].income,
                    color: AppColors.successGreen,
                    width: 8,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  BarChartRodData(
                    toY: trends[i].expense,
                    color: AppColors.expenseRed,
                    width: 8,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ],
                barsSpace: 4,
              ),
          ],
        ),
      ),
    );
  }
}

class _NetWorthChart extends StatelessWidget {
  final List<Account> accounts;
  final List<MoneyTransaction> transactions;
  const _NetWorthChart({required this.accounts, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final points = _analytics.netWorthOverTime(accounts, transactions, monthsBack: 6);
    final values = points.map((p) => p.value).toList();
    final minY = (values.reduce((a, b) => a < b ? a : b)) * (values.any((v) => v < 0) ? 1.2 : 0.9);
    final maxY = (values.reduce((a, b) => a > b ? a : b)) * 1.1;

    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: LineChart(
        LineChartData(
          minY: minY == 0 ? -100 : minY,
          maxY: maxY == 0 ? 100 : maxY,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppColors.surfaceElevatedDark,
              getTooltipItems: (spots) => spots
                  .map((s) => LineTooltipItem(
                        Formatters.currency(s.y),
                        const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                      ))
                  .toList(),
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= points.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      Formatters.monthShort(points[index].date),
                      style: AppTextStyles.caption.copyWith(color: AppColors.mutedGray),
                    ),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [for (var i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i].value)],
              isCurved: true,
              color: AppColors.bloomPink,
              barWidth: 3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: AppColors.bloomPink.withValues(alpha: 0.12)),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBreakdown extends StatelessWidget {
  final List<MoneyTransaction> transactions;
  const _CategoryBreakdown({required this.transactions});

  static const _palette = [
    AppColors.bloomPink,
    AppColors.softPink,
    Color(0xFF3B82F6),
    Color(0xFFF59E0B),
    Color(0xFF8B5CF6),
    Color(0xFF06B6D4),
    Color(0xFF22C55E),
    AppColors.mutedGray,
  ];

  @override
  Widget build(BuildContext context) {
    final breakdown = _analytics.spendingByCategory(transactions);
    if (breakdown.isEmpty) {
      return const EmptyState(
        icon: Icons.donut_small_rounded,
        title: 'No expenses yet',
        message: 'Your category breakdown will appear once you log expenses.',
      );
    }

    final total = breakdown.fold<double>(0, (sum, c) => sum + c.amount);
    final top = breakdown.take(8).toList();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 46,
                sections: [
                  for (var i = 0; i < top.length; i++)
                    PieChartSectionData(
                      value: top[i].amount,
                      color: _palette[i % _palette.length],
                      title: '',
                      radius: 40,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...top.asMap().entries.map((entry) {
            final i = entry.key;
            final c = entry.value;
            final pct = total <= 0 ? 0.0 : c.amount / total;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(color: _palette[i % _palette.length], shape: BoxShape.circle),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(c.category, style: AppTextStyles.body, overflow: TextOverflow.ellipsis),
                  ),
                  Text(Formatters.currencyCompact(c.amount), style: AppTextStyles.bodyStrong),
                  const SizedBox(width: AppSpacing.sm),
                  SizedBox(
                    width: 40,
                    child: Text(
                      Formatters.percent(pct),
                      textAlign: TextAlign.right,
                      style: AppTextStyles.caption.copyWith(color: AppColors.mutedGray),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _AccountBalanceBars extends StatelessWidget {
  final List<Account> accounts;
  const _AccountBalanceBars({required this.accounts});

  @override
  Widget build(BuildContext context) {
    if (accounts.isEmpty) {
      return const EmptyState(
        icon: Icons.account_balance_wallet_outlined,
        title: 'No accounts yet',
        message: 'Add accounts to see their balances compared here.',
      );
    }
    final maxBalance = accounts.fold<double>(0, (max, a) => a.balance > max ? a.balance : max);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: accounts.map<Widget>((account) {
          final ratio = maxBalance <= 0 ? 0.0 : (account.balance / maxBalance).clamp(0.0, 1.0);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(account.name, style: AppTextStyles.body),
                    Text(Formatters.currencyCompact(account.balance), style: AppTextStyles.bodyStrong),
                  ],
                ),
                const SizedBox(height: 6),
                BloomProgressBar(value: ratio, height: 6),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _GoalProgressList extends StatelessWidget {
  final GoalService goalService;
  const _GoalProgressList({required this.goalService});

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
        children: goalService.goals.map((goal) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(goal.name, style: AppTextStyles.body, overflow: TextOverflow.ellipsis)),
                    Text(Formatters.percent(goal.percentComplete), style: AppTextStyles.bodyStrong),
                  ],
                ),
                const SizedBox(height: 6),
                BloomProgressBar(value: goal.percentComplete, color: goal.status.color, height: 6),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
