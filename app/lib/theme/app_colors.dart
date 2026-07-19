import 'package:flutter/material.dart';

/// 品牌色票 v2 —— Prodigy 極簡 × 繽紛 Year-in-Review：
/// 背景 #F7F7F7、墨黑 #010101、主色 #C2D1D3、橘 #FF8B04、粉 #CF729B。
//#fef6b7

abstract final class AppColors {
  static const ink = Color(0xFF010101);
  /// ink + 8% 白：次要 CTA（ink 底）的 hover 疊層色
  static const inkHover = Color(0xFF151515);
  static const diluteInk = Color(0xFF222222);
  static const main = Color(0xFFC2D1D3);
  /// main 壓深版：藍色按鈕（邀請好友）的 hover 色
  static const mainDark = Color(0xFFA5B2B3);
  static const orange = Color(0xFFFF8B04);
  static const pink = Color(0xFFCF729B);
  // 已領取（不可再點）的實心暗粉色；雜訊底不用半透明
  static const pinkDark = Color(0xFF6E3F54);
  static const bg = Color(0xFFFDFBFC);
  static const white = Color(0xFFFFFFFF);

  // ---- v3 改版新色（綠色系；舊色保留至全面改版完成）----
  /// 主綠：愛心 FAB、選中態
  static const green = Color(0xFF23965C);
  /// 淺綠：底部導覽列底色
  static const greenSoft = Color(0xFFDBE7DB);
  /// 紙張底色（全站背景基底）
  static const paper = Color(0xFFFDFBFC);
  /// 紙張雜點色
  static const paperNoise = Color(0xFFF6F6EB);
  /// 畫面 1px 外框粉
  static const framePink = Color(0xFFE6CCD9);
  /// 淺粉線：資訊卡 1px 邊框（同 $ 符號色）
  static const pinkLight = Color(0xFFFAD3D7);
  /// 主綠壓深版：綠色 CTA 的 hover 底
  static const greenDark = Color(0xFF1D7A4B);
  /// 淡綠字：未選取分頁、星期、刊頭小標
  static const greenPale = Color(0xFF98B2A2);
  /// 更淡的綠：app bar 底色
  static const greenMist = Color(0xFFDEEDE4);
  /// 橘線：刊頭分隔線、選中分頁底線
  static const orangeLine = Color(0xFFF2A375);
  /// 卡片輪替色（依序循環）
  static const cardCycle = [
    Color(0xFFFAF6EF),
    Color(0xFFF0F4F7),
    Color(0xFFF6F7F2),
    Color(0xFFF4F0F6),
    Color(0xFFFCF7E9),
  ];

  // 衍生色（柔和背景、輔助文字）
  static const inkSoft = Color(0xFF6F6F6F);
  static const mainSoft = Color(0xFFE6EDEE);
  static const pinkSoft = Color(0xFFF6E4EC);
  static const orangeSoft = Color(0xFFFFE9CD);
  static const lightGray = Color(0xFFE7E7E7);
  static const starEmpty = Color(0xFFD9D9D9);
}
