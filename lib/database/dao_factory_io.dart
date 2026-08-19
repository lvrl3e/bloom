import 'account_dao.dart';
import 'goal_dao.dart';
import 'sqlite_account_dao.dart';
import 'sqlite_goal_dao.dart';
import 'sqlite_transaction_dao.dart';
import 'transaction_dao.dart';

AccountDao createAccountDao() => SqliteAccountDao();
TransactionDao createTransactionDao() => SqliteTransactionDao();
GoalDao createGoalDao() => SqliteGoalDao();
GoalContributionDao createGoalContributionDao() => SqliteGoalContributionDao();
