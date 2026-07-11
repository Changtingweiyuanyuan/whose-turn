import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../theme/app_colors.dart';

/// 任務進度：次數 ≤ 5 用星星（⭐⭐⭐☆☆　3 / 5），
/// 次數 > 5 星星呈現不完整，改用進度條（▓▓▓░░░　7 / 20）。
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
        ? Text(
            '$confirmed / $required',
            style: TextStyle(
              fontSize: size * 0.75,
              fontWeight: FontWeight.w700,
              color: AppColors.navySoft,
            ),
          )
        : null;

    if (required > 5) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size * 5.3,
            child: ShadProgress(
              value: (confirmed / required).clamp(0.0, 1.0),
              minHeight: size * 0.45,
              color: AppColors.yellow,
              backgroundColor: AppColors.lightGray,
            ),
          ),
          if (countText != null) ...[const SizedBox(width: 6), countText],
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < required.clamp(1, 5); i++)
          Icon(
            i < confirmed ? Icons.star_rounded : Icons.star_outline_rounded,
            size: size,
            color: i < confirmed ? AppColors.yellow : AppColors.starEmpty,
          ),
        if (countText != null) ...[const SizedBox(width: 6), countText],
      ],
    );
  }
}
