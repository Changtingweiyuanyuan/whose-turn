import 'package:flutter/material.dart';

import '../models/task.dart';
import '../theme/app_colors.dart';

/// 獎勵標籤 —— 設計原則：Reward 醒目，不是 Task 醒目。
class RewardBadge extends StatelessWidget {
  const RewardBadge({super.key, required this.task, required this.viewerUid});

  final Task task;
  final String viewerUid;

  @override
  Widget build(BuildContext context) {
    final label = task.rewardLabelFor(viewerUid);
    final isMystery = task.isMystery && label == '???';
    final (bg, fg) = switch (task.rewardType) {
      RewardType.mystery => (AppColors.pink, AppColors.white),
      RewardType.money => (AppColors.yellow, AppColors.navy),
      _ => (AppColors.pinkSoft, AppColors.pink),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isMystery ? '🎁 ???' : label,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}
