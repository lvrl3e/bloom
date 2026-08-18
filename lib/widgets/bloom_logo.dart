import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Minimal bloom/flower mark: overlapping petals suggesting growth,
/// built from simple shapes rather than an image asset.
class BloomLogo extends StatelessWidget {
  final double size;
  final Color color;

  const BloomLogo({super.key, this.size = 32, this.color = AppColors.bloomPink});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _BloomPainter(color: color),
      ),
    );
  }
}

class _BloomPainter extends CustomPainter {
  final Color color;
  const _BloomPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final petalRadius = size.width * 0.24;
    final orbit = size.width * 0.22;

    final petalPaint = Paint()..color = color;
    final corePaint = Paint()..color = Colors.white;

    for (var i = 0; i < 5; i++) {
      final angle = (i * 72) * math.pi / 180;
      final dx = center.dx + orbit * math.cos(angle);
      final dy = center.dy + orbit * math.sin(angle);
      canvas.drawCircle(Offset(dx, dy), petalRadius, petalPaint..color = color.withValues(alpha: 0.85));
    }

    canvas.drawCircle(center, size.width * 0.14, corePaint);
  }

  @override
  bool shouldRepaint(covariant _BloomPainter oldDelegate) => oldDelegate.color != color;
}
