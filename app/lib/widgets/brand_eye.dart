import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// 手繪風抽象眼睛品牌標記 —— 取代 👀 emoji。
/// 純 CustomPaint，無圖檔／字型依賴。兩顆微微歪斜的眼睛，帶編輯手感。
class BrandEye extends StatelessWidget {
  const BrandEye({super.key, this.size = 34});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size * 1.6, size),
      painter: _EyePainter(),
    );
  }
}

class _EyePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = AppColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.height * 0.09
      ..strokeCap = StrokeCap.round;
    final pupil = Paint()..color = AppColors.ink;
    final accent = Paint()..color = AppColors.orange;

    final eyeW = size.width * 0.42;
    final eyeH = size.height * 0.72;
    final cy = size.height / 2;

    void eye(double cx, double tilt, Paint dot) {
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(tilt);
      // 杏仁形外框（兩段弧線）
      final path = Path()
        ..moveTo(-eyeW / 2, 0)
        ..quadraticBezierTo(0, -eyeH / 2, eyeW / 2, 0)
        ..quadraticBezierTo(0, eyeH / 2, -eyeW / 2, 0);
      canvas.drawPath(path, stroke);
      canvas.drawCircle(Offset.zero, eyeH * 0.2, dot);
      canvas.restore();
    }

    eye(size.width * 0.26, -0.12, pupil);
    eye(size.width * 0.72, 0.10, accent);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
