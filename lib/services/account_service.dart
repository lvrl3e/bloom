import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../database/account_dao.dart';
import '../database/dao_factory.dart';
import '../models/account_model.dart';

/// Owns the accounts list and their balances. Transaction/goal services
/// call [adjustBalance] instead of writing to the accounts table directly,
/// so balance math stays in one place.
class AccountService extends ChangeNotifier {
  final AccountDao _dao;
  final _uuid = const Uuid();

  AccountService({AccountDao? dao}) : _dao = dao ?? createAccountDao();

  List<Account> _accounts = [];
  bool _isLoading = true;
  String? _error;

  List<Account> get accounts => List.unmodifiable(_accounts);
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalBalance =>
      _accounts.fold(0.0, (sum, a) => sum + a.balance);

  Account? byId(String id) {
    for (final a in _accounts) {
      if (a.id == id) return a;
    }
    return null;
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _accounts = await _dao.getAll();
    } catch (e) {
      _error = 'Could not load accounts.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Account> addAccount({
    required String name,
    required AccountType type,
    required double balance,
    String currency = 'PHP',
    String? notes,
  }) async {
    final now = DateTime.now();
    final account = Account(
      id: _uuid.v4(),
      name: name.trim(),
      type: type,
      balance: balance,
      currency: currency,
      notes: (notes?.trim().isEmpty ?? true) ? null : notes!.trim(),
      createdAt: now,
      updatedAt: now,
    );
    await _dao.insert(account);
    _accounts = [..._accounts, account];
    notifyListeners();
    return account;
  }

  Future<void> updateAccount(
    String id, {
    required String name,
    required AccountType type,
    String currency = 'PHP',
    String? notes,
  }) async {
    final index = _accounts.indexWhere((a) => a.id == id);
    if (index == -1) return;
    final updated = _accounts[index].copyWith(
      name: name.trim(),
      type: type,
      currency: currency,
      notes: (notes?.trim().isEmpty ?? true) ? null : notes!.trim(),
      updatedAt: DateTime.now(),
    );
    await _dao.update(updated);
    _accounts = [..._accounts]..[index] = updated;
    notifyListeners();
  }

  Future<void> deleteAccount(String id) async {
    await _dao.delete(id);
    _accounts = _accounts.where((a) => a.id != id).toList();
    notifyListeners();
  }

  /// Applies a balance delta (positive or negative) to an account, used by
  /// TransactionService/GoalService when money moves.
  Future<void> adjustBalance(String accountId, double delta) async {
    final index = _accounts.indexWhere((a) => a.id == accountId);
    if (index == -1) return;
    final now = DateTime.now();
    final newBalance = _accounts[index].balance + delta;
    await _dao.updateBalance(accountId, newBalance, now);
    _accounts = [..._accounts]
      ..[index] = _accounts[index].copyWith(balance: newBalance, updatedAt: now);
    notifyListeners();
  }
}
