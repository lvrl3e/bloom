import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class BloomProgressBar extends StatelessWidget {
  final double value; // 0..1
  final Color color;
  final double height;

  const BloomProgressBar({
    super.key,
    required this.value,
    this.color = AppColors.bloomPink,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Container(
                height: height,
                width: constraints.maxWidth,
                color: color.withValues(alpha: 0.14),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                height: height,
                width: constraints.maxWidth * clamped,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
