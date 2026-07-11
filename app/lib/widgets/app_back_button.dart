import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// AppBar 返回鍵：有上一頁就返回，沒有（深層連結、重新整理）就回任務牆。
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadButton.ghost(
      onPressed: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/');
        }
      },
      child: const Icon(Iconsax.arrow_left_2_copy, size: 22),
    );
  }
}
