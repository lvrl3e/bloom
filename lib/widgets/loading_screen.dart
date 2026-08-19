import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'bloom_logo.dart';

/// Full-screen splash shown once, while the app's initial data (accounts,
/// transactions, goals) is loading — before the tab shell mounts.
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BloomLogo(size: 56),
            const SizedBox(height: 16),
            Text('BLOOM', style: AppTextStyles.displayMedium.copyWith(color: onSurface)),
            const SizedBox(height: 4),
            Text(
              'Track. Save. Bloom.',
              style: AppTextStyles.caption.copyWith(color: AppColors.mutedGray),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(color: AppColors.bloomPink, strokeWidth: 2.5),
            ),
          ],
        ),
      ),
    );
  }
}
