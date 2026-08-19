import 'account_dao.dart';
import 'goal_dao.dart';
import 'transaction_dao.dart';

import 'dao_factory_web.dart' if (dart.library.io) 'dao_factory_io.dart' as impl;

/// Picks the storage implementation for the current platform: SQLite
/// (native, persistent) everywhere `dart:io` is available, in-memory
/// (web, resets every session) otherwise. `dart.library.io` is never
/// available in a browser, which is what makes this switch reliable.
AccountDao createAccountDao() => impl.createAccountDao();
TransactionDao createTransactionDao() => impl.createTransactionDao();
GoalDao createGoalDao() => impl.createGoalDao();
GoalContributionDao createGoalContributionDao() => impl.createGoalContributionDao();
