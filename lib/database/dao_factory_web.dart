import 'account_dao.dart';
import 'goal_dao.dart';
import 'memory_account_dao.dart';
import 'memory_goal_dao.dart';
import 'memory_transaction_dao.dart';
import 'transaction_dao.dart';

AccountDao createAccountDao() => InMemoryAccountDao();
TransactionDao createTransactionDao() => InMemoryTransactionDao();
GoalDao createGoalDao() => InMemoryGoalDao();
GoalContributionDao createGoalContributionDao() => InMemoryGoalContributionDao();
