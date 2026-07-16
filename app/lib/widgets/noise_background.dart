import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// 有顆粒雜訊的純色背景 —— 純 code（CustomPainter 灑淡白點），不用圖片。
/// 用法：NoiseBackground(child: ...)，預設黑底。
class NoiseBackground extends StatelessWidget {
  const NoiseBackground({
    super.key,
    required this.child,
    this.color = AppColors.ink,
    this.opacity = 0.2,
    this.density = 0.1,
  });

  final Widget child;
  final Color color;

  /// 每個雜訊點的最大透明度（越大顆粒越明顯）
  final double opacity;

  /// 密度：每 1px² 的點數（越大越密）
  final double density;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color,
      child: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _NoisePainter(opacity: opacity, density: density),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _NoisePainter extends CustomPainter {
  _NoisePainter({required this.opacity, required this.density});

  final double opacity;
  final double density;

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(42); // 固定 seed → 每次顆粒分布一致，不會閃動
    final paint = Paint();
    final count = (size.width * size.height * density).toInt();
    for (var i = 0; i < count; i++) {
      paint.color = Colors.white.withValues(alpha: rng.nextDouble() * opacity);
      canvas.drawRect(
        Rect.fromLTWH(
          rng.nextDouble() * size.width,
          rng.nextDouble() * size.height,
          1,
          1,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _NoisePainter old) =>
      old.opacity != opacity || old.density != density;
}
