import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/goal_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/formatters.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/goal_card.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/theme_toggle_button.dart';
import 'add_goal_sheet.dart';
import 'goal_detail_screen.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<GoalService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Goals'),
        actions: [
          IconButton(
            onPressed: () => showAddGoalSheet(context),
            icon: const Icon(Icons.add_rounded),
            tooltip: 'New goal',
          ),
          const ThemeToggleButton(),
        ],
      ),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (service.isLoading) return const LoadingView();
            if (service.error != null) {
              return ErrorView(message: service.error!, onRetry: service.load);
            }
            if (service.goals.isEmpty) {
              return SingleChildScrollView(
                child: EmptyState(
                  icon: Icons.flag_outlined,
                  title: 'No goals yet',
                  message: 'Set a savings goal — an emergency fund, a trip, a big purchase — and watch it bloom.',
                  actionLabel: 'Create Goal',
                  onAction: () => showAddGoalSheet(context),
                ),
              );
            }

            final active = service.activeGoals;
            final completed = service.completedGoals;

            return RefreshIndicator(
              color: AppColors.bloomPink,
              onRefresh: service.load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 100),
                children: [
                  _GoalsSummaryCard(saved: service.totalSaved, target: service.totalTarget),
                  const SizedBox(height: AppSpacing.xl),
                  if (active.isNotEmpty) ...[
                    Text('Active Goals', style: AppTextStyles.title),
                    const SizedBox(height: AppSpacing.md),
                    ...active.map(
                      (goal) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: GoalCard(
                          goal: goal,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => GoalDetailScreen(goalId: goal.id)),
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (completed.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text('Completed', style: AppTextStyles.title),
                    const SizedBox(height: AppSpacing.md),
                    ...completed.map(
                      (goal) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: GoalCard(
                          goal: goal,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => GoalDetailScreen(goalId: goal.id)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GoalsSummaryCard extends StatelessWidget {
  final double saved;
  final double target;

  const _GoalsSummaryCard({required this.saved, required this.target});

  @override
  Widget build(BuildContext context) {
    final progress = target <= 0 ? 0.0 : (saved / target).clamp(0.0, 1.0);
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
          Text('TOTAL SAVED TOWARD GOALS', style: AppTextStyles.overline.copyWith(color: Colors.white.withValues(alpha: 0.85))),
          const SizedBox(height: AppSpacing.xs),
          Text(Formatters.currency(saved), style: AppTextStyles.numericLarge.copyWith(color: Colors.white)),
          const SizedBox(height: 4),
          Text(
            'of ${Formatters.currency(target)} across all goals',
            style: AppTextStyles.caption.copyWith(color: Colors.white.withValues(alpha: 0.85)),
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
