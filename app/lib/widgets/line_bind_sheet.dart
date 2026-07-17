import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../state/providers.dart';
import '../theme/app_colors.dart';
import 'app_close_icon.dart';

// Iconsax message-bubble（broken 樣式）—— 直接用官方 SVG，最精準
const _bubbleSvg =
    '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" '
    'viewBox="0 0 24 24" fill="none">'
    '<path d="M8.5 10.5H15.5" stroke="#ffffff" stroke-width="1.5" '
    'stroke-miterlimit="10" stroke-linecap="round" stroke-linejoin="round"/>'
    '<path d="M2 11.5597V13.4297C2 16.4297 4 18.4297 7 18.4297H11L15.45 '
    '21.3897C16.11 21.8297 17 21.3597 17 20.5597V18.4297C20 18.4297 22 16.4297 '
    '22 13.4297V7.42969C22 4.42969 20 2.42969 17 2.42969H7C4 2.42969 2 4.42969 '
    '2 7.42969" stroke="#ffffff" stroke-width="1.5" stroke-miterlimit="10" '
    'stroke-linecap="round" stroke-linejoin="round"/></svg>';

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
            leading: SvgPicture.string(
              _bubbleSvg,
              width: 20,
              height: 20,
              colorFilter:
                  const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
            ),
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
