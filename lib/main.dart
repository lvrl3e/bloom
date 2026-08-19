import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/account_service.dart';
import 'services/goal_service.dart';
import 'services/theme_service.dart';
import 'services/transaction_service.dart';
import 'theme/app_theme.dart';
import 'widgets/loading_screen.dart';
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
        ChangeNotifierProvider<ThemeService>(create: (_) => ThemeService()),
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
      child: const _BloomMaterialApp(),
    );
  }
}

class _BloomMaterialApp extends StatelessWidget {
  const _BloomMaterialApp();

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeService>().mode;
    return MaterialApp(
      title: 'BLOOM',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const _AppRoot(),
    );
  }
}

/// Shows [LoadingScreen] until the initial account/transaction/goal load
/// completes, then latches to [RootShell] for good — later reloads (e.g.
/// pull-to-refresh) toggle each service's `isLoading` again, but that must
/// not send the user back to a full-screen splash mid-session.
class _AppRoot extends StatefulWidget {
  const _AppRoot();

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  bool _ready = false;

  @override
  Widget build(BuildContext context) {
    final accountService = context.watch<AccountService>();
    final txService = context.watch<TransactionService>();
    final goalService = context.watch<GoalService>();

    if (!_ready &&
        !accountService.isLoading &&
        !txService.isLoading &&
        !goalService.isLoading) {
      _ready = true;
    }

    return _ready ? const RootShell() : const LoadingScreen();
  }
}
