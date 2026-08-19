import '../models/goal_model.dart';

/// Storage contract for goals. [createGoalDao] picks the real implementation:
/// SQLite on native platforms, in-memory on web (see `dao_factory.dart`).
abstract class GoalDao {
  Future<List<Goal>> getAll();
  Future<Goal?> getById(String id);
  Future<void> insert(Goal goal);
  Future<void> update(Goal goal);
  Future<void> delete(String id);
}

/// Storage contract for goal contributions. [createGoalContributionDao]
/// picks the real implementation: SQLite on native platforms, in-memory on
/// web (see `dao_factory.dart`).
abstract class GoalContributionDao {
  Future<List<GoalContribution>> getByGoal(String goalId);
  Future<void> insert(GoalContribution contribution);
  Future<void> delete(String id);
}
