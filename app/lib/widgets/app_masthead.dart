import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import 'app_svg_icons.dart';
import 'masthead_divider.dart';

/// 雜誌刊頭：WHOSE TURN TODAY + 花花分隔線 + 大標題。
/// [starTotal] 為 null 時右側不顯示星星。
class AppMasthead extends StatelessWidget {
  const AppMasthead({
    super.key,
    required this.title,
    this.starTotal,
  });

  final String title;
  final int? starTotal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        AppSpacing.md,
        AppSpacing.pagePadding,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'WHOSE TURN TODAY',
            style: TextStyle(
              fontSize: AppType.kicker,
              fontWeight: FontWeight.w600,
              letterSpacing: 3,
              color: AppColors.green,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const MastheadDivider(),
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
                    letterSpacing: AppType.spacingBold,
                    color: AppColors.ink,
                  ),
                ),
              ),
              if (starTotal != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AppSvgIcon(kStarSvg, color: AppColors.red, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      '$starTotal',
                      // height 1.0 對齊標題行高，避免撐高刊頭（各頁 tab 位置才會一致）
                      style: const TextStyle(
                        fontSize: AppType.title,
                        height: 1.0,
                        fontWeight: FontWeight.w800,
                        letterSpacing: AppType.spacingBold,
                        color: AppColors.inkSoft,
                      ),
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
