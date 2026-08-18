import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Success/error toast helper so screens don't hand-roll SnackBars.
class AppSnackbar {
  AppSnackbar._();

  static void success(BuildContext context, String message) {
    _show(context, message, icon: Icons.check_circle_rounded, iconColor: AppColors.successGreen);
  }

  static void error(BuildContext context, String message) {
    _show(context, message, icon: Icons.error_rounded, iconColor: AppColors.expenseRed);
  }

  static void info(BuildContext context, String message) {
    _show(context, message, icon: Icons.info_rounded, iconColor: AppColors.bloomPink);
  }

  static void _show(
    BuildContext context,
    String message, {
    required IconData icon,
    required Color iconColor,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}
