import '../models/account_model.dart';
import 'account_dao.dart';
import 'database_helper.dart';

class SqliteAccountDao implements AccountDao {
  final DatabaseHelper _helper = DatabaseHelper.instance;

  @override
  Future<List<Account>> getAll() async {
    final db = await _helper.database;
    final rows = await db.query('accounts', orderBy: 'created_at ASC');
    return rows.map(Account.fromMap).toList();
  }

  @override
  Future<Account?> getById(String id) async {
    final db = await _helper.database;
    final rows = await db.query('accounts', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Account.fromMap(rows.first);
  }

  @override
  Future<void> insert(Account account) async {
    final db = await _helper.database;
    await db.insert('accounts', account.toMap());
  }

  @override
  Future<void> update(Account account) async {
    final db = await _helper.database;
    await db.update('accounts', account.toMap(), where: 'id = ?', whereArgs: [account.id]);
  }

  @override
  Future<void> updateBalance(String id, double newBalance, DateTime updatedAt) async {
    final db = await _helper.database;
    await db.update(
      'accounts',
      {'balance': newBalance, 'updated_at': updatedAt.toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> delete(String id) async {
    final db = await _helper.database;
    await db.delete('accounts', where: 'id = ?', whereArgs: [id]);
  }
}
