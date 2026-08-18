import '../models/goal_model.dart';
import 'database_helper.dart';

class GoalDao {
  final DatabaseHelper _helper = DatabaseHelper.instance;

  Future<List<Goal>> getAll() async {
    final db = await _helper.database;
    final rows = await db.query('goals', orderBy: 'created_at ASC');
    return rows.map(Goal.fromMap).toList();
  }

  Future<Goal?> getById(String id) async {
    final db = await _helper.database;
    final rows = await db.query('goals', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Goal.fromMap(rows.first);
  }

  Future<void> insert(Goal goal) async {
    final db = await _helper.database;
    await db.insert('goals', goal.toMap());
  }

  Future<void> update(Goal goal) async {
    final db = await _helper.database;
    await db.update('goals', goal.toMap(), where: 'id = ?', whereArgs: [goal.id]);
  }

  Future<void> delete(String id) async {
    final db = await _helper.database;
    await db.delete('goals', where: 'id = ?', whereArgs: [id]);
  }
}

class GoalContributionDao {
  final DatabaseHelper _helper = DatabaseHelper.instance;

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

  Future<void> insert(GoalContribution contribution) async {
    final db = await _helper.database;
    await db.insert('goal_contributions', contribution.toMap());
  }

  Future<void> delete(String id) async {
    final db = await _helper.database;
    await db.delete('goal_contributions', where: 'id = ?', whereArgs: [id]);
  }
}
