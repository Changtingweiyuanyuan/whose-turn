import 'package:flutter/material.dart';

/// 品牌色票 v2 —— Prodigy 極簡 × 繽紛 Year-in-Review：
/// 背景 #F7F7F7、墨黑 #010101、主色 #C2D1D3、橘 #FF8B04、粉 #CF729B。
abstract final class AppColors {
  static const ink = Color(0xFF010101);
  static const main = Color(0xFFC2D1D3);
  static const orange = Color(0xFFFF8B04);
  static const pink = Color(0xFFCF729B);
  static const bg = Color(0xFFF7F7F7);
  static const white = Color(0xFFFFFFFF);

  // 衍生色（柔和背景、輔助文字）
  static const inkSoft = Color(0xFF6F6F6F);
  static const mainSoft = Color(0xFFE6EDEE);
  static const pinkSoft = Color(0xFFF6E4EC);
  static const orangeSoft = Color(0xFFFFE9CD);
  static const lightGray = Color(0xFFE7E7E7);
  static const starEmpty = Color(0xFFD9D9D9);
}
