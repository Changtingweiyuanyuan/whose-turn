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
  /// 頁級標題：刊頭大標、彈窗/sheet 標題、慶祝副標
  static const title = 20.0;
  static const cardTitle = 16.0;
  static const body = 16.0;
  static const label = 14.0;
  static const kicker = 13.0;

  /// 全站字距：一般字重（w500 以下），theme 層預設套用
  static const spacing = 0.8;

  /// 全站字距：粗體（w600 以上），inline TextStyle 需明確帶上
  static const spacingBold = 1.2;
}
