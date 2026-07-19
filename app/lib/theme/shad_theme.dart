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
    // 彈出層（select 選項、日曆）淡灰底 Ink 字
    popover: Color(0xFFF3F3F3),
    popoverForeground: AppColors.ink,
    // 主色愛心綠（日曆選中日）
    primary: AppColors.green,
    primaryForeground: AppColors.white,
    // secondary＝日曆「今天」底色（淡綠），文字 Ink
    secondary: AppColors.greenMist,
    secondaryForeground: AppColors.ink,
    muted: AppColors.lightGray,
    mutedForeground: AppColors.inkSoft,
    // hover surface：淡灰底上用半透明黑
    accent: Color(0x0F000000), // black ~6%
    accentForeground: AppColors.ink,
    destructive: Color(0xFFC0392B),
    destructiveForeground: AppColors.white,
    border: AppColors.lightGray,
    input: AppColors.lightGray,
    ring: AppColors.green,
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
        // Toast：紙白底 + 1px softInk 邊框 + Ink 字
        primaryToastTheme: ShadToastTheme(
          backgroundColor: AppColors.bg,
          radius: BorderRadius.circular(6),
          border: ShadBorder.all(
            color: AppColors.inkSoft,
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
        // Input：任務詳情列同款 F3F3F3 淺底 + Ink 字；focus 1.5px 愛心綠框
        inputTheme: ShadInputTheme(
          decoration: ShadDecoration(
            color: const Color(0xFFF3F3F3),
            // focus 內框維持原本灰色
            focusedBorder: ShadBorder.all(
              color: AppColors.lightGray,
              width: 1,
              radius: BorderRadius.circular(6),
            ),
            // focus 外圈改淡綠 1.5px
            secondaryFocusedBorder: ShadBorder.all(
              color: AppColors.greenMist,
              width: 1.5,
              radius: BorderRadius.circular(8),
            ),
          ),
          style: const TextStyle(color: AppColors.ink),
          placeholderStyle: const TextStyle(color: AppColors.inkSoft),
          cursorColor: AppColors.ink,
          cursorWidth: 1,
        ),
        // Outline 前景 Ink（日曆左右導覽箭頭）
        outlineButtonTheme: const ShadButtonTheme(
          foregroundColor: AppColors.ink,
        ),
        // 誰都可以接開關：開=愛心綠、把手白
        switchTheme: const ShadSwitchTheme(
          thumbColor: AppColors.white,
          checkedTrackColor: AppColors.green,
          uncheckedTrackColor: AppColors.main,
        ),
        // 日曆：淡灰底 Ink 字（配合 popover 淺色）
        calendarTheme: const ShadCalendarTheme(
          selectedDayButtonTextStyle: TextStyle(color: AppColors.white),
          dayButtonTextStyle: TextStyle(color: AppColors.ink),
          dayButtonOutsideMonthTextStyle: TextStyle(color: AppColors.inkSoft),
          weekdaysTextStyle: TextStyle(color: AppColors.inkSoft),
          headerTextStyle: TextStyle(
              color: AppColors.ink, fontWeight: FontWeight.w600, letterSpacing: AppType.spacingBold),
        ),
        textTheme: ShadTextTheme(
          family: GoogleFonts.robotoCondensed().fontFamily!,
        ),
      );
}
