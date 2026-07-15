import 'package:flutter/material.dart';

import '../models/task.dart';
import '../theme/app_colors.dart';

/// 獎勵標籤 —— 純文字粉色小標籤（radius 6，無圖標）。
/// 神秘獎勵未揭曉時顯示「神秘禮物」。hover 不變色。
class RewardBadge extends StatelessWidget {
  const RewardBadge({super.key, required this.task, required this.viewerUid});

  final Task task;
  final String viewerUid;

  @override
  Widget build(BuildContext context) {
    final label = task.rewardLabelFor(viewerUid);
    final text = task.isMystery && label == '???' ? '神秘禮物' : label;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.pink,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
      ),
    );
  }
}
