import '../models/transaction_model.dart';
import 'transaction_dao.dart';

/// Pure in-memory implementation used on web builds — nothing survives a
/// page refresh, by design (see `dao_factory_web.dart`).
class InMemoryTransactionDao implements TransactionDao {
  final List<MoneyTransaction> _transactions = [];

  int _compare(MoneyTransaction a, MoneyTransaction b) {
    final byDate = b.date.compareTo(a.date);
    if (byDate != 0) return byDate;
    return b.createdAt.compareTo(a.createdAt);
  }

  @override
  Future<List<MoneyTransaction>> getAll() async {
    return [..._transactions]..sort(_compare);
  }

  @override
  Future<List<MoneyTransaction>> getByAccount(String accountId) async {
    final filtered = _transactions
        .where((t) => t.accountId == accountId || t.toAccountId == accountId)
        .toList();
    filtered.sort(_compare);
    return filtered;
  }

  @override
  Future<MoneyTransaction?> getById(String id) async {
    for (final t in _transactions) {
      if (t.id == id) return t;
    }
    return null;
  }

  @override
  Future<void> insert(MoneyTransaction transaction) async {
    _transactions.add(transaction);
  }

  @override
  Future<void> update(MoneyTransaction transaction) async {
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index == -1) return;
    _transactions[index] = transaction;
  }

  @override
  Future<void> delete(String id) async {
    _transactions.removeWhere((t) => t.id == id);
  }
}
