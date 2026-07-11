import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/app_user.dart';
import '../models/task.dart';
import '../theme/app_colors.dart';
import 'reward_badge.dart';
import 'star_progress.dart';

/// 任務牆卡片 —— 卡片很大、Reward 醒目。
class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.viewer,
    required this.creator,
    this.onTap,
    this.onClaim,
  });

  final Task task;
  final AppUser viewer;
  final AppUser creator;
  final VoidCallback? onTap;
  final VoidCallback? onClaim;

  @override
  Widget build(BuildContext context) {
    final canClaim = task.canClaimBy(viewer.uid);

    return GestureDetector(
      onTap: onTap,
      child: ShadCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TaskEmoji(emoji: task.emoji),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          task.title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      RewardBadge(task: task, viewerUid: viewer.uid),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '發起人：${creator.displayName}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.navySoft,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      StarProgress(
                        confirmed: task.confirmedCount,
                        required: task.requiredCount,
                      ),
                      const Spacer(),
                      if (canClaim)
                        ShadButton(
                          size: ShadButtonSize.sm,
                          onPressed: onClaim,
                          child: const Text('我要接'),
                        )
                      else
                        _StatusChip(task: task, viewerUid: viewer.uid),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskEmoji extends StatelessWidget {
  const _TaskEmoji({required this.emoji});

  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: const BoxDecoration(
        color: AppColors.cream,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(emoji, style: const TextStyle(fontSize: 26)),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.task, required this.viewerUid});

  final Task task;
  final String viewerUid;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (task.status) {
      TaskStatus.open when task.createdBy == viewerUid => ('等人接單', AppColors.navySoft),
      TaskStatus.open => ('指定任務', AppColors.navySoft),
      TaskStatus.claimed when task.claimedBy == viewerUid => ('進行中', AppColors.pink),
      TaskStatus.claimed => ('已被接走', AppColors.navySoft),
      TaskStatus.completed => ('已完成', AppColors.yellow),
      TaskStatus.rewardClaimed => ('獎勵已領', AppColors.navySoft),
      TaskStatus.expired => ('已截止', AppColors.navySoft),
      TaskStatus.cancelled => ('已取消', AppColors.navySoft),
    };
    return Text(
      label,
      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color),
    );
  }
}
