import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/account_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/formatters.dart';
import '../../widgets/account_card.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_view.dart';
import 'add_account_sheet.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<AccountService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts'),
        actions: [
          IconButton(
            onPressed: () => showAddAccountSheet(context),
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add account',
          ),
        ],
      ),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (service.isLoading) return const LoadingView();
            if (service.error != null) {
              return ErrorView(message: service.error!, onRetry: service.load);
            }
            if (service.accounts.isEmpty) {
              return SingleChildScrollView(
                child: EmptyState(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'No accounts yet',
                  message: 'Add your banks, e-wallets, or cash to start tracking your money.',
                  actionLabel: 'Add Account',
                  onAction: () => showAddAccountSheet(context),
                ),
              );
            }

            return RefreshIndicator(
              color: AppColors.bloomPink,
              onRefresh: service.load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 100),
                children: [
                  _TotalBalanceBanner(total: service.totalBalance, accountCount: service.accounts.length),
                  const SizedBox(height: AppSpacing.xl),
                  ...service.accounts.map(
                    (account) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: AccountCard(
                        account: account,
                        onEdit: () => showAddAccountSheet(context, account: account),
                        onDelete: () async {
                          final confirmed = await showConfirmDialog(
                            context,
                            title: 'Delete ${account.name}?',
                            message:
                                'This will permanently delete this account and all of its transactions. This cannot be undone.',
                          );
                          if (confirmed) {
                            await service.deleteAccount(account.id);
                            if (context.mounted) {
                              AppSnackbar.success(context, 'Account deleted.');
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TotalBalanceBanner extends StatelessWidget {
  final double total;
  final int accountCount;

  const _TotalBalanceBanner({required this.total, required this.accountCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.bloomPink,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOTAL BALANCE',
            style: AppTextStyles.overline.copyWith(color: Colors.white.withValues(alpha: 0.85)),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            Formatters.currency(total),
            style: AppTextStyles.numericLarge.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            'Across $accountCount account${accountCount == 1 ? '' : 's'}',
            style: AppTextStyles.caption.copyWith(color: Colors.white.withValues(alpha: 0.85)),
          ),
        ],
      ),
    );
  }
}
