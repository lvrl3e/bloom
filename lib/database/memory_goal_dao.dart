import '../models/goal_model.dart';
import 'goal_dao.dart';

/// Pure in-memory implementation used on web builds — nothing survives a
/// page refresh, by design (see `dao_factory_web.dart`).
class InMemoryGoalDao implements GoalDao {
  final List<Goal> _goals = [];

  @override
  Future<List<Goal>> getAll() async {
    final sorted = [..._goals]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return sorted;
  }

  @override
  Future<Goal?> getById(String id) async {
    for (final g in _goals) {
      if (g.id == id) return g;
    }
    return null;
  }

  @override
  Future<void> insert(Goal goal) async {
    _goals.add(goal);
  }

  @override
  Future<void> update(Goal goal) async {
    final index = _goals.indexWhere((g) => g.id == goal.id);
    if (index == -1) return;
    _goals[index] = goal;
  }

  @override
  Future<void> delete(String id) async {
    _goals.removeWhere((g) => g.id == id);
  }
}

/// Pure in-memory implementation used on web builds — nothing survives a
/// page refresh, by design (see `dao_factory_web.dart`).
class InMemoryGoalContributionDao implements GoalContributionDao {
  final List<GoalContribution> _contributions = [];

  @override
  Future<List<GoalContribution>> getByGoal(String goalId) async {
    final filtered = _contributions.where((c) => c.goalId == goalId).toList();
    filtered.sort((a, b) {
      final byDate = b.date.compareTo(a.date);
      if (byDate != 0) return byDate;
      return b.createdAt.compareTo(a.createdAt);
    });
    return filtered;
  }

  @override
  Future<void> insert(GoalContribution contribution) async {
    _contributions.add(contribution);
  }

  @override
  Future<void> delete(String id) async {
    _contributions.removeWhere((c) => c.id == id);
  }
}
