import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/transaction_model.dart';
import '../../services/account_service.dart';
import '../../services/transaction_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/formatters.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/theme_toggle_button.dart';
import '../../widgets/transaction_tile.dart';
import 'add_transaction_sheet.dart';
import 'transaction_filter_sheet.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  TransactionType? _typeFilter;
  TransactionFilters _filters = const TransactionFilters();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final txService = context.watch<TransactionService>();
    final accountService = context.watch<AccountService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            onPressed: () async {
              final result = await showTransactionFilterSheet(context, _filters);
              if (result != null) setState(() => _filters = result);
            },
            icon: Badge(
              isLabelVisible: _filters.isActive,
              smallSize: 8,
              backgroundColor: AppColors.bloomPink,
              child: const Icon(Icons.tune_rounded),
            ),
            tooltip: 'Filter',
          ),
          const ThemeToggleButton(),
        ],
      ),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (txService.isLoading) return const LoadingView();
            if (txService.error != null) {
              return ErrorView(message: txService.error!, onRetry: txService.load);
            }

            final results = txService.filtered(
              query: _query,
              category: _filters.category,
              type: _typeFilter,
              startDate: _filters.dateRange?.start,
              endDate: _filters.dateRange?.end,
            );

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                    decoration: InputDecoration(
                      hintText: 'Search transactions',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _query = '');
                              },
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    children: [
                      _TypeChip(label: 'All', selected: _typeFilter == null, onTap: () => setState(() => _typeFilter = null)),
                      const SizedBox(width: AppSpacing.sm),
                      _TypeChip(
                        label: 'Income',
                        selected: _typeFilter == TransactionType.income,
                        onTap: () => setState(() => _typeFilter = TransactionType.income),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _TypeChip(
                        label: 'Expense',
                        selected: _typeFilter == TransactionType.expense,
                        onTap: () => setState(() => _typeFilter = TransactionType.expense),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _TypeChip(
                        label: 'Transfer',
                        selected: _typeFilter == TransactionType.transfer,
                        onTap: () => setState(() => _typeFilter = TransactionType.transfer),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Expanded(
                  child: results.isEmpty
                      ? SingleChildScrollView(
                          child: EmptyState(
                            icon: Icons.receipt_long_outlined,
                            title: txService.transactions.isEmpty ? 'No transactions yet' : 'No matches found',
                            message: txService.transactions.isEmpty
                                ? 'Add your first income or expense to start tracking.'
                                : 'Try adjusting your search or filters.',
                            actionLabel: txService.transactions.isEmpty ? 'Add Transaction' : null,
                            onAction: txService.transactions.isEmpty
                                ? () => showAddTransactionSheet(context)
                                : null,
                          ),
                        )
                      : _GroupedTransactionList(
                          transactions: results,
                          accountService: accountService,
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TypeChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

class _GroupedTransactionList extends StatelessWidget {
  final List<MoneyTransaction> transactions;
  final AccountService accountService;

  const _GroupedTransactionList({required this.transactions, required this.accountService});

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<MoneyTransaction>>{};
    for (final t in transactions) {
      final key = Formatters.shortDate(t.date);
      groups.putIfAbsent(key, () => []).add(t);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, 100),
      children: groups.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.xs),
              child: Text(
                entry.key,
                style: AppTextStyles.caption.copyWith(color: AppColors.mutedGray, fontWeight: FontWeight.w700),
              ),
            ),
            ...entry.value.map((t) => _TransactionRow(transaction: t, accountService: accountService)),
          ],
        );
      }).toList(),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final MoneyTransaction transaction;
  final AccountService accountService;

  const _TransactionRow({required this.transaction, required this.accountService});

  @override
  Widget build(BuildContext context) {
    final accountName = accountService.byId(transaction.accountId)?.name ?? 'Unknown';
    final toAccountName = transaction.toAccountId != null
        ? accountService.byId(transaction.toAccountId!)?.name
        : null;

    return Dismissible(
      key: ValueKey(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.expenseRed.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.expenseRed),
      ),
      confirmDismiss: (_) => showConfirmDialog(
        context,
        title: 'Delete transaction?',
        message: 'This will remove the transaction and reverse its effect on your account balance.',
      ),
      onDismissed: (_) async {
        await context.read<TransactionService>().deleteTransaction(transaction.id);
        if (context.mounted) AppSnackbar.success(context, 'Transaction deleted.');
      },
      child: TransactionTile(
        transaction: transaction,
        accountName: accountName,
        toAccountName: toAccountName,
        onTap: () => showAddTransactionSheet(context, transaction: transaction),
      ),
    );
  }
}
