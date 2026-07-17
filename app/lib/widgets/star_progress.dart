import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'app_svg_icons.dart';

/// 星星進度 —— 已完成=粉色星星、未完成=淡藍帶斜線星星（Iconsax broken）。
/// 次數 ≤ 8：一顆一星；次數 > 8：分段條 ████░░ 7/20，維持精確比例。
class StarProgress extends StatelessWidget {
  const StarProgress({
    super.key,
    required this.confirmed,
    required this.required,
    this.size = 18,
  });

  final int confirmed;
  final int required;
  final double size;

  @override
  Widget build(BuildContext context) {
    // 進度條情境：顯示 confirmed/required（完成次數 18px），與條間距 8px
    if (required > 8) {
      return _SegmentBar(
        confirmed: confirmed,
        required: required,
        height: 8,
        trailing: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text.rich(
            TextSpan(
              children: [
                // 已完成次數：粗體 16px
                TextSpan(
                  text: '$confirmed',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                // /總數：正常字重與大小
                TextSpan(
                  text: '/$required',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 星星情境：不顯示 0/1 次數
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < required; i++)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: i < confirmed
                ? AppSvgIcon(kStarSvg, color: AppColors.pink, size: size)
                : AppSvgIcon(kStarSlashSvg, color: AppColors.main, size: size),
          ),
      ],
    );
  }
}

class _SegmentBar extends StatelessWidget {
  const _SegmentBar({
    required this.confirmed,
    required this.required,
    required this.height,
    this.trailing,
  });

  final int confirmed;
  final int required;
  final double height;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 120,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Row(
              children: [
                Expanded(
                  flex: confirmed,
                  child: Container(height: height, color: AppColors.pink),
                ),
                Expanded(
                  flex: (required - confirmed).clamp(0, required),
                  child: Container(height: height, color: AppColors.pinkSoft),
                ),
              ],
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}
