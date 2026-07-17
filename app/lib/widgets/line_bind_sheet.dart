import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../state/providers.dart';
import '../theme/app_colors.dart';
import 'app_close_icon.dart';
import 'dashed_rule.dart';
import 'message_bubble_icon.dart';

/// 訪客 gate：建立群組 / 發起任務前必須綁定 LINE。
/// 回傳 true 表示已完成綁定，呼叫端可繼續原本的動作。
Future<bool> showLineBindSheet(BuildContext context, WidgetRef ref) async {
  final bound = await showShadSheet<bool>(
    context: context,
    side: ShadSheetSide.bottom,
    builder: (sheetContext) => ShadSheet(
      backgroundColor: AppColors.diluteInk,
      radius: const BorderRadius.vertical(top: Radius.circular(8)),
      border: const Border(
        top: BorderSide(color: AppColors.pink, width: 1),
      ),
      closeIcon: const AppCloseIcon(color: AppColors.white, size: 22),
      closeIconPosition: const ShadPosition(top: 20, right: 20),
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/lock.png', height: 72),
          const SizedBox(height: 16),
          // 標題：LINE 粉色強調
          const Text.rich(
            TextSpan(
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
                height: 1.2,
              ),
              children: [
                TextSpan(text: '先綁定 '),
                TextSpan(text: 'LINE', style: TextStyle(color: AppColors.pink)),
                TextSpan(text: ' 再繼續'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const DashedRule(color: AppColors.pink),
          const SizedBox(height: 12),
          // 內文：永久保存 粉色強調
          const Text.rich(
            TextSpan(
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
                height: 1.5,
              ),
              children: [
                TextSpan(text: '建立群組和發起任務需要綁定帳號，\n你的星星和紀錄也會'),
                TextSpan(
                  text: '永久保存',
                  style: TextStyle(color: AppColors.pink),
                ),
                TextSpan(text: '、不怕換手機。'),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ShadButton(
            width: double.infinity,
            backgroundColor: AppColors.pink,
            foregroundColor: AppColors.white,
            leading: const MessageBubbleIcon(color: AppColors.white, size: 20),
            onPressed: () async {
              await ref.read(repositoryProvider).bindLine();
              if (sheetContext.mounted) {
                Navigator.of(sheetContext).pop(true);
              }
            },
            child: const Text('用 LINE 綁定'),
          ),
          const SizedBox(height: 8),
          // 次要 CTA：ink 底白字；hover 維持 ink 疊半透明白
          ShadButton(
            width: double.infinity,
            backgroundColor: AppColors.ink,
            foregroundColor: AppColors.white,
            hoverBackgroundColor: AppColors.inkHover,
            hoverForegroundColor: AppColors.white,
            onPressed: () => Navigator.of(sheetContext).pop(false),
            child: const Text('下次再說'),
          ),
        ],
      ),
    ),
  );
  return bound ?? false;
}
