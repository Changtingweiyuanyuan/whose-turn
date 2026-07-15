import 'package:flutter/material.dart';

import '../models/task.dart';
import '../theme/app_colors.dart';

/// 獎勵標籤 —— 粉色收藏藥丸，左側小圖標。
/// 神秘獎勵未揭曉時顯示「神秘禮物」。hover 不變色。
class RewardBadge extends StatelessWidget {
  const RewardBadge({super.key, required this.task, required this.viewerUid});

  final Task task;
  final String viewerUid;

  @override
  Widget build(BuildContext context) {
    final label = task.rewardLabelFor(viewerUid);
    final (glyph, text) = switch (task.rewardType) {
      RewardType.mystery => ('🎁', label == '???' ? '神秘禮物' : label),
      RewardType.money => ('＄', label),
      _ => ('🎀', label),
    };

    return Container(
      padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
      decoration: BoxDecoration(
        color: AppColors.pink,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: Text(glyph, style: const TextStyle(fontSize: 11)),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}
