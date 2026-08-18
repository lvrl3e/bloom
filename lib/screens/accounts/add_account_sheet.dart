import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/account_model.dart';
import '../../services/account_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/icon_avatar.dart';

const List<String> kAccountNamePresets = [
  'BPI', 'BDO', 'UnionBank', 'Metrobank', 'GCash', 'Maya', 'Cash', 'Credit Card',
];

Future<void> showAddAccountSheet(BuildContext context, {Account? account}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => AddAccountSheet(account: account),
  );
}

class AddAccountSheet extends StatefulWidget {
  final Account? account;

  const AddAccountSheet({super.key, this.account});

  @override
  State<AddAccountSheet> createState() => _AddAccountSheetState();
}

class _AddAccountSheetState extends State<AddAccountSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  final _notesController = TextEditingController();

  late AccountType _type;
  bool _isSaving = false;

  bool get _isEditing => widget.account != null;

  @override
  void initState() {
    super.initState();
    final a = widget.account;
    _type = a?.type ?? AccountType.bank;
    _nameController.text = a?.name ?? '';
    _balanceController.text = a != null ? a.balance.toStringAsFixed(2) : '';
    _notesController.text = a?.notes ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final service = context.read<AccountService>();
    try {
      if (_isEditing) {
        await service.updateAccount(
          widget.account!.id,
          name: _nameController.text,
          type: _type,
          notes: _notesController.text,
        );
      } else {
        await service.addAccount(
          name: _nameController.text,
          type: _type,
          balance: double.parse(_balanceController.text.replaceAll(',', '')),
          notes: _notesController.text,
        );
      }
      if (mounted) {
        Navigator.of(context).pop();
        AppSnackbar.success(context, _isEditing ? 'Account updated.' : 'Account added.');
      }
    } catch (e) {
      if (mounted) AppSnackbar.error(context, 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  Text(_isEditing ? 'Edit Account' : 'Add Account', style: AppTextStyles.headline),
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
                      Text('Account Type', style: AppTextStyles.subtitle.copyWith(color: AppColors.mutedGray)),
                      const SizedBox(height: AppSpacing.sm),
                      _buildTypeGrid(),
                      const SizedBox(height: AppSpacing.lg),
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(labelText: 'Account name'),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty) ? 'Enter an account name' : null,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: kAccountNamePresets.map((preset) {
                          return GestureDetector(
                            onTap: () => setState(() => _nameController.text = preset),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceElevatedDark,
                                borderRadius: BorderRadius.circular(AppRadius.pill),
                                border: Border.all(color: AppColors.borderDark),
                              ),
                              child: Text(preset, style: AppTextStyles.caption),
                            ),
                          );
                        }).toList(),
                      ),
                      if (!_isEditing) ...[
                        const SizedBox(height: AppSpacing.lg),
                        TextFormField(
                          controller: _balanceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: AppTextStyles.numericMedium,
                          decoration: const InputDecoration(labelText: 'Current balance', prefixText: '₱ '),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return 'Enter a starting balance';
                            if (double.tryParse(value.replaceAll(',', '')) == null) return 'Enter a valid amount';
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(labelText: 'Notes (optional)'),
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: 2,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.successGreen.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.lock_rounded, size: 16, color: AppColors.successGreen),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'BLOOM never asks for passwords, PINs, or OTPs. Only balances you enter yourself.',
                                style: AppTextStyles.caption.copyWith(color: AppColors.mutedGray),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(_isEditing ? 'Save Changes' : 'Add Account'),
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

  Widget _buildTypeGrid() {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: AccountType.values.map((type) {
        final selected = _type == type;
        return GestureDetector(
          onTap: () => setState(() => _type = type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? AppColors.bloomPink.withValues(alpha: 0.18) : AppColors.surfaceElevatedDark,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: selected ? AppColors.bloomPink : AppColors.borderDark),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconAvatar(icon: type.icon, color: selected ? AppColors.bloomPink : AppColors.mutedGray, size: 22),
                const SizedBox(width: 6),
                Text(
                  type.label,
                  style: AppTextStyles.caption.copyWith(
                    color: selected ? AppColors.bloomPink : AppColors.offWhite,
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
