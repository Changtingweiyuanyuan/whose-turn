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
    // 編輯排版風：主要按鈕墨黑白字，main 作為選中/次要 surface
    primary: AppColors.ink,
    primaryForeground: AppColors.white,
    secondary: AppColors.main,
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
        // 按鈕類（含 input）圓角 6
        radius: BorderRadius.circular(6),
        // 卡片：圓角 8、1px 邊框、無 shadow
        cardTheme: ShadCardTheme(
          shadows: const [],
          radius: BorderRadius.circular(8),
          border: ShadBorder.all(color: AppColors.lightGray, width: 1),
        ),
        textTheme: ShadTextTheme(
          family: GoogleFonts.robotoCondensed().fontFamily!,
        ),
      );
}
