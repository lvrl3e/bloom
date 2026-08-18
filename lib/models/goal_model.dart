import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum GoalPriority { low, medium, high }

extension GoalPriorityX on GoalPriority {
  String get label {
    switch (this) {
      case GoalPriority.low:
        return 'Low';
      case GoalPriority.medium:
        return 'Medium';
      case GoalPriority.high:
        return 'High';
    }
  }

  static GoalPriority fromKey(String key) {
    return GoalPriority.values.firstWhere(
      (e) => e.name == key,
      orElse: () => GoalPriority.medium,
    );
  }
}

enum GoalStatus { onTrack, behind, atRisk, completed }

extension GoalStatusX on GoalStatus {
  String get label {
    switch (this) {
      case GoalStatus.onTrack:
        return 'On Track';
      case GoalStatus.behind:
        return 'Behind';
      case GoalStatus.atRisk:
        return 'At Risk';
      case GoalStatus.completed:
        return 'Completed';
    }
  }

  String get emoji {
    switch (this) {
      case GoalStatus.onTrack:
        return '🟢';
      case GoalStatus.behind:
        return '🟡';
      case GoalStatus.atRisk:
        return '🔴';
      case GoalStatus.completed:
        return '✅';
    }
  }

  Color get color {
    switch (this) {
      case GoalStatus.onTrack:
        return AppColors.successGreen;
      case GoalStatus.behind:
        return const Color(0xFFF59E0B);
      case GoalStatus.atRisk:
        return AppColors.expenseRed;
      case GoalStatus.completed:
        return AppColors.bloomPink;
    }
  }
}

class GoalCategoryPreset {
  final String name;
  final IconData icon;

  const GoalCategoryPreset(this.name, this.icon);

  static const List<GoalCategoryPreset> all = [
    GoalCategoryPreset('Emergency Fund', Icons.shield_rounded),
    GoalCategoryPreset('Travel', Icons.flight_takeoff_rounded),
    GoalCategoryPreset('Gadget', Icons.devices_rounded),
    GoalCategoryPreset('Education', Icons.school_rounded),
    GoalCategoryPreset('Vehicle', Icons.directions_car_filled_rounded),
    GoalCategoryPreset('Home', Icons.home_rounded),
    GoalCategoryPreset('Wedding', Icons.favorite_rounded),
    GoalCategoryPreset('Retirement', Icons.beach_access_rounded),
    GoalCategoryPreset('Debt Payoff', Icons.credit_score_rounded),
    GoalCategoryPreset('Other', Icons.local_florist_rounded),
  ];

  static IconData iconFor(String name) {
    return all
        .firstWhere((c) => c.name == name, orElse: () => all.last)
        .icon;
  }
}

class Goal {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final String category;
  final GoalPriority priority;
  final double monthlyContribution;
  final String? notes;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Goal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
    required this.category,
    required this.priority,
    required this.monthlyContribution,
    this.notes,
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  double get percentComplete =>
      targetAmount <= 0 ? 0 : (currentAmount / targetAmount).clamp(0, 1);

  double get remainingAmount =>
      (targetAmount - currentAmount) < 0 ? 0 : (targetAmount - currentAmount);

  int get monthsRemaining {
    final now = DateTime.now();
    if (targetDate.isBefore(now)) return 0;
    final months = (targetDate.year - now.year) * 12 +
        (targetDate.month - now.month) -
        (now.day > targetDate.day ? 1 : 0);
    return months < 0 ? 0 : months;
  }

  double get requiredMonthlySavings {
    final months = monthsRemaining;
    if (months <= 0) return remainingAmount;
    return remainingAmount / months;
  }

  GoalStatus get status {
    if (isCompleted || currentAmount >= targetAmount) return GoalStatus.completed;

    final now = DateTime.now();
    if (now.isAfter(targetDate)) return GoalStatus.atRisk;

    final totalSpan = targetDate.difference(createdAt).inDays;
    final elapsed = now.difference(createdAt).inDays;
    final elapsedFraction =
        totalSpan <= 0 ? 1.0 : (elapsed / totalSpan).clamp(0.0, 1.0);

    final actualProgress = percentComplete;
    final delta = actualProgress - elapsedFraction;

    if (delta >= -0.05) return GoalStatus.onTrack;
    if (delta >= -0.20) return GoalStatus.behind;
    return GoalStatus.atRisk;
  }

  Goal copyWith({
    String? name,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    String? category,
    GoalPriority? priority,
    double? monthlyContribution,
    String? notes,
    bool? isCompleted,
    DateTime? updatedAt,
  }) {
    return Goal(
      id: id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      monthlyContribution: monthlyContribution ?? this.monthlyContribution,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'target_date': targetDate.toIso8601String(),
      'category': category,
      'priority': priority.name,
      'monthly_contribution': monthlyContribution,
      'notes': notes,
      'is_completed': isCompleted ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'] as String,
      name: map['name'] as String,
      targetAmount: (map['target_amount'] as num).toDouble(),
      currentAmount: (map['current_amount'] as num).toDouble(),
      targetDate: DateTime.parse(map['target_date'] as String),
      category: map['category'] as String,
      priority: GoalPriorityX.fromKey(map['priority'] as String),
      monthlyContribution: (map['monthly_contribution'] as num).toDouble(),
      notes: map['notes'] as String?,
      isCompleted: (map['is_completed'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}

class GoalContribution {
  final String id;
  final String goalId;
  final double amount;
  final DateTime date;
  final String? note;
  final DateTime createdAt;

  const GoalContribution({
    required this.id,
    required this.goalId,
    required this.amount,
    required this.date,
    this.note,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'goal_id': goalId,
      'amount': amount,
      'date': date.toIso8601String(),
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory GoalContribution.fromMap(Map<String, dynamic> map) {
    return GoalContribution(
      id: map['id'] as String,
      goalId: map['goal_id'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
