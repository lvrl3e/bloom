import '../models/account_model.dart';
import 'account_dao.dart';

/// Pure in-memory implementation used on web builds — nothing survives a
/// page refresh, by design (see `dao_factory_web.dart`).
class InMemoryAccountDao implements AccountDao {
  final List<Account> _accounts = [];

  @override
  Future<List<Account>> getAll() async {
    final sorted = [..._accounts]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return sorted;
  }

  @override
  Future<Account?> getById(String id) async {
    for (final a in _accounts) {
      if (a.id == id) return a;
    }
    return null;
  }

  @override
  Future<void> insert(Account account) async {
    _accounts.add(account);
  }

  @override
  Future<void> update(Account account) async {
    final index = _accounts.indexWhere((a) => a.id == account.id);
    if (index == -1) return;
    _accounts[index] = account;
  }

  @override
  Future<void> updateBalance(String id, double newBalance, DateTime updatedAt) async {
    final index = _accounts.indexWhere((a) => a.id == id);
    if (index == -1) return;
    _accounts[index] = _accounts[index].copyWith(balance: newBalance, updatedAt: updatedAt);
  }

  @override
  Future<void> delete(String id) async {
    _accounts.removeWhere((a) => a.id == id);
  }
}
