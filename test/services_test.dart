// Integration-style tests for the service layer against a real (FFI-backed)
// SQLite database, covering the balance math that the UI depends on:
// income/expense/transfer effects, edits reversing old effects, deletes
// reversing effects, and goal contribution + status computation.

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloom/database/database_helper.dart';
import 'package:bloom/models/account_model.dart';
import 'package:bloom/models/goal_model.dart';
import 'package:bloom/models/transaction_model.dart';
import 'package:bloom/services/account_service.dart';
import 'package:bloom/services/goal_service.dart';
import 'package:bloom/services/transaction_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // path_provider has no real platform channel under `flutter test`; stub it
  // to a temp directory so DatabaseHelper can open a real sqlite file.
  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    pathProviderChannel,
    (MethodCall methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        final dir = Directory.systemTemp.createTempSync('bloom_test');
        return dir.path;
      }
      return null;
    },
  );

  late AccountService accountService;
  late TransactionService transactionService;
  late GoalService goalService;

  setUp(() async {
    await DatabaseHelper.instance.clearAllData();
    accountService = AccountService();
    await accountService.load();
    transactionService = TransactionService(accountService: accountService);
    await transactionService.load();
    goalService = GoalService();
    await goalService.load();
  });

  test('adding an income transaction increases the account balance', () async {
    final account = await accountService.addAccount(
      name: 'GCash',
      type: AccountType.eWallet,
      balance: 1000,
    );

    await transactionService.addTransaction(
      type: TransactionType.income,
      amount: 500,
      category: 'Salary',
      accountId: account.id,
      date: DateTime.now(),
    );

    expect(accountService.byId(account.id)!.balance, 1500);
  });

  test('adding an expense transaction decreases the account balance', () async {
    final account = await accountService.addAccount(
      name: 'BPI',
      type: AccountType.bank,
      balance: 8450,
    );

    await transactionService.addTransaction(
      type: TransactionType.expense,
      amount: 500,
      category: 'Food & Dining',
      accountId: account.id,
      date: DateTime.now(),
    );

    expect(accountService.byId(account.id)!.balance, 7950);
  });

  test('a transfer moves money between two accounts', () async {
    final from = await accountService.addAccount(name: 'BDO', type: AccountType.bank, balance: 5000);
    final to = await accountService.addAccount(name: 'Cash', type: AccountType.cash, balance: 0);

    await transactionService.addTransaction(
      type: TransactionType.transfer,
      amount: 2000,
      category: 'Transfer',
      accountId: from.id,
      toAccountId: to.id,
      date: DateTime.now(),
    );

    expect(accountService.byId(from.id)!.balance, 3000);
    expect(accountService.byId(to.id)!.balance, 2000);
  });

  test('editing a transaction reverses the old effect before applying the new one', () async {
    final account = await accountService.addAccount(name: 'Maya', type: AccountType.eWallet, balance: 1000);

    final tx = await transactionService.addTransaction(
      type: TransactionType.expense,
      amount: 200,
      category: 'Shopping',
      accountId: account.id,
      date: DateTime.now(),
    );
    expect(accountService.byId(account.id)!.balance, 800);

    await transactionService.updateTransaction(
      tx.id,
      type: TransactionType.expense,
      amount: 350,
      category: 'Shopping',
      accountId: account.id,
      date: DateTime.now(),
    );

    expect(accountService.byId(account.id)!.balance, 650);
  });

  test('deleting a transaction reverses its effect on the balance', () async {
    final account = await accountService.addAccount(name: 'UnionBank', type: AccountType.bank, balance: 1000);

    final tx = await transactionService.addTransaction(
      type: TransactionType.income,
      amount: 300,
      category: 'Freelance',
      accountId: account.id,
      date: DateTime.now(),
    );
    expect(accountService.byId(account.id)!.balance, 1300);

    await transactionService.deleteTransaction(tx.id);
    expect(accountService.byId(account.id)!.balance, 1000);
  });

  test('a goal contribution increases currentAmount and completing it flips status', () async {
    final goal = await goalService.addGoal(
      name: 'Emergency Fund',
      targetAmount: 1000,
      currentAmount: 0,
      targetDate: DateTime.now().add(const Duration(days: 180)),
      category: 'Emergency Fund',
      priority: GoalPriority.high,
      monthlyContribution: 200,
    );
    expect(goal.status, isNot(GoalStatus.completed));

    await goalService.addContribution(goalId: goal.id, amount: 400, date: DateTime.now());
    var updated = goalService.goals.firstWhere((g) => g.id == goal.id);
    expect(updated.currentAmount, 400);
    expect(updated.status, isNot(GoalStatus.completed));

    await goalService.addContribution(goalId: goal.id, amount: 600, date: DateTime.now());
    updated = goalService.goals.firstWhere((g) => g.id == goal.id);
    expect(updated.currentAmount, 1000);
    expect(updated.status, GoalStatus.completed);
  });
}
