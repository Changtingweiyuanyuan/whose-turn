import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

/// 標題毛筆手寫感字型 —— LXGW WenKai TC（霞鶩文楷，OFL 授權，完整繁中）。
/// 只用在刊頭大標與卡片標題；內文仍用 Roboto Condensed + Noto Sans TC。
abstract final class AppFonts {
  static TextStyle brush({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w700,
    double? height,
    Color? color,
  }) {
    return GoogleFonts.lxgwWenKaiTc(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      color: color,
    );
  }
}
