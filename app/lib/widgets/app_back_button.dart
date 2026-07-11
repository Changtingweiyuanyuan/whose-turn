import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../theme/app_colors.dart';

/// AppBar 返回鍵：有上一頁就返回，沒有（深層連結、重新整理）就回任務牆。
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadButton.ghost(
      foregroundColor: AppColors.navy,
      onPressed: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/');
        }
      },
      child: const Icon(LucideIcons.arrowLeft, size: 22),
    );
  }
}
