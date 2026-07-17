import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// 通用：把內嵌 Iconsax SVG 字串以指定顏色渲染（srcIn 上色）。
/// 用於底部導覽等需要 broken/twotone 樣式（flutter 套件未提供）的地方。
class AppSvgIcon extends StatelessWidget {
  const AppSvgIcon(this.svg, {required this.color, this.size = 24, super.key});

  final String svg;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      svg,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}

/// Iconsax `task`（broken）—— 清單打勾，用於「我的任務」。
const kTaskListSvg =
    '<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">'
    '<path stroke="#ffffff" stroke-linecap="round" stroke-linejoin="round" '
    'stroke-width="1.5" d="M11 19.5h10M20 12.5h1M11 12.5h5.49M11 5.5h10M3 5.5l1 '
    '1 3-3M3 12.5l1 1 3-3M3 19.5l1 1 3-3"/></svg>';

/// Iconsax `setting-2`（broken）—— 齒輪，用於「個人設定」。
const kSettingsSvg =
    '<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">'
    '<path stroke="#ffffff" stroke-linecap="round" stroke-linejoin="round" '
    'stroke-miterlimit="10" stroke-width="1.5" d="M15 12c0-1.66-1.34-3-3-3s-3 '
    '1.34-3 3a2.996 2.996 0 004.17 2.76"/>'
    '<path stroke="#ffffff" stroke-linecap="round" stroke-linejoin="round" '
    'stroke-miterlimit="10" stroke-width="1.5" d="M6.88 20.58l1.09.63c.79.47 '
    '1.81.19 2.28-.6l.11-.19c.9-1.57 2.38-1.57 3.29 0l.11.19c.47.79 1.49 1.07 '
    '2.28.6l1.73-.99c.91-.52 1.22-1.69.7-2.59-.91-1.57-.17-2.85 1.64-2.85 1.04 '
    '0 1.9-.85 1.9-1.9v-1.76c0-1.04-.85-1.9-1.9-1.9-1.01 0-1.69-.4-1.93-1.03-.19'
    '-.49-.11-1.13.29-1.82.52-.91.21-2.07-.7-2.59l-.81-.46M13.64 3.58c-.9 '
    '1.57-2.38 1.57-3.29 0l-.11-.19a1.655 1.655 0 00-2.27-.6l-1.73.99c-.91.52'
    '-1.22 1.69-.7 2.6.91 1.56.17 2.84-1.64 2.84-1.04 0-1.9.85-1.9 1.9v1.76c0 '
    '1.04.85 1.9 1.9 1.9 1.81 0 2.55 1.28 1.64 2.85"/></svg>';
