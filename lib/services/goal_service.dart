import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../database/goal_dao.dart';
import '../models/goal_model.dart';

/// Owns financial goals and their contribution history.
class GoalService extends ChangeNotifier {
  final GoalDao _dao;
  final GoalContributionDao _contributionDao;
  final _uuid = const Uuid();

  GoalService({GoalDao? dao, GoalContributionDao? contributionDao})
      : _dao = dao ?? GoalDao(),
        _contributionDao = contributionDao ?? GoalContributionDao();

  List<Goal> _goals = [];
  bool _isLoading = true;
  String? _error;

  List<Goal> get goals => List.unmodifiable(_goals);
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalSaved => _goals.fold(0.0, (sum, g) => sum + g.currentAmount);
  double get totalTarget => _goals.fold(0.0, (sum, g) => sum + g.targetAmount);
  List<Goal> get activeGoals => _goals.where((g) => g.status != GoalStatus.completed).toList();
  List<Goal> get completedGoals => _goals.where((g) => g.status == GoalStatus.completed).toList();

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _goals = await _dao.getAll();
    } catch (e) {
      _error = 'Could not load goals.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Goal> addGoal({
    required String name,
    required double targetAmount,
    double currentAmount = 0,
    required DateTime targetDate,
    required String category,
    required GoalPriority priority,
    double monthlyContribution = 0,
    String? notes,
  }) async {
    final now = DateTime.now();
    final goal = Goal(
      id: _uuid.v4(),
      name: name.trim(),
      targetAmount: targetAmount,
      currentAmount: currentAmount,
      targetDate: targetDate,
      category: category,
      priority: priority,
      monthlyContribution: monthlyContribution,
      notes: (notes?.trim().isEmpty ?? true) ? null : notes!.trim(),
      isCompleted: currentAmount >= targetAmount,
      createdAt: now,
      updatedAt: now,
    );
    await _dao.insert(goal);
    _goals = [..._goals, goal];
    notifyListeners();
    return goal;
  }

  Future<void> updateGoal(
    String id, {
    required String name,
    required double targetAmount,
    required DateTime targetDate,
    required String category,
    required GoalPriority priority,
    required double monthlyContribution,
    String? notes,
  }) async {
    final index = _goals.indexWhere((g) => g.id == id);
    if (index == -1) return;
    final current = _goals[index];
    final updated = current.copyWith(
      name: name.trim(),
      targetAmount: targetAmount,
      targetDate: targetDate,
      category: category,
      priority: priority,
      monthlyContribution: monthlyContribution,
      notes: (notes?.trim().isEmpty ?? true) ? null : notes!.trim(),
      isCompleted: current.currentAmount >= targetAmount,
      updatedAt: DateTime.now(),
    );
    await _dao.update(updated);
    _goals = [..._goals]..[index] = updated;
    notifyListeners();
  }

  Future<void> deleteGoal(String id) async {
    await _dao.delete(id);
    _goals = _goals.where((g) => g.id != id).toList();
    notifyListeners();
  }

  Future<List<GoalContribution>> contributionsFor(String goalId) {
    return _contributionDao.getByGoal(goalId);
  }

  Future<void> addContribution({
    required String goalId,
    required double amount,
    required DateTime date,
    String? note,
  }) async {
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index == -1) return;
    final goal = _goals[index];

    final contribution = GoalContribution(
      id: _uuid.v4(),
      goalId: goalId,
      amount: amount,
      date: date,
      note: (note?.trim().isEmpty ?? true) ? null : note!.trim(),
      createdAt: DateTime.now(),
    );
    await _contributionDao.insert(contribution);

    final newAmount = goal.currentAmount + amount;
    final updated = goal.copyWith(
      currentAmount: newAmount,
      isCompleted: newAmount >= goal.targetAmount,
      updatedAt: DateTime.now(),
    );
    await _dao.update(updated);
    _goals = [..._goals]..[index] = updated;
    notifyListeners();
  }
}
