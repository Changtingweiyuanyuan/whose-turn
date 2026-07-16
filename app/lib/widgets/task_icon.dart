import 'package:flutter/material.dart';

/// 任務圖示 —— 值可以是 emoji（如 '🍵'）或手繪圖檔（如 'asset:plate'）。
/// 'asset:xxx' → 顯示 assets/images/xxx.png（手繪線稿）；否則當 emoji 顯示。
class TaskIcon extends StatelessWidget {
  const TaskIcon({super.key, required this.icon, this.size = 44});

  final String icon;
  final double size;

  static const _assetPrefix = 'asset:';

  bool get isAsset => icon.startsWith(_assetPrefix);

  @override
  Widget build(BuildContext context) {
    if (isAsset) {
      final name = icon.substring(_assetPrefix.length);
      return Image.asset(
        'assets/images/$name.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
      );
    }
    return Text(icon, style: TextStyle(fontSize: size * 0.9));
  }
}
