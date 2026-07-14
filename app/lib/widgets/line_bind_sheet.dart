import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../state/providers.dart';
import '../theme/app_colors.dart';

/// 訪客 gate：建立群組 / 發起任務前必須綁定 LINE。
/// 回傳 true 表示已完成綁定，呼叫端可繼續原本的動作。
Future<bool> showLineBindSheet(BuildContext context, WidgetRef ref) async {
  final bound = await showShadSheet<bool>(
    context: context,
    side: ShadSheetSide.bottom,
    builder: (sheetContext) => ShadSheet(
      radius: const BorderRadius.vertical(top: Radius.circular(24)),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔒', style: TextStyle(fontSize: 44)),
          const SizedBox(height: 12),
          const Text(
            '先綁定 LINE 再繼續',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            '建立群組和發起任務需要綁定帳號，\n你的星星和紀錄也會永久保存、不怕換手機。',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.inkSoft),
          ),
          const SizedBox(height: 24),
          ShadButton(
            width: double.infinity,
            backgroundColor: const Color(0xFF06C755), // LINE 品牌綠
            leading: const Icon(Iconsax.message_copy, size: 18),
            onPressed: () async {
              await ref.read(repositoryProvider).bindLine();
              if (sheetContext.mounted) {
                Navigator.of(sheetContext).pop(true);
              }
            },
            child: const Text('用 LINE 綁定'),
          ),
          const SizedBox(height: 8),
          ShadButton.link(
            width: double.infinity,
            foregroundColor: AppColors.orange,
            onPressed: () => Navigator.of(sheetContext).pop(false),
            child: const Text('下次再說'),
          ),
        ],
      ),
    ),
  );
  return bound ?? false;
}
