import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// 全站統一的關閉（✕）icon。
///
/// 來源是 Iconsax broken 風格的「加號」SVG，旋轉 45° 後成為打叉造型，
/// 與排序選單的 broken 箭頭風格一致。顏色透過 [color] 以 srcIn 濾鏡上色，
/// 深色底傳白色、淺色底傳墨黑。
class AppCloseIcon extends StatelessWidget {
  const AppCloseIcon({super.key, required this.color, this.size = 22});

  final Color color;
  final double size;

  // Iconsax add / broken#fff（加號斷線版），旋轉 45° 當作 ✕ 使用。
  static const _svg = '''
<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none">
<path d="M12 18V6" stroke="#fff" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M16 12H18" stroke="#fff" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M6 12H11.66" stroke="#fff" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
</svg>''';

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: math.pi / 4, // 加號 +45° → ✕
      child: SvgPicture.string(
        _svg,
        width: size,
        height: size,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      ),
    );
  }
}
