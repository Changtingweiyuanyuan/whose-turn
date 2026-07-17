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
    this.showCount = true,
  });

  final int confirmed;
  final int required;
  final double size;
  final bool showCount;

  @override
  Widget build(BuildContext context) {
    final countText = showCount
        ? Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              '$confirmed / $required',
              style: TextStyle(
                fontSize: size * 0.8,
                fontWeight: FontWeight.w500,
                color: AppColors.ink,
              ),
            ),
          )
        : null;

    if (required > 8) {
      return _SegmentBar(
        confirmed: confirmed,
        required: required,
        height: size * 0.5,
        trailing: countText,
      );
    }

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
        ?countText,
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
          width: height * 10,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Row(
              children: [
                Expanded(
                  flex: confirmed,
                  child: Container(height: height, color: AppColors.orange),
                ),
                Expanded(
                  flex: (required - confirmed).clamp(0, required),
                  child: Container(height: height, color: AppColors.lightGray),
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
