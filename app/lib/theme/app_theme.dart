import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  /// 英數用 Roboto Condensed，中文 fallback 到 Noto Sans TC。
  static String get _fontFamily => GoogleFonts.robotoCondensed().fontFamily!;
  static List<String> get _fontFallback =>
      [GoogleFonts.notoSansTc().fontFamily!];

  /// 全站字距（theme 層套用，AppBar／按鈕等自帶樣式的元件也吃得到）。
  static const letterSpacing = 0.8;

  /// 幫 TextTheme 的每個角色都加上全站字距。
  static TextTheme _spaced(TextTheme t) {
    TextStyle? s(TextStyle? style) =>
        style?.copyWith(letterSpacing: letterSpacing);
    return TextTheme(
      displayLarge: s(t.displayLarge),
      displayMedium: s(t.displayMedium),
      displaySmall: s(t.displaySmall),
      headlineLarge: s(t.headlineLarge),
      headlineMedium: s(t.headlineMedium),
      headlineSmall: s(t.headlineSmall),
      titleLarge: s(t.titleLarge),
      titleMedium: s(t.titleMedium),
      titleSmall: s(t.titleSmall),
      bodyLarge: s(t.bodyLarge),
      bodyMedium: s(t.bodyMedium),
      bodySmall: s(t.bodySmall),
      labelLarge: s(t.labelLarge),
      labelMedium: s(t.labelMedium),
      labelSmall: s(t.labelSmall),
    );
  }

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

    final textTheme = _spaced(base.textTheme.apply(
      fontFamily: _fontFamily,
      fontFamilyFallback: _fontFallback,
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    ));

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
