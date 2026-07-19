import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import 'app_svg_icons.dart';

/// 雜誌刊頭：WHOSE TURN TODAY / NO.xx + 粉色分隔線 + 大標題。
/// [starTotal] 為 null 時右側不顯示星星；[userNo] 為 null（未加入群組）時不顯示編號。
class AppMasthead extends StatelessWidget {
  const AppMasthead({
    super.key,
    required this.title,
    required this.userNo,
    this.starTotal,
  });

  final String title;
  final int? userNo;
  final int? starTotal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.pagePadding, AppSpacing.md, AppSpacing.pagePadding, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'WHOSE TURN TODAY',
                  style: TextStyle(
                    fontSize: AppType.kicker,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 3,
                    color: AppColors.greenPale,
                  ),
                ),
              ),
              if (userNo != null)
                Text(
                  'NO.${userNo.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: AppType.body,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    color: AppColors.green,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            height: 2,
            decoration: BoxDecoration(
              color: AppColors.orangeLine,
              borderRadius: BorderRadius.circular(2), // 對齊選中 tab 底線
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: AppType.title,
                    height: 1.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.green,
                  ),
                ),
              ),
              if (starTotal != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AppSvgIcon(kStarSvg,
                        color: AppColors.orange, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      '$starTotal',
                      style: const TextStyle(
                          fontSize: AppType.title,
                          fontWeight: FontWeight.w800,
                          color: AppColors.inkSoft),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
