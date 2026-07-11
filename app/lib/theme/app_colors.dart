import 'package:flutter/material.dart';

/// 品牌色票（定案）：深藍 / 粉 / 黃 / 米白 / 淺灰
/// 比例建議：米白(背景) 55%・淺灰 25%・粉 10%・黃 10%，深藍用於文字與重點。
abstract final class AppColors {
  static const navy = Color(0xFF255359);
  static const pink = Color(0xFFA75F7B);
  static const yellow = Color(0xFFFFB21B);
  static const cream = Color(0xFFFFF8ED);
  static const lightGray = Color(0xFFEAECEF);
  static const white = Color(0xFFFFFFFF);

  // 衍生色（柔和背景、輔助文字）
  static const pinkSoft = Color(0xFFF1E3E9);
  static const yellowSoft = Color(0xFFFFF1D2);
  static const navySoft = Color(0xFF4A7178);
  static const starEmpty = Color(0xFFD8DCE0);
}
