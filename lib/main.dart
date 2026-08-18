import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/account_service.dart';
import 'services/goal_service.dart';
import 'services/transaction_service.dart';
import 'theme/app_theme.dart';
import 'widgets/root_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BloomApp());
}

class BloomApp extends StatelessWidget {
  const BloomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AccountService>(
          create: (_) => AccountService()..load(),
        ),
        ChangeNotifierProxyProvider<AccountService, TransactionService>(
          create: (context) => TransactionService(
            accountService: context.read<AccountService>(),
          )..load(),
          update: (context, accountService, previous) =>
              previous ?? TransactionService(accountService: accountService)..load(),
        ),
        ChangeNotifierProvider<GoalService>(
          create: (_) => GoalService()..load(),
        ),
      ],
      child: MaterialApp(
        title: 'BLOOM',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: const RootShell(),
      ),
    );
  }
}
