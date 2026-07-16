import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  /// 英數用 Roboto Condensed，中文 fallback 到 Noto Sans TC。
  static String get _fontFamily => GoogleFonts.robotoCondensed().fontFamily!;
  static List<String> get _fontFallback =>
      [GoogleFonts.notoSansTc().fontFamily!];

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.main,
        primary: AppColors.main,
        secondary: AppColors.orange,
        surface: AppColors.bg,
        onSurface: AppColors.ink,
      ),
      scaffoldBackgroundColor: AppColors.bg,
    );

    final textTheme = base.textTheme.apply(
      fontFamily: _fontFamily,
      fontFamilyFallback: _fontFallback,
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
