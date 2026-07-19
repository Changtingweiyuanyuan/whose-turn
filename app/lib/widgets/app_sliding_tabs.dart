import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

/// 分頁標籤（全站共用）：格子平均分佈。
/// 選中＝主綠 w600，文字底下墊一條淡綠 highlight（高 10、超出下 2 左右 4、圓角 6）。
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
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++)
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        if (i == selected)
                          Positioned(
                            left: -4,
                            right: -4,
                            bottom: -2,
                            height: 10,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.greenMist,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        Text(
                          labels[i],
                          style: TextStyle(
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
                      ],
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
                                fontWeight: FontWeight.w800,
                                letterSpacing: AppType.spacingBold,
                                color: AppColors.white)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
