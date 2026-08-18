import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/category_model.dart';
import '../../models/transaction_model.dart';
import '../../services/account_service.dart';
import '../../services/transaction_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/icon_avatar.dart';
import '../accounts/add_account_sheet.dart';

Future<void> showAddTransactionSheet(
  BuildContext context, {
  MoneyTransaction? transaction,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => AddTransactionSheet(transaction: transaction),
  );
}

class AddTransactionSheet extends StatefulWidget {
  final MoneyTransaction? transaction;

  const AddTransactionSheet({super.key, this.transaction});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();

  late TransactionType _type;
  String? _category;
  String? _accountId;
  String? _toAccountId;
  late DateTime _date;
  bool _isSaving = false;

  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    final t = widget.transaction;
    _type = t?.type ?? TransactionType.expense;
    _category = t?.category;
    _accountId = t?.accountId;
    _toAccountId = t?.toAccountId;
    _date = t?.date ?? DateTime.now();
    if (t != null) {
      _amountController.text = t.amount.toStringAsFixed(2);
      _descriptionController.text = t.description ?? '';
      _notesController.text = t.notes ?? '';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  List<TransactionCategory> get _categoryOptions {
    return _type == TransactionType.income
        ? TransactionCategory.incomeCategories
        : TransactionCategory.expenseCategories;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2015),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (_type != TransactionType.transfer && _category == null) {
      AppSnackbar.error(context, 'Please choose a category.');
      return;
    }
    if (_accountId == null) {
      AppSnackbar.error(context, 'Please choose an account.');
      return;
    }
    if (_type == TransactionType.transfer) {
      if (_toAccountId == null) {
        AppSnackbar.error(context, 'Please choose a destination account.');
        return;
      }
      if (_toAccountId == _accountId) {
        AppSnackbar.error(context, 'Source and destination accounts must differ.');
        return;
      }
    }
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text.replaceAll(',', ''));
    final category = _type == TransactionType.transfer
        ? TransactionCategory.transferCategory.name
        : _category!;

    setState(() => _isSaving = true);
    final txService = context.read<TransactionService>();
    try {
      if (_isEditing) {
        await txService.updateTransaction(
          widget.transaction!.id,
          type: _type,
          amount: amount,
          category: category,
          accountId: _accountId!,
          toAccountId: _toAccountId,
          date: _date,
          description: _descriptionController.text,
          notes: _notesController.text,
        );
      } else {
        await txService.addTransaction(
          type: _type,
          amount: amount,
          category: category,
          accountId: _accountId!,
          toAccountId: _toAccountId,
          date: _date,
          description: _descriptionController.text,
          notes: _notesController.text,
        );
      }
      if (mounted) {
        Navigator.of(context).pop();
        AppSnackbar.success(context, _isEditing ? 'Transaction updated.' : 'Transaction added.');
      }
    } catch (e) {
      if (mounted) AppSnackbar.error(context, 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accounts = context.watch<AccountService>().accounts;
    final viewInsets = MediaQuery.of(context).viewInsets;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 100),
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.darkCharcoal,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.92),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.mutedGray.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_isEditing ? 'Edit Transaction' : 'Add Transaction', style: AppTextStyles.headline),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xl),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTypeSelector(),
                      const SizedBox(height: AppSpacing.lg),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: AppTextStyles.numericMedium,
                        decoration: const InputDecoration(
                          labelText: 'Amount',
                          prefixText: '₱ ',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Enter an amount';
                          final parsed = double.tryParse(value.replaceAll(',', ''));
                          if (parsed == null || parsed <= 0) return 'Enter a valid amount';
                          return null;
                        },
                      ),
                      if (_type != TransactionType.transfer) ...[
                        const SizedBox(height: AppSpacing.lg),
                        Text('Category', style: AppTextStyles.subtitle.copyWith(color: AppColors.mutedGray)),
                        const SizedBox(height: AppSpacing.sm),
                        _buildCategoryGrid(),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      accounts.isEmpty
                          ? _buildNoAccountsNotice()
                          : DropdownButtonFormField<String>(
                              initialValue: _accountId,
                              decoration: InputDecoration(
                                labelText: _type == TransactionType.transfer ? 'From account' : 'Account',
                              ),
                              items: accounts
                                  .map((a) => DropdownMenuItem(value: a.id, child: Text(a.name)))
                                  .toList(),
                              onChanged: (value) => setState(() => _accountId = value),
                              validator: (value) => value == null ? 'Select an account' : null,
                            ),
                      if (_type == TransactionType.transfer) ...[
                        const SizedBox(height: AppSpacing.lg),
                        DropdownButtonFormField<String>(
                          initialValue: _toAccountId,
                          decoration: const InputDecoration(labelText: 'To account'),
                          items: accounts
                              .map((a) => DropdownMenuItem(value: a.id, child: Text(a.name)))
                              .toList(),
                          onChanged: (value) => setState(() => _toAccountId = value),
                          validator: (value) => value == null ? 'Select a destination account' : null,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Date'),
                          child: Row(
                            children: [
                              Text(
                                '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
                              ),
                              const Spacer(),
                              const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.mutedGray),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(labelText: 'Description (optional)'),
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(labelText: 'Notes (optional)'),
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: 2,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      ElevatedButton(
                        onPressed: (_isSaving || accounts.isEmpty) ? null : _save,
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(_isEditing ? 'Save Changes' : 'Add Transaction'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoAccountsNotice() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.bloomPink.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.bloomPink.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('You need an account first', style: AppTextStyles.bodyStrong),
          const SizedBox(height: 4),
          Text(
            'Add a bank, e-wallet, or cash account to start recording transactions.',
            style: AppTextStyles.caption.copyWith(color: AppColors.mutedGray),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop();
              showAddAccountSheet(context);
            },
            child: const Text('Add Account'),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Row(
      children: TransactionType.values.map((type) {
        final selected = _type == type;
        final color = switch (type) {
          TransactionType.income => AppColors.successGreen,
          TransactionType.expense => AppColors.expenseRed,
          TransactionType.transfer => AppColors.bloomPink,
        };
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: type == TransactionType.values.last ? 0 : AppSpacing.sm),
            child: GestureDetector(
              onTap: () => setState(() {
                _type = type;
                _category = null;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? color.withValues(alpha: 0.16) : AppColors.surfaceElevatedDark,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: selected ? color : AppColors.borderDark),
                ),
                alignment: Alignment.center,
                child: Text(
                  type.label,
                  style: AppTextStyles.bodyStrong.copyWith(color: selected ? color : AppColors.mutedGray),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryGrid() {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: _categoryOptions.map((category) {
        final selected = _category == category.name;
        return GestureDetector(
          onTap: () => setState(() => _category = category.name),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? category.color.withValues(alpha: 0.18) : AppColors.surfaceElevatedDark,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: selected ? category.color : AppColors.borderDark),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconAvatar(icon: category.icon, color: category.color, size: 22),
                const SizedBox(width: 6),
                Text(
                  category.name,
                  style: AppTextStyles.caption.copyWith(
                    color: selected ? category.color : AppColors.offWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
