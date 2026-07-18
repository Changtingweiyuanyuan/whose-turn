import 'package:flutter/material.dart';

import 'app_svg_icons.dart';

/// 使用者頭像 —— 值可為 emoji（如 '🐱'）或個人圖示（如 'asset:smiley_happy'）。
///
/// `asset:xxx` → `assets/icons/xxx.svg`，以 [color] 上色（Streamline Freehand
/// 原色為近白，深底可不填、淺底請給 ink）；否則當 emoji 顯示。
class PersonAvatar extends StatelessWidget {
  const PersonAvatar(this.avatar,
      {this.size = 24, this.color, this.fillColor, super.key});

  final String avatar;
  final double size;
  final Color? color;

  /// 白／淺底請帶 ink，讓近白填色（#f7f7f7）不至於隱形；深底不帶。
  final Color? fillColor;

  static const _assetPrefix = 'asset:';

  bool get isAsset => avatar.startsWith(_assetPrefix);

  @override
  Widget build(BuildContext context) {
    if (isAsset) {
      final name = avatar.substring(_assetPrefix.length);
      return AppAssetIcon('assets/icons/$name.svg',
          color: color, fillColor: fillColor, size: size);
    }
    return Text(avatar, style: TextStyle(fontSize: size * 0.9));
  }
}
