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
    // 彈出層（select 選項、日曆）深底白字
    popover: AppColors.diluteInk,
    popoverForeground: AppColors.white,
    // 編輯排版風：主要按鈕墨黑白字，main 作為選中/次要 surface
    primary: AppColors.ink,
    primaryForeground: AppColors.white,
    secondary: AppColors.main,
    secondaryForeground: AppColors.ink,
    muted: AppColors.lightGray,
    mutedForeground: AppColors.inkSoft,
    // hover / 選中 surface 用粉色系（日曆日期 hover、date picker hover）
    accent: AppColors.pinkSoft,
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
        // Toast：diluteInk 深色底 + 粉色邊框 + 白字
        primaryToastTheme: ShadToastTheme(
          backgroundColor: AppColors.diluteInk,
          radius: BorderRadius.circular(6),
          border: ShadBorder.all(
            color: AppColors.pink,
            width: 1,
            radius: BorderRadius.circular(6),
          ),
          descriptionStyle: const TextStyle(color: AppColors.white),
          shadows: const [],
        ),
        // 全站彈窗（dialog / alert / popover / date picker）統一粉色邊框
        primaryDialogTheme: ShadDialogTheme(
          border: Border.all(color: AppColors.pink, width: 1),
        ),
        alertDialogTheme: ShadDialogTheme(
          border: Border.all(color: AppColors.pink, width: 1),
        ),
        // Input：diluteInk 深底 + 白字（深色頁面上一致）
        inputTheme: const ShadInputTheme(
          decoration: ShadDecoration(color: AppColors.diluteInk),
          style: TextStyle(color: AppColors.white),
          placeholderStyle: TextStyle(color: Colors.white54),
          cursorColor: AppColors.white,
        ),
        // 誰都可以接開關：開=pink、關=pinkSoft、把手白
        switchTheme: const ShadSwitchTheme(
          thumbColor: AppColors.white,
          checkedTrackColor: AppColors.pink,
          uncheckedTrackColor: AppColors.pinkSoft,
        ),
        // 日曆：深底白字（配合 popover 深色）
        calendarTheme: const ShadCalendarTheme(
          selectedDayButtonTextStyle: TextStyle(color: AppColors.white),
          dayButtonTextStyle: TextStyle(color: AppColors.white),
          dayButtonOutsideMonthTextStyle: TextStyle(color: Colors.white38),
          weekdaysTextStyle: TextStyle(color: Colors.white70),
          headerTextStyle: TextStyle(
              color: AppColors.white, fontWeight: FontWeight.w600),
        ),
        textTheme: ShadTextTheme(
          family: GoogleFonts.robotoCondensed().fontFamily!,
        ),
      );
}
