import '../models/account_model.dart';

/// Storage contract for accounts. [createAccountDao] picks the real
/// implementation: SQLite on native platforms, in-memory on web (see
/// `dao_factory.dart`).
abstract class AccountDao {
  Future<List<Account>> getAll();
  Future<Account?> getById(String id);
  Future<void> insert(Account account);
  Future<void> update(Account account);
  Future<void> updateBalance(String id, double newBalance, DateTime updatedAt);
  Future<void> delete(String id);
}
