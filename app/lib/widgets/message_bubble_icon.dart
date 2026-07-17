import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// 全站共用的 message-bubble（Iconsax broken 樣式）icon。
///
/// 直接內嵌官方 SVG，顏色透過 [color] 以 srcIn 濾鏡上色。
/// LINE 綁定按鈕與底部導覽「訊息」共用同一顆，確保造型一致。
class MessageBubbleIcon extends StatelessWidget {
  const MessageBubbleIcon({super.key, required this.color, this.size = 24});

  final Color color;
  final double size;

  static const _svg =
      '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" '
      'viewBox="0 0 24 24" fill="none">'
      '<path d="M8.5 10.5H15.5" stroke="#ffffff" stroke-width="1.5" '
      'stroke-miterlimit="10" stroke-linecap="round" stroke-linejoin="round"/>'
      '<path d="M2 11.5597V13.4297C2 16.4297 4 18.4297 7 18.4297H11L15.45 '
      '21.3897C16.11 21.8297 17 21.3597 17 20.5597V18.4297C20 18.4297 22 '
      '16.4297 22 13.4297V7.42969C22 4.42969 20 2.42969 17 2.42969H7C4 2.42969 '
      '2 4.42969 2 7.42969" stroke="#ffffff" stroke-width="1.5" '
      'stroke-miterlimit="10" stroke-linecap="round" stroke-linejoin="round"/>'
      '</svg>';

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      _svg,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
