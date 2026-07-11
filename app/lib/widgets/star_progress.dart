import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// ⭐⭐⭐☆☆　3 / 5
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
    // 星星最多畫 5 顆，超過 5 次的任務以比例呈現
    final totalStars = required.clamp(1, 5);
    final filledStars =
        required <= 5 ? confirmed : (confirmed * totalStars / required).floor();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < totalStars; i++)
          Icon(
            i < filledStars ? Icons.star_rounded : Icons.star_outline_rounded,
            size: size,
            color: i < filledStars ? AppColors.yellow : AppColors.starEmpty,
          ),
        if (showCount) ...[
          const SizedBox(width: 6),
          Text(
            '$confirmed / $required',
            style: TextStyle(
              fontSize: size * 0.75,
              fontWeight: FontWeight.w700,
              color: AppColors.navySoft,
            ),
          ),
        ],
      ],
    );
  }
}
