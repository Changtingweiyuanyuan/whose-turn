import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart' show SvgPicture;

import '../theme/app_colors.dart';

/// 紙張感背景 —— 紙白基底 + 蠟筆格紋圖磚重複 + 雜點 + 隨機 $ 符號 + 1px 粉外框。
/// 用法：NoiseBackground(child: ...)。
class NoiseBackground extends StatelessWidget {
  const NoiseBackground({
    super.key,
    required this.child,
    this.color = AppColors.paper,
    this.opacity = 0.9,
    this.density = 0.06,
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
          // 蠟筆格紋圖磚
          Positioned.fill(
            child: Image.asset(
              'assets/images/paper_grid.png',
              repeat: ImageRepeat.repeat,
              scale: 4, // 384px 磚 → 96 邏輯 px
            ),
          ),
          // 紙張雜點
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _NoisePainter(opacity: opacity, density: density),
              ),
            ),
          ),
          // 隨機灑落的 $ 符號
          const Positioned.fill(child: _DollarScatter()),
          child,
          // 左右 1.5px 粉色邊框（上下不畫，避開狀態列與螢幕圓角；蓋在最上、不擋點擊）
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  border: Border(
                    left: BorderSide(color: AppColors.framePink, width: 1.5),
                    right: BorderSide(color: AppColors.framePink, width: 1.5),
                  ),
                ),
              ),
            ),
          ),
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
      paint.color =
          AppColors.paperNoise.withValues(alpha: rng.nextDouble() * opacity);
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

/// 固定 seed 的隨機 $ 灑落（LayoutBuilder 依畫面大小佈點，不會閃動）。
class _DollarScatter extends StatelessWidget {
  const _DollarScatter();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final rng = Random(7);
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        // 大約每 45000 px² 一顆，手機直式約 7~8 顆
        final count = max(6, (w * h / 45000).round());
        return Stack(
          children: [
            for (var i = 0; i < count; i++)
              Positioned(
                left: rng.nextDouble() * (w - 24),
                top: rng.nextDouble() * (h - 32),
                child: Transform.rotate(
                  angle: (rng.nextDouble() - 0.5) * 0.6, // 約 ±17°
                  child: SvgPicture.asset(
                    'assets/icons/dollar.svg',
                    width: 12 + rng.nextDouble() * 4,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
