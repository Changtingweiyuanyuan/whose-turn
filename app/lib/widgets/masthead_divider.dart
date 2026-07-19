import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'app_svg_icons.dart';
import 'dashed_rule.dart';

/// 刊頭裝飾分隔線：5 朵花之間以 2px 橘色虛線相連（gap 12）。
class MastheadDivider extends StatelessWidget {
  const MastheadDivider({super.key});

  static const _flowers = 5;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < _flowers; i++) ...[
          if (i > 0) ...[
            const SizedBox(width: 12),
            const Expanded(
              child: DashedRule(color: AppColors.orangeLine, thickness: 2),
            ),
            const SizedBox(width: 12),
          ],
          const AppAssetIcon('assets/icons/flower.svg', size: 20),
        ],
      ],
    );
  }
}
