import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/goal_model.dart';
import '../../services/goal_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/formatters.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/bloom_progress_bar.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/icon_avatar.dart';
import '../../widgets/status_badge.dart';
import 'add_goal_sheet.dart';

class GoalDetailScreen extends StatelessWidget {
  final String goalId;
  const GoalDetailScreen({super.key, required this.goalId});

  @override
  Widget build(BuildContext context) {
    final goalService = context.watch<GoalService>();
    Goal? goal;
    for (final g in goalService.goals) {
      if (g.id == goalId) {
        goal = g;
        break;
      }
    }

    if (goal == null) {
      return const Scaffold(body: Center(child: Text('Goal not found')));
    }
    final resolvedGoal = goal;

    final status = resolvedGoal.status;

    return Scaffold(
      appBar: AppBar(
        title: Text(resolvedGoal.name, overflow: TextOverflow.ellipsis),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'edit') {
                showAddGoalSheet(context, goal: resolvedGoal);
              } else if (value == 'delete') {
                final confirmed = await showConfirmDialog(
                  context,
                  title: 'Delete ${resolvedGoal.name}?',
                  message: 'This will permanently delete this goal and its contribution history.',
                );
                if (confirmed && context.mounted) {
                  await context.read<GoalService>().deleteGoal(resolvedGoal.id);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    AppSnackbar.success(context, 'Goal deleted.');
                  }
                }
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
      floatingActionButton: status == GoalStatus.completed
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _showContributeSheet(context, resolvedGoal),
              backgroundColor: AppColors.bloomPink,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Contribution'),
            ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 100),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconAvatar(icon: GoalCategoryPreset.iconFor(goal.category), color: AppColors.bloomPink, size: 52),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(goal.category, style: AppTextStyles.caption.copyWith(color: AppColors.mutedGray)),
                              const SizedBox(height: 2),
                              StatusBadge(label: status.label, color: status.color, emoji: status.emoji),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(Formatters.currency(goal.currentAmount), style: AppTextStyles.numericLarge),
                    Text(
                      'of ${Formatters.currency(goal.targetAmount)} goal',
                      style: AppTextStyles.body.copyWith(color: AppColors.mutedGray),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    BloomProgressBar(value: goal.percentComplete, color: status.color, height: 10),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '${Formatters.percent(goal.percentComplete)} complete',
                      style: AppTextStyles.caption.copyWith(color: AppColors.mutedGray),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: _StatBox(
                    label: 'Remaining',
                    value: Formatters.currency(goal.remainingAmount),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _StatBox(
                    label: 'Target Date',
                    value: Formatters.monthYear(goal.targetDate),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _StatBox(
                    label: 'Required / mo.',
                    value: Formatters.currency(goal.requiredMonthlySavings),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _StatBox(
                    label: 'Planned / mo.',
                    value: Formatters.currency(goal.monthlyContribution),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _StatBox(label: 'Priority', value: goal.priority.label, fullWidth: true),
            if (goal.notes != null && goal.notes!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              Text('Notes', style: AppTextStyles.subtitle.copyWith(color: AppColors.mutedGray)),
              const SizedBox(height: AppSpacing.sm),
              Text(goal.notes!, style: AppTextStyles.body),
            ],
            const SizedBox(height: AppSpacing.xl),
            Text('Contribution History', style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.sm),
            FutureBuilder(
              future: goalService.contributionsFor(goal.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                    child: Center(child: CircularProgressIndicator(color: AppColors.bloomPink)),
                  );
                }
                final contributions = snapshot.data!;
                if (contributions.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    child: EmptyState(
                      icon: Icons.savings_outlined,
                      title: 'No contributions yet',
                      message: 'Log a contribution to see it appear here.',
                    ),
                  );
                }
                return Column(
                  children: contributions.map((c) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Card(
                        child: ListTile(
                          leading: const IconAvatar(icon: Icons.savings_rounded, color: AppColors.successGreen, size: 40),
                          title: Text('+${Formatters.currency(c.amount)}', style: AppTextStyles.bodyStrong),
                          subtitle: Text(
                            c.note?.isNotEmpty == true ? c.note! : Formatters.shortDate(c.date),
                            style: AppTextStyles.caption.copyWith(color: AppColors.mutedGray),
                          ),
                          trailing: Text(
                            Formatters.shortDate(c.date),
                            style: AppTextStyles.caption.copyWith(color: AppColors.mutedGray),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showContributeSheet(BuildContext context, Goal goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ContributeSheet(goal: goal),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final bool fullWidth;

  const _StatBox({required this.label, required this.value, this.fullWidth = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.mutedGray)),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.bodyStrong),
        ],
      ),
    );
  }
}

class _ContributeSheet extends StatefulWidget {
  final Goal goal;
  const _ContributeSheet({required this.goal});

  @override
  State<_ContributeSheet> createState() => _ContributeSheetState();
}

class _ContributeSheetState extends State<_ContributeSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _date = DateTime.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      await context.read<GoalService>().addContribution(
            goalId: widget.goal.id,
            amount: double.parse(_amountController.text.replaceAll(',', '')),
            date: _date,
            note: _noteController.text,
          );
      if (mounted) {
        Navigator.of(context).pop();
        AppSnackbar.success(context, 'Contribution added.');
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
        padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xl),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Contribution', style: AppTextStyles.headline),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: AppTextStyles.numericMedium,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Amount', prefixText: '₱ '),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Enter an amount';
                  final parsed = double.tryParse(value.replaceAll(',', ''));
                  if (parsed == null || parsed <= 0) return 'Enter a valid amount';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2015),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _date = picked);
                },
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Date'),
                  child: Row(
                    children: [
                      Text(Formatters.shortDate(_date)),
                      const Spacer(),
                      const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.mutedGray),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: 'Note (optional)'),
                textCapitalization: TextCapitalization.sentences,
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
                    : const Text('Add Contribution'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
