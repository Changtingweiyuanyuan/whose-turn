import 'package:flutter/material.dart';

import '../models/task.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

/// 獎勵標籤 —— 帶邊框的圓角膠囊（邊框 diluteInk）。
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.white, // 底：白，讓文字清楚
        borderRadius: BorderRadius.circular(999), // 膠囊
        border: Border.all(color: AppColors.diluteInk, width: 1),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: AppType.kicker,
          fontWeight: FontWeight.w600,
          letterSpacing: AppType.spacingBold,
          color: AppColors.ink, // 文字：墨黑
        ),
      ),
    );
  }
}
