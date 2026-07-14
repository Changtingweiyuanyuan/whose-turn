import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'app_colors.dart';

/// shadcn_ui 主題 —— 品牌色票 v2：
/// 背景 #F7F7F7、墨黑 #010101、主色 #C2D1D3、橘 #FF8B04、粉 #CF729B。
abstract final class AppShadTheme {
  static const _colorScheme = ShadColorScheme(
    background: AppColors.bg,
    foreground: AppColors.ink,
    card: AppColors.white,
    cardForeground: AppColors.ink,
    popover: AppColors.white,
    popoverForeground: AppColors.ink,
    primary: AppColors.main,
    primaryForeground: AppColors.ink,
    secondary: AppColors.orange,
    secondaryForeground: AppColors.ink,
    muted: AppColors.lightGray,
    mutedForeground: AppColors.inkSoft,
    accent: AppColors.mainSoft,
    accentForeground: AppColors.ink,
    destructive: Color(0xFFC0392B),
    destructiveForeground: AppColors.white,
    border: AppColors.lightGray,
    input: AppColors.lightGray,
    ring: AppColors.ink,
    selection: AppColors.main,
  );

  static ShadThemeData get light => ShadThemeData(
        brightness: Brightness.light,
        colorScheme: _colorScheme,
        textTheme: ShadTextTheme(
          family: GoogleFonts.robotoCondensed().fontFamily!,
        ),
      );
}
