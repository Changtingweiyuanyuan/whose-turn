import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

/// 滑動底線分頁（全站共用）：格子平均分佈，選中底線在整條基線上滑動。
/// 選中＝主綠、未選＝淡綠、底線＝橘線。
class AppSlidingTabs extends StatelessWidget {
  const AppSlidingTabs({
    super.key,
    required this.labels,
    required this.selected,
    required this.onChanged,
    this.badgeIndex = -1,
    this.badgeCount = 0,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;
  final int badgeIndex;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final n = labels.length;
    // 選中格中心的對齊 x：0→-1, 中→0, 末→1
    final x = n == 1 ? 0.0 : -1.0 + 2.0 * selected / (n - 1);

    return Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < n; i++)
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(i),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          labels[i],
                          style: TextStyle(
                            fontSize: AppType.body,
                            fontWeight: i == selected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            letterSpacing: i == selected
                                ? AppType.spacingBold
                                : AppType.spacing,
                            color: i == selected
                                ? AppColors.green
                                : AppColors.inkSoft,
                          ),
                        ),
                        if (i == badgeIndex && badgeCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: const BoxDecoration(
                              color: AppColors.orange,
                              shape: BoxShape.circle,
                            ),
                            child: Text('$badgeCount',
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800, letterSpacing: AppType.spacingBold,
                                    color: AppColors.white)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        // 基線 + 滑動的橘色底線
        Stack(
          children: [
            Container(height: 1, color: AppColors.lightGray),
            AnimatedAlign(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              alignment: Alignment(x, 0),
              child: FractionallySizedBox(
                widthFactor: 1 / n,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: AppColors.orangeLine,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
