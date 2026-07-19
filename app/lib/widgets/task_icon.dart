import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'app_svg_icons.dart';

/// 任務圖示 —— 值可以是 emoji（如 '🍵'）或線稿圖示（如 'asset:trash'）。
/// 'asset:xxx' → 顯示 assets/icons/xxx.svg（Streamline Freehand duotone，
/// 主線 #010101、次色換成主綠 #23965C）；否則當 emoji 顯示。
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
      return AppAssetIcon('assets/icons/$name.svg',
          size: size, accentColor: AppColors.green);
    }
    return Text(icon, style: TextStyle(fontSize: size * 0.9));
  }
}
