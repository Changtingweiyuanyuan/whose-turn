import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../state/providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import 'app_close_icon.dart';
import 'app_svg_icons.dart';
import 'dashed_rule.dart';
import 'message_bubble_icon.dart';

/// 訪客 gate：建立群組 / 發起任務前必須綁定 LINE。
/// 回傳 true 表示已完成綁定，呼叫端可繼續原本的動作。
Future<bool> showLineBindSheet(BuildContext context, WidgetRef ref) async {
  final bound = await showShadSheet<bool>(
    context: context,
    side: ShadSheetSide.bottom,
    builder: (sheetContext) => ShadSheet(
      // 同任務詳情列的背景色
      backgroundColor: const Color(0xFFF3F3F3),
      radius: const BorderRadius.vertical(top: Radius.circular(8)),
      border: const Border(
        top: BorderSide(color: AppColors.green, width: 1.5),
      ),
      closeIcon: const AppCloseIcon(),
      closeIconPosition: const ShadPosition(top: 20, right: 20),
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppAssetIcon(
            'assets/icons/cloud_phone.svg',
            fillColor: AppColors.ink,
            size: 60,
          ),
          const SizedBox(height: 16),
          // 標題：LINE 愛心綠強調
          const Text.rich(
            TextSpan(
              style: TextStyle(
                fontSize: AppType.title,
                fontWeight: FontWeight.w600, letterSpacing: AppType.spacingBold,
                color: AppColors.ink,
                height: 1.2,
              ),
              children: [
                TextSpan(text: '先綁定 '),
                TextSpan(
                    text: 'LINE', style: TextStyle(color: AppColors.green)),
                TextSpan(text: ' 再繼續'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const DashedRule(color: AppColors.inkSoft),
          const SizedBox(height: 12),
          // 內文：永久保存 紅色強調
          const Text.rich(
            TextSpan(
              style: TextStyle(
                fontSize: AppType.label,
                color: AppColors.inkSoft,
                height: 1.5,
              ),
              children: [
                TextSpan(text: '建立群組和發起任務需要綁定帳號，\n你的星星和紀錄也會'),
                TextSpan(
                  text: '永久保存',
                  style: TextStyle(
                    color: AppColors.red,
                    fontWeight: FontWeight.w600,
                    letterSpacing: AppType.spacingBold,
                  ),
                ),
                TextSpan(text: '、不怕換手機。'),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // 兩顆 CTA 同一 row：次要在左、主要在右（對齊任務詳情）
          Row(
            children: [
              Expanded(
                child: ShadButton(
                  backgroundColor: AppColors.bg,
                  foregroundColor: AppColors.green,
                  hoverBackgroundColor: AppColors.greenSoft,
                  hoverForegroundColor: AppColors.green,
                  decoration: ShadDecoration(
                      border:
                          ShadBorder.all(color: AppColors.green, width: 1)),
                  onPressed: () => Navigator.of(sheetContext).pop(false),
                  child: const Text('下次再說'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ShadButton(
                  backgroundColor: AppColors.green,
                  foregroundColor: AppColors.bg,
                  hoverBackgroundColor: AppColors.greenDark,
                  hoverForegroundColor: AppColors.bg,
                  leading:
                      const MessageBubbleIcon(color: AppColors.white, size: 20),
                  onPressed: () async {
                    await ref.read(repositoryProvider).bindLine();
                    if (sheetContext.mounted) {
                      Navigator.of(sheetContext).pop(true);
                    }
                  },
                  child: const Text('用 LINE 綁定'),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
  return bound ?? false;
}
