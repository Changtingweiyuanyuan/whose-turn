import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/providers.dart';
import '../theme/app_colors.dart';

/// 訪客 gate：建立群組 / 發起任務前必須綁定 LINE。
/// 回傳 true 表示已完成綁定，呼叫端可繼續原本的動作。
Future<bool> showLineBindSheet(BuildContext context, WidgetRef ref) async {
  final bound = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => Padding(
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
            style: TextStyle(fontSize: 14, color: AppColors.navySoft),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF06C755), // LINE 品牌綠
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () async {
                await ref.read(repositoryProvider).bindLine();
                if (sheetContext.mounted) {
                  Navigator.of(sheetContext).pop(true);
                }
              },
              icon: const Icon(Icons.chat_bubble_rounded, size: 20),
              label: const Text('用 LINE 綁定'),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.of(sheetContext).pop(false),
            child: const Text(
              '下次再說',
              style: TextStyle(color: AppColors.navySoft),
            ),
          ),
        ],
      ),
    ),
  );
  return bound ?? false;
}
