import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../widgets/app_close_icon.dart';
import 'app_colors.dart';
import 'app_tokens.dart';

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
    // 主色粉紅（主要按鈕、日曆選中日）
    primary: AppColors.pink,
    primaryForeground: AppColors.white,
    // secondary＝日曆「今天」底色（ink），文字白
    secondary: AppColors.ink,
    secondaryForeground: AppColors.white,
    muted: AppColors.lightGray,
    mutedForeground: AppColors.inkSoft,
    // hover surface 用半透明白（與「放棄任務」ghost hover 一致）
    accent: Color(0x14FFFFFF), // white ~8%
    accentForeground: AppColors.white,
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
        // Toast：F3F3F3 底 + 1px 橘線邊框 + Ink 字
        primaryToastTheme: ShadToastTheme(
          backgroundColor: const Color(0xFFF3F3F3),
          radius: BorderRadius.circular(6),
          border: ShadBorder.all(
            color: AppColors.orangeLine,
            width: 1,
            radius: BorderRadius.circular(6),
          ),
          descriptionStyle: const TextStyle(color: AppColors.ink),
          shadows: const [],
          // 右上角 X 對齊 modal：AppCloseIcon 22 @ top20 right20
          closeIcon: const AppCloseIcon(),
          closeIconPosition: const ShadPosition(top: 20, right: 20),
        ),
        // 全站彈窗（dialog / alert）統一 inkSoft 邊框
        primaryDialogTheme: ShadDialogTheme(
          border: Border.all(color: AppColors.inkSoft, width: 1),
        ),
        alertDialogTheme: ShadDialogTheme(
          border: Border.all(color: AppColors.inkSoft, width: 1),
        ),
        // Input：diluteInk 深底 + 白字（深色頁面上一致）
        inputTheme: const ShadInputTheme(
          decoration: ShadDecoration(color: AppColors.diluteInk),
          style: TextStyle(color: AppColors.white),
          placeholderStyle: TextStyle(color: Colors.white54),
          cursorColor: AppColors.white,
          cursorWidth: 1,
        ),
        // Outline 前景白（日曆左右導覽箭頭）；白底彈窗上的 outline 按鈕另行指定 ink
        outlineButtonTheme: const ShadButtonTheme(
          foregroundColor: AppColors.white,
        ),
        // 誰都可以接開關：開=pink、關=pinkSoft、把手白
        switchTheme: const ShadSwitchTheme(
          thumbColor: AppColors.white,
          checkedTrackColor: AppColors.pink,
          uncheckedTrackColor: AppColors.main,
        ),
        // 日曆：深底白字（配合 popover 深色）
        calendarTheme: const ShadCalendarTheme(
          selectedDayButtonTextStyle: TextStyle(color: AppColors.white),
          dayButtonTextStyle: TextStyle(color: AppColors.white),
          dayButtonOutsideMonthTextStyle: TextStyle(color: Colors.white38),
          weekdaysTextStyle: TextStyle(color: Colors.white70),
          headerTextStyle: TextStyle(
              color: AppColors.white, fontWeight: FontWeight.w600, letterSpacing: AppType.spacingBold),
        ),
        textTheme: ShadTextTheme(
          family: GoogleFonts.robotoCondensed().fontFamily!,
        ),
      );
}
