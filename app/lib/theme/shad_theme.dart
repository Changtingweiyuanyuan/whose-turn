import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'app_colors.dart';

/// shadcn_ui 主題：把品牌五色對應到 shadcn 的色彩系統。
abstract final class AppShadTheme {
  static const _colorScheme = ShadColorScheme(
    background: AppColors.cream,
    foreground: AppColors.navy,
    card: AppColors.white,
    cardForeground: AppColors.navy,
    popover: AppColors.white,
    popoverForeground: AppColors.navy,
    primary: AppColors.pink,
    primaryForeground: AppColors.white,
    secondary: AppColors.yellow,
    secondaryForeground: AppColors.navy,
    muted: AppColors.lightGray,
    mutedForeground: AppColors.navySoft,
    accent: AppColors.pinkSoft,
    accentForeground: AppColors.navy,
    destructive: Color(0xFFC0392B),
    destructiveForeground: AppColors.white,
    border: AppColors.lightGray,
    input: AppColors.lightGray,
    ring: AppColors.pink,
    selection: AppColors.pinkSoft,
  );

  static ShadThemeData get light => ShadThemeData(
        brightness: Brightness.light,
        colorScheme: _colorScheme,
        textTheme: ShadTextTheme(
          family: GoogleFonts.robotoCondensed().fontFamily!,
        ),
      );
}
