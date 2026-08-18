import '../models/account_model.dart';
import '../models/transaction_model.dart';

class CategorySpend {
  final String category;
  final double amount;
  const CategorySpend(this.category, this.amount);
}

class MonthlyTrend {
  final DateTime month;
  final double income;
  final double expense;
  double get savings => income - expense;
  const MonthlyTrend(this.month, this.income, this.expense);
}

class NetWorthPoint {
  final DateTime date;
  final double value;
  const NetWorthPoint(this.date, this.value);
}

/// Pure, stateless computations over transactions/accounts/goals.
/// Kept separate from AccountService/TransactionService so the analytics
/// screen never mutates data — it only reads and derives.
class AnalyticsService {
  const AnalyticsService();

  bool _isSameMonth(DateTime a, DateTime b) => a.year == b.year && a.month == b.month;

  double totalIncome(List<MoneyTransaction> transactions, {DateTime? month}) {
    return transactions
        .where((t) => t.type == TransactionType.income)
        .where((t) => month == null || _isSameMonth(t.date, month))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double totalExpenses(List<MoneyTransaction> transactions, {DateTime? month}) {
    return transactions
        .where((t) => t.type == TransactionType.expense)
        .where((t) => month == null || _isSameMonth(t.date, month))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double totalSavings(List<MoneyTransaction> transactions, {DateTime? month}) {
    return totalIncome(transactions, month: month) - totalExpenses(transactions, month: month);
  }

  double savingsRate(List<MoneyTransaction> transactions, {DateTime? month}) {
    final income = totalIncome(transactions, month: month);
    if (income <= 0) return 0;
    return (totalSavings(transactions, month: month) / income).clamp(-5.0, 1.0);
  }

  List<CategorySpend> spendingByCategory(
    List<MoneyTransaction> transactions, {
    DateTime? month,
  }) {
    final map = <String, double>{};
    for (final t in transactions) {
      if (t.type != TransactionType.expense) continue;
      if (month != null && !_isSameMonth(t.date, month)) continue;
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    final entries = map.entries.map((e) => CategorySpend(e.key, e.value)).toList();
    entries.sort((a, b) => b.amount.compareTo(a.amount));
    return entries;
  }

  CategorySpend? highestSpendingCategory(
    List<MoneyTransaction> transactions, {
    DateTime? month,
  }) {
    final list = spendingByCategory(transactions, month: month);
    return list.isEmpty ? null : list.first;
  }

  double averageMonthlySpending(List<MoneyTransaction> transactions) {
    final trends = monthlyTrends(transactions, monthsBack: 6);
    final withActivity = trends.where((t) => t.expense > 0).toList();
    if (withActivity.isEmpty) return 0;
    final total = withActivity.fold(0.0, (sum, t) => sum + t.expense);
    return total / withActivity.length;
  }

  List<MonthlyTrend> monthlyTrends(List<MoneyTransaction> transactions, {int monthsBack = 6}) {
    final now = DateTime.now();
    final months = List.generate(monthsBack, (i) {
      final m = DateTime(now.year, now.month - (monthsBack - 1 - i), 1);
      return m;
    });

    return months.map((m) {
      final income = totalIncome(transactions, month: m);
      final expense = totalExpenses(transactions, month: m);
      return MonthlyTrend(m, income, expense);
    }).toList();
  }

  /// Approximates net worth at the end of each of the trailing [monthsBack]
  /// months (plus today) by subtracting the net effect of every transaction
  /// that happened *after* that point from the current total balance.
  /// Transfers between the user's own accounts net to zero, so only
  /// income/expense need to be undone.
  List<NetWorthPoint> netWorthOverTime(
    List<Account> accounts,
    List<MoneyTransaction> transactions, {
    int monthsBack = 6,
  }) {
    final now = DateTime.now();
    final currentTotal = accounts.fold(0.0, (sum, a) => sum + a.balance);

    // Cutoffs, oldest to newest: end of each past month, then "today".
    final cutoffs = <DateTime>[
      for (var i = monthsBack; i >= 1; i--)
        DateTime(now.year, now.month - i + 1, 1).subtract(const Duration(seconds: 1)),
      DateTime(now.year, now.month, now.day, 23, 59, 59),
    ];

    return cutoffs.map((cutoff) {
      double netAfterCutoff = 0;
      for (final t in transactions) {
        if (!t.date.isAfter(cutoff)) continue;
        if (t.type == TransactionType.income) netAfterCutoff += t.amount;
        if (t.type == TransactionType.expense) netAfterCutoff -= t.amount;
      }
      return NetWorthPoint(cutoff, currentTotal - netAfterCutoff);
    }).toList();
  }
}
