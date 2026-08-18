import '../models/account_model.dart';
import 'database_helper.dart';

class AccountDao {
  final DatabaseHelper _helper = DatabaseHelper.instance;

  Future<List<Account>> getAll() async {
    final db = await _helper.database;
    final rows = await db.query('accounts', orderBy: 'created_at ASC');
    return rows.map(Account.fromMap).toList();
  }

  Future<Account?> getById(String id) async {
    final db = await _helper.database;
    final rows = await db.query('accounts', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Account.fromMap(rows.first);
  }

  Future<void> insert(Account account) async {
    final db = await _helper.database;
    await db.insert('accounts', account.toMap());
  }

  Future<void> update(Account account) async {
    final db = await _helper.database;
    await db.update('accounts', account.toMap(), where: 'id = ?', whereArgs: [account.id]);
  }

  Future<void> updateBalance(String id, double newBalance, DateTime updatedAt) async {
    final db = await _helper.database;
    await db.update(
      'accounts',
      {'balance': newBalance, 'updated_at': updatedAt.toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> delete(String id) async {
    final db = await _helper.database;
    await db.delete('accounts', where: 'id = ?', whereArgs: [id]);
  }
}
