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

/// Iconsax `ai-homepage`（twotone）—— 房子 + 火花，用於「任務看板」。
const kHomeBoardSvg =
    '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" '
    'viewBox="0 0 24 24" fill="none">'
    '<path d="M22.28 6.90994L20.89 7.22994C19.9 7.45994 19.12 8.22994 18.89 '
    '9.22994L18.57 10.6199C18.54 10.7599 18.32 10.7599 18.29 10.6199L17.97 '
    '9.22994C17.74 8.23994 16.97 7.45994 15.97 7.22994L14.58 6.90994C14.44 '
    '6.87994 14.44 6.65994 14.58 6.62994L15.97 6.30994C16.96 6.07994 17.74 '
    '5.30994 17.97 4.30994L18.29 2.91994C18.32 2.77994 18.54 2.77994 18.57 '
    '2.91994L18.89 4.30994C19.12 5.29994 19.89 6.07994 20.89 6.30994L22.28 '
    '6.62994C22.42 6.65994 22.42 6.87994 22.28 6.90994Z" stroke="#ffffff" '
    'stroke-width="1.5" stroke-miterlimit="10"/>'
    '<path d="M14.46 3.02005C13.02 1.90005 10.99 1.90005 9.55001 3.02005L3.55001 '
    '7.69005C2.58001 8.45005 2.01001 9.61005 2.01001 10.8501V12.0004M22.01 '
    '10.8501V18.0001C22.01 20.2101 20.22 22.0001 18.01 22.0001H6.01001C3.80001 '
    '22.0001 2.01001 20.2101 2.01001 18.0001V16.5004" stroke="#ffffff" '
    'stroke-width="1.5" stroke-linecap="round"/>'
    '<path d="M12 15V18" stroke="#ffffff" stroke-width="1.5" '
    'stroke-linecap="round"/></svg>';

/// Iconsax `star`（broken 外框）—— 已完成的星星。
const kStarSvg =
    '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" '
    'viewBox="0 0 24 24" fill="none">'
    '<path d="M20.0999 8.61062C22.1399 8.95062 22.6199 10.4306 21.1499 '
    '11.8906L18.6699 14.3706C18.2499 14.7906 18.0199 15.6006 18.1499 '
    '16.1806L18.8599 19.2506C19.4199 21.6806 18.1299 22.6206 15.9799 '
    '21.3506L12.9899 19.5806C12.4499 19.2606 11.5599 19.2606 11.0099 '
    '19.5806L8.01991 21.3506C5.87991 22.6206 4.57991 21.6706 5.13991 '
    '19.2506L5.84991 16.1806C5.97991 15.6006 5.74991 14.7906 5.32991 '
    '14.3706L2.84991 11.8906C1.38991 10.4306 1.85991 8.95062 3.89991 '
    '8.61062L7.08991 8.08063C7.61991 7.99063 8.25991 7.52063 8.49991 '
    '7.03063L10.2599 3.51063C11.2099 1.60063 12.7699 1.60063 13.7299 '
    '3.51063L15.4899 7.03063C15.5899 7.24063 15.7699 7.45063 15.9799 7.62063" '
    'stroke="#ffffff" stroke-width="1.5" stroke-linecap="round" '
    'stroke-linejoin="round"/></svg>';

/// Iconsax `star-slash`（broken）—— 未完成的星星（帶斜線）。
const kStarSlashSvg =
    '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" '
    'viewBox="0 0 24 24" fill="none">'
    '<path d="M16.0502 7.67063C15.8102 7.49063 15.6102 7.26063 15.5002 '
    '7.03063L13.7402 3.51063C12.7902 1.60063 11.2302 1.60063 10.2702 '
    '3.51063L8.50016 7.03063C8.38016 7.28063 8.16016 7.51062 7.91016 7.70062" '
    'stroke="#ffffff" stroke-width="1.5" stroke-linecap="round" '
    'stroke-linejoin="round"/>'
    '<path d="M5.27991 18.6494L5.84991 16.1794C5.97991 15.5994 5.74991 14.7894 '
    '5.32991 14.3694L2.84991 11.8894C1.38991 10.4294 1.85991 8.94938 3.89991 '
    '8.60938" stroke="#ffffff" stroke-width="1.5" stroke-linecap="round" '
    'stroke-linejoin="round"/>'
    '<path d="M20.1 8.60938C22.14 8.94938 22.62 10.4294 21.15 11.8894L18.67 '
    '14.3694C18.25 14.7894 18.02 15.5994 18.15 16.1794L18.86 19.2494C19.42 '
    '21.6794 18.13 22.6194 15.98 21.3494L12.99 19.5794C12.45 19.2594 11.56 '
    '19.2594 11.01 19.5794L8.02002 21.3494" stroke="#ffffff" stroke-width="1.5" '
    'stroke-linecap="round" stroke-linejoin="round"/>'
    '<path d="M22 2L2 22" stroke="#ffffff" stroke-width="1.5" '
    'stroke-linecap="round" stroke-linejoin="round"/></svg>';
