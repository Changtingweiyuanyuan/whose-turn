import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/task.dart';
import '../theme/app_colors.dart';

/// 獎勵標籤 —— 設計原則：Reward 醒目，不是 Task 醒目。
/// hover 不變色、統一顯示文字；神秘獎勵未揭曉時顯示「神秘禮物」。
class RewardBadge extends StatelessWidget {
  const RewardBadge({super.key, required this.task, required this.viewerUid});

  final Task task;
  final String viewerUid;

  @override
  Widget build(BuildContext context) {
    final label = task.rewardLabelFor(viewerUid);
    final text = task.isMystery && label == '???' ? '神秘禮物' : label;
    final (bg, fg) = switch (task.rewardType) {
      RewardType.mystery => (AppColors.pink, AppColors.white),
      RewardType.money => (AppColors.orange, AppColors.ink),
      _ => (AppColors.main, AppColors.ink),
    };

    return ShadBadge(
      backgroundColor: bg,
      hoverBackgroundColor: bg,
      foregroundColor: fg,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      ),
    );
  }
}
