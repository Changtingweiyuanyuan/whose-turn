import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../theme/app_colors.dart';
import 'app_svg_icons.dart';

/// AppBar 返回鍵：有上一頁就返回，沒有（深層連結、重新整理）就回任務看板。
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.color});

  /// 箭頭顏色；深色頁面傳白色。預設白色。
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? AppColors.white;
    return ShadButton.ghost(
      foregroundColor: color,
      hoverForegroundColor: color,
      hoverBackgroundColor: Colors.transparent,
      pressedBackgroundColor: Colors.transparent,
      onPressed: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/');
        }
      },
      child: AppSvgIcon(kArrowBackSvg, color: iconColor, size: 22),
    );
  }
}
