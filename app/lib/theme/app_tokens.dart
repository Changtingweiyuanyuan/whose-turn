/// 共用設計 token —— 間距 / 圓角 / 字級。
/// 顏色見 app_colors.dart。編輯排版風：大字級、寬留白、銳利小圓角。
abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;

  /// 頁面左右邊界
  static const pagePadding = 20.0;

  /// 底部導覽 + FAB 讓出的空間
  static const bottomNavClearance = 96.0;
}

abstract final class AppRadius {
  static const chip = 6.0;
  static const card = 8.0;
  static const squircle = 20.0;
}

abstract final class AppType {
  /// 刊頭大標（今天換誰？）
  static const display = 40.0;
  static const heading = 26.0;
  static const cardTitle = 22.0;
  static const body = 15.0;
  static const label = 13.0;
  static const kicker = 12.0;
}
