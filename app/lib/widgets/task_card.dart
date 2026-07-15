import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/app_user.dart';
import '../models/task.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import 'reward_badge.dart';
import 'star_progress.dart';

/// 任務卡 —— 編輯海報式：非對稱、大字級、獎勵權重高、超大 emoji 當主視覺。
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
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 上緣：獎勵標籤壓在最醒目位置 + 超大 emoji
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.emoji,
                    style: const TextStyle(fontSize: 40, height: 1)),
                const Spacer(),
                RewardBadge(task: task, viewerUid: viewer.uid, large: true),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            // 任務名：大字，海報主標
            Text(
              task.title,
              style: const TextStyle(
                fontSize: AppType.cardTitle,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '發起人 ${creator.displayName}',
              style: const TextStyle(
                  fontSize: AppType.label, color: AppColors.inkSoft),
            ),
            const SizedBox(height: AppSpacing.md),
            // 底列：進度（集章）＋ 動作
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: StarProgress(
                    confirmed: task.confirmedCount,
                    required: task.requiredCount,
                    active: task.status == TaskStatus.claimed,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
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
      TaskStatus.open when task.createdBy == viewerUid =>
        ('等人接單', AppColors.inkSoft),
      TaskStatus.open => ('指定任務', AppColors.inkSoft),
      TaskStatus.claimed when task.claimedBy == viewerUid =>
        ('進行中', AppColors.pink),
      TaskStatus.claimed => ('已被接走', AppColors.inkSoft),
      TaskStatus.completed => ('已完成', AppColors.orange),
      TaskStatus.rewardClaimed => ('獎勵已領', AppColors.inkSoft),
      TaskStatus.expired => ('已截止', AppColors.inkSoft),
      TaskStatus.cancelled => ('已取消', AppColors.inkSoft),
    };
    return Text(
      label,
      style: TextStyle(
          fontSize: AppType.label, fontWeight: FontWeight.w800, color: color),
    );
  }
}
