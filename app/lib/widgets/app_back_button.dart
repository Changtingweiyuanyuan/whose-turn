import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// AppBar 返回鍵：有上一頁就返回，沒有（深層連結、重新整理）就回任務牆。
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.color});

  /// 箭頭顏色；深色頁面傳白色。預設用主題前景色。
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ShadButton.ghost(
      foregroundColor: color,
      onPressed: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/');
        }
      },
      child: Icon(Iconsax.arrow_left_2_copy, size: 22, color: color),
    );
  }
}
