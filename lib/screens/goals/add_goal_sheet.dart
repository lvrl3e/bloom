import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/goal_model.dart';
import '../../services/goal_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/icon_avatar.dart';

Future<void> showAddGoalSheet(BuildContext context, {Goal? goal}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => AddGoalSheet(goal: goal),
  );
}

class AddGoalSheet extends StatefulWidget {
  final Goal? goal;
  const AddGoalSheet({super.key, this.goal});

  @override
  State<AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends State<AddGoalSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  final _currentController = TextEditingController();
  final _monthlyController = TextEditingController();
  final _notesController = TextEditingController();

  String _category = GoalCategoryPreset.all.first.name;
  GoalPriority _priority = GoalPriority.medium;
  late DateTime _targetDate;
  bool _isSaving = false;

  bool get _isEditing => widget.goal != null;

  @override
  void initState() {
    super.initState();
    final g = widget.goal;
    _category = g?.category ?? GoalCategoryPreset.all.first.name;
    _priority = g?.priority ?? GoalPriority.medium;
    _targetDate = g?.targetDate ?? DateTime.now().add(const Duration(days: 180));
    _nameController.text = g?.name ?? '';
    _targetController.text = g != null ? g.targetAmount.toStringAsFixed(0) : '';
    _currentController.text = g != null ? g.currentAmount.toStringAsFixed(0) : '0';
    _monthlyController.text = g != null ? g.monthlyContribution.toStringAsFixed(0) : '';
    _notesController.text = g?.notes ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _currentController.dispose();
    _monthlyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 20)),
    );
    if (picked != null) setState(() => _targetDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final target = double.parse(_targetController.text.replaceAll(',', ''));
    final current = double.tryParse(_currentController.text.replaceAll(',', '')) ?? 0;
    final monthly = double.tryParse(_monthlyController.text.replaceAll(',', '')) ?? 0;

    setState(() => _isSaving = true);
    final service = context.read<GoalService>();
    try {
      if (_isEditing) {
        await service.updateGoal(
          widget.goal!.id,
          name: _nameController.text,
          targetAmount: target,
          targetDate: _targetDate,
          category: _category,
          priority: _priority,
          monthlyContribution: monthly,
          notes: _notesController.text,
        );
      } else {
        await service.addGoal(
          name: _nameController.text,
          targetAmount: target,
          currentAmount: current,
          targetDate: _targetDate,
          category: _category,
          priority: _priority,
          monthlyContribution: monthly,
          notes: _notesController.text,
        );
      }
      if (mounted) {
        Navigator.of(context).pop();
        AppSnackbar.success(context, _isEditing ? 'Goal updated.' : 'Goal created.');
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
                  Text(_isEditing ? 'Edit Goal' : 'New Goal', style: AppTextStyles.headline),
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
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(labelText: 'Goal name'),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty) ? 'Enter a goal name' : null,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text('Category', style: AppTextStyles.subtitle.copyWith(color: AppColors.mutedGray)),
                      const SizedBox(height: AppSpacing.sm),
                      _buildCategoryGrid(),
                      const SizedBox(height: AppSpacing.lg),
                      TextFormField(
                        controller: _targetController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: AppTextStyles.numericMedium,
                        decoration: const InputDecoration(labelText: 'Target amount', prefixText: '₱ '),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Enter a target amount';
                          final parsed = double.tryParse(value.replaceAll(',', ''));
                          if (parsed == null || parsed <= 0) return 'Enter a valid amount';
                          return null;
                        },
                      ),
                      if (!_isEditing) ...[
                        const SizedBox(height: AppSpacing.lg),
                        TextFormField(
                          controller: _currentController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Current savings', prefixText: '₱ '),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      TextFormField(
                        controller: _monthlyController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Planned monthly contribution', prefixText: '₱ '),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Target date'),
                          child: Row(
                            children: [
                              Text(
                                '${_targetDate.year}-${_targetDate.month.toString().padLeft(2, '0')}-${_targetDate.day.toString().padLeft(2, '0')}',
                              ),
                              const Spacer(),
                              const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.mutedGray),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text('Priority', style: AppTextStyles.subtitle.copyWith(color: AppColors.mutedGray)),
                      const SizedBox(height: AppSpacing.sm),
                      _buildPrioritySelector(),
                      const SizedBox(height: AppSpacing.lg),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(labelText: 'Notes (optional)'),
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: 2,
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
                            : Text(_isEditing ? 'Save Changes' : 'Create Goal'),
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

  Widget _buildCategoryGrid() {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: GoalCategoryPreset.all.map((preset) {
        final selected = _category == preset.name;
        return GestureDetector(
          onTap: () => setState(() => _category = preset.name),
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
                IconAvatar(icon: preset.icon, color: selected ? AppColors.bloomPink : AppColors.mutedGray, size: 22),
                const SizedBox(width: 6),
                Text(
                  preset.name,
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

  Widget _buildPrioritySelector() {
    return Row(
      children: GoalPriority.values.map((priority) {
        final selected = _priority == priority;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: priority == GoalPriority.values.last ? 0 : AppSpacing.sm),
            child: GestureDetector(
              onTap: () => setState(() => _priority = priority),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? AppColors.bloomPink.withValues(alpha: 0.16) : AppColors.surfaceElevatedDark,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: selected ? AppColors.bloomPink : AppColors.borderDark),
                ),
                alignment: Alignment.center,
                child: Text(
                  priority.label,
                  style: AppTextStyles.bodyStrong.copyWith(
                    color: selected ? AppColors.bloomPink : AppColors.mutedGray,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
