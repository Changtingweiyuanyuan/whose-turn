import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../state/providers.dart';
import '../theme/app_colors.dart';
import 'app_close_icon.dart';
import 'message_bubble_icon.dart';

/// 訪客 gate：建立群組 / 發起任務前必須綁定 LINE。
/// 回傳 true 表示已完成綁定，呼叫端可繼續原本的動作。
Future<bool> showLineBindSheet(BuildContext context, WidgetRef ref) async {
  final bound = await showShadSheet<bool>(
    context: context,
    side: ShadSheetSide.bottom,
    builder: (sheetContext) => ShadSheet(
      backgroundColor: AppColors.diluteInk,
      radius: BorderRadius.zero,
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
          const _DashedRule(),
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
          ShadButton.ghost(
            width: double.infinity,
            foregroundColor: AppColors.white,
            hoverForegroundColor: AppColors.white,
            hoverBackgroundColor: AppColors.white.withValues(alpha: 0.08),
            onPressed: () => Navigator.of(sheetContext).pop(false),
            child: const Text('下次再說'),
          ),
        ],
      ),
    ),
  );
  return bound ?? false;
}

/// 粉色虛線分隔線（與標題同寬）。
class _DashedRule extends StatelessWidget {
  const _DashedRule();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 1,
      width: double.infinity,
      child: CustomPaint(painter: _DashedPainter()),
    );
  }
}

class _DashedPainter extends CustomPainter {
  const _DashedPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const dash = 6.0, gap = 4.0;
    final paint = Paint()
      ..color = AppColors.pink
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    double x = 0;
    final y = size.height / 2;
    while (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset(x + dash, y), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedPainter oldDelegate) => false;
}
