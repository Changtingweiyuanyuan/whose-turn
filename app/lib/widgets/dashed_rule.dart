import 'package:flutter/material.dart';

/// 水平虛線分隔線（樣式同 LINE 綁定 sheet：6px 線 + 4px 空）。
class DashedRule extends StatelessWidget {
  const DashedRule({
    super.key,
    required this.color,
    this.dash = 3,
    this.gap = 3,
    this.thickness = 1,
  });

  final Color color;
  final double dash;
  final double gap;
  final double thickness;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: thickness,
      width: double.infinity,
      child: CustomPaint(painter: _DashedPainter(color, dash, gap, thickness)),
    );
  }
}

class _DashedPainter extends CustomPainter {
  const _DashedPainter(this.color, this.dash, this.gap, this.thickness);

  final Color color;
  final double dash;
  final double gap;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;
    double x = 0;
    final y = size.height / 2;
    while (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset(x + dash, y), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedPainter old) =>
      old.color != color || old.dash != dash || old.gap != gap;
}
