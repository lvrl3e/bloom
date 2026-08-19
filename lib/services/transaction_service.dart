import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../database/dao_factory.dart';
import '../database/transaction_dao.dart';
import '../models/transaction_model.dart';
import 'account_service.dart';

/// Owns the transaction ledger. Every insert/update/delete keeps the
/// related account balances in sync via [AccountService.adjustBalance].
class TransactionService extends ChangeNotifier {
  final TransactionDao _dao;
  final AccountService _accountService;
  final _uuid = const Uuid();

  TransactionService({
    required AccountService accountService,
    TransactionDao? dao,
  })  : _accountService = accountService,
        _dao = dao ?? createTransactionDao();

  List<MoneyTransaction> _transactions = [];
  bool _isLoading = true;
  String? _error;

  List<MoneyTransaction> get transactions => List.unmodifiable(_transactions);
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<MoneyTransaction> get recent => _transactions.take(5).toList();

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _transactions = await _dao.getAll();
    } catch (e) {
      _error = 'Could not load transactions.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _applyBalanceEffect(MoneyTransaction t, {required int sign}) async {
    switch (t.type) {
      case TransactionType.income:
        await _accountService.adjustBalance(t.accountId, sign * t.amount);
        break;
      case TransactionType.expense:
        await _accountService.adjustBalance(t.accountId, -sign * t.amount);
        break;
      case TransactionType.transfer:
        await _accountService.adjustBalance(t.accountId, -sign * t.amount);
        if (t.toAccountId != null) {
          await _accountService.adjustBalance(t.toAccountId!, sign * t.amount);
        }
        break;
    }
  }

  Future<MoneyTransaction> addTransaction({
    required TransactionType type,
    required double amount,
    required String category,
    required String accountId,
    String? toAccountId,
    required DateTime date,
    String? description,
    String? notes,
  }) async {
    final transaction = MoneyTransaction(
      id: _uuid.v4(),
      type: type,
      amount: amount,
      category: category,
      accountId: accountId,
      toAccountId: type == TransactionType.transfer ? toAccountId : null,
      date: date,
      description: (description?.trim().isEmpty ?? true) ? null : description!.trim(),
      notes: (notes?.trim().isEmpty ?? true) ? null : notes!.trim(),
      createdAt: DateTime.now(),
    );

    await _dao.insert(transaction);
    await _applyBalanceEffect(transaction, sign: 1);

    _transactions = [transaction, ..._transactions]
      ..sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
    return transaction;
  }

  Future<void> updateTransaction(
    String id, {
    required TransactionType type,
    required double amount,
    required String category,
    required String accountId,
    String? toAccountId,
    required DateTime date,
    String? description,
    String? notes,
  }) async {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index == -1) return;
    final old = _transactions[index];

    // Reverse the old effect, then apply the new one.
    await _applyBalanceEffect(old, sign: -1);

    final updated = old.copyWith(
      type: type,
      amount: amount,
      category: category,
      accountId: accountId,
      toAccountId: type == TransactionType.transfer ? toAccountId : null,
      date: date,
      description: (description?.trim().isEmpty ?? true) ? null : description!.trim(),
      notes: (notes?.trim().isEmpty ?? true) ? null : notes!.trim(),
    );

    await _applyBalanceEffect(updated, sign: 1);
    await _dao.update(updated);

    _transactions = [..._transactions]
      ..[index] = updated
      ..sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index == -1) return;
    final old = _transactions[index];

    await _applyBalanceEffect(old, sign: -1);
    await _dao.delete(id);

    _transactions = _transactions.where((t) => t.id != id).toList();
    notifyListeners();
  }

  List<MoneyTransaction> filtered({
    String? query,
    String? category,
    TransactionType? type,
    String? accountId,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _transactions.where((t) {
      if (query != null && query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        final matchesDescription = (t.description ?? '').toLowerCase().contains(q);
        final matchesCategory = t.category.toLowerCase().contains(q);
        final matchesNotes = (t.notes ?? '').toLowerCase().contains(q);
        if (!matchesDescription && !matchesCategory && !matchesNotes) return false;
      }
      if (category != null && category.isNotEmpty && t.category != category) return false;
      if (type != null && t.type != type) return false;
      if (accountId != null &&
          accountId.isNotEmpty &&
          t.accountId != accountId &&
          t.toAccountId != accountId) {
        return false;
      }
      if (startDate != null && t.date.isBefore(startDate)) return false;
      if (endDate != null && t.date.isAfter(endDate)) return false;
      return true;
    }).toList();
  }
}
