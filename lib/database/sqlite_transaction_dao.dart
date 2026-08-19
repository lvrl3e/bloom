import '../models/transaction_model.dart';
import 'database_helper.dart';
import 'transaction_dao.dart';

class SqliteTransactionDao implements TransactionDao {
  final DatabaseHelper _helper = DatabaseHelper.instance;

  @override
  Future<List<MoneyTransaction>> getAll() async {
    final db = await _helper.database;
    final rows = await db.query('transactions', orderBy: 'date DESC, created_at DESC');
    return rows.map(MoneyTransaction.fromMap).toList();
  }

  @override
  Future<List<MoneyTransaction>> getByAccount(String accountId) async {
    final db = await _helper.database;
    final rows = await db.query(
      'transactions',
      where: 'account_id = ? OR to_account_id = ?',
      whereArgs: [accountId, accountId],
      orderBy: 'date DESC, created_at DESC',
    );
    return rows.map(MoneyTransaction.fromMap).toList();
  }

  @override
  Future<MoneyTransaction?> getById(String id) async {
    final db = await _helper.database;
    final rows = await db.query('transactions', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return MoneyTransaction.fromMap(rows.first);
  }

  @override
  Future<void> insert(MoneyTransaction transaction) async {
    final db = await _helper.database;
    await db.insert('transactions', transaction.toMap());
  }

  @override
  Future<void> update(MoneyTransaction transaction) async {
    final db = await _helper.database;
    await db.update('transactions', transaction.toMap(), where: 'id = ?', whereArgs: [transaction.id]);
  }

  @override
  Future<void> delete(String id) async {
    final db = await _helper.database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }
}
