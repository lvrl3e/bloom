import '../models/transaction_model.dart';

/// Storage contract for transactions. [createTransactionDao] picks the real
/// implementation: SQLite on native platforms, in-memory on web (see
/// `dao_factory.dart`).
abstract class TransactionDao {
  Future<List<MoneyTransaction>> getAll();
  Future<List<MoneyTransaction>> getByAccount(String accountId);
  Future<MoneyTransaction?> getById(String id);
  Future<void> insert(MoneyTransaction transaction);
  Future<void> update(MoneyTransaction transaction);
  Future<void> delete(String id);
}
