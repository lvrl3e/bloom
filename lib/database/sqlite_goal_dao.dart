import '../models/goal_model.dart';
import 'database_helper.dart';
import 'goal_dao.dart';

class SqliteGoalDao implements GoalDao {
  final DatabaseHelper _helper = DatabaseHelper.instance;

  @override
  Future<List<Goal>> getAll() async {
    final db = await _helper.database;
    final rows = await db.query('goals', orderBy: 'created_at ASC');
    return rows.map(Goal.fromMap).toList();
  }

  @override
  Future<Goal?> getById(String id) async {
    final db = await _helper.database;
    final rows = await db.query('goals', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Goal.fromMap(rows.first);
  }

  @override
  Future<void> insert(Goal goal) async {
    final db = await _helper.database;
    await db.insert('goals', goal.toMap());
  }

  @override
  Future<void> update(Goal goal) async {
    final db = await _helper.database;
    await db.update('goals', goal.toMap(), where: 'id = ?', whereArgs: [goal.id]);
  }

  @override
  Future<void> delete(String id) async {
    final db = await _helper.database;
    await db.delete('goals', where: 'id = ?', whereArgs: [id]);
  }
}

class SqliteGoalContributionDao implements GoalContributionDao {
  final DatabaseHelper _helper = DatabaseHelper.instance;

  @override
  Future<List<GoalContribution>> getByGoal(String goalId) async {
    final db = await _helper.database;
    final rows = await db.query(
      'goal_contributions',
      where: 'goal_id = ?',
      whereArgs: [goalId],
      orderBy: 'date DESC, created_at DESC',
    );
    return rows.map(GoalContribution.fromMap).toList();
  }

  @override
  Future<void> insert(GoalContribution contribution) async {
    final db = await _helper.database;
    await db.insert('goal_contributions', contribution.toMap());
  }

  @override
  Future<void> delete(String id) async {
    final db = await _helper.database;
    await db.delete('goal_contributions', where: 'id = ?', whereArgs: [id]);
  }
}
