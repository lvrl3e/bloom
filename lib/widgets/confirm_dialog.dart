import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Standard destructive-action confirmation dialog.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Delete',
  bool isDestructive = true,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(
            foregroundColor: isDestructive ? AppColors.expenseRed : AppColors.bloomPink,
          ),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}
