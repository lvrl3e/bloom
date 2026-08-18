import 'package:flutter/material.dart';
import '../../models/category_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/formatters.dart';

class TransactionFilters {
  final String? category;
  final DateTimeRange? dateRange;

  const TransactionFilters({this.category, this.dateRange});

  bool get isActive => category != null || dateRange != null;

  TransactionFilters copyWith({
    String? category,
    bool clearCategory = false,
    DateTimeRange? dateRange,
    bool clearDateRange = false,
  }) {
    return TransactionFilters(
      category: clearCategory ? null : (category ?? this.category),
      dateRange: clearDateRange ? null : (dateRange ?? this.dateRange),
    );
  }
}

Future<TransactionFilters?> showTransactionFilterSheet(
  BuildContext context,
  TransactionFilters current,
) {
  return showModalBottomSheet<TransactionFilters>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _TransactionFilterSheet(initial: current),
  );
}

class _TransactionFilterSheet extends StatefulWidget {
  final TransactionFilters initial;
  const _TransactionFilterSheet({required this.initial});

  @override
  State<_TransactionFilterSheet> createState() => _TransactionFilterSheetState();
}

class _TransactionFilterSheetState extends State<_TransactionFilterSheet> {
  late TransactionFilters _filters;

  @override
  void initState() {
    super.initState();
    _filters = widget.initial;
  }

  final _allCategories = [
    ...TransactionCategory.incomeCategories,
    ...TransactionCategory.expenseCategories,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.darkCharcoal,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
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
                const Text('Filter Transactions', style: AppTextStyles.headline),
                TextButton(
                  onPressed: () => setState(() => _filters = const TransactionFilters()),
                  child: const Text('Clear all'),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Date range', style: AppTextStyles.subtitle.copyWith(color: AppColors.mutedGray)),
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2015),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        initialDateRange: _filters.dateRange,
                      );
                      if (picked != null) {
                        setState(() => _filters = _filters.copyWith(dateRange: picked));
                      }
                    },
                    icon: const Icon(Icons.date_range_rounded, size: 18),
                    label: Text(
                      _filters.dateRange == null
                          ? 'Any date'
                          : '${Formatters.shortDate(_filters.dateRange!.start)} — ${Formatters.shortDate(_filters.dateRange!.end)}',
                    ),
                  ),
                  if (_filters.dateRange != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () => setState(() => _filters = _filters.copyWith(clearDateRange: true)),
                        child: const Text('Reset date range'),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Category', style: AppTextStyles.subtitle.copyWith(color: AppColors.mutedGray)),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: _allCategories.map((category) {
                      final selected = _filters.category == category.name;
                      return ChoiceChip(
                        label: Text(category.name),
                        selected: selected,
                        onSelected: (value) => setState(() {
                          _filters = _filters.copyWith(
                            category: value ? category.name : null,
                            clearCategory: !value,
                          );
                        }),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(_filters),
                    child: const Text('Apply Filters'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
