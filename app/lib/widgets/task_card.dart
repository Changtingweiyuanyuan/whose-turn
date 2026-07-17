import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/app_user.dart';
import '../models/task.dart';
import '../theme/app_colors.dart';
import 'app_svg_icons.dart';
import '../theme/app_tokens.dart';
import 'reward_badge.dart';
import 'task_icon.dart';

/// 任務卡 —— 黑底雜誌風：藍/白輪替底色、次數右上角、動作右下角。
class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.viewer,
    required this.creator,
    this.backgroundColor = AppColors.white,
    this.onTap,
    this.onClaim,
  });

  final Task task;
  final AppUser viewer;
  final AppUser creator;
  final Color backgroundColor;
  final VoidCallback? onTap;
  final VoidCallback? onClaim;

  @override
  Widget build(BuildContext context) {
    final canClaim = task.canClaimBy(viewer.uid);

    return GestureDetector(
      onTap: onTap,
      child: ShadCard(
        backgroundColor: backgroundColor,
        radius: BorderRadius.circular(AppRadius.card),
        border: ShadBorder.none,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 左側插圖（emoji 或手繪圖）；與內容間距 12
            Padding(
              padding: const EdgeInsets.only(top: 2, right: 12),
              child: TaskIcon(icon: task.emoji, size: 44),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 標題 + 次數（右上角）
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          task.title,
                          style: const TextStyle(
                            fontSize: AppType.cardTitle,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _CountLabel(
                        confirmed: task.confirmedCount,
                        required: task.requiredCount,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs), // 標題↔發起人 4
                  Text.rich(
                    TextSpan(
                      style: const TextStyle(
                          fontSize: AppType.label, color: AppColors.inkSoft),
                      children: [
                        const TextSpan(text: '發起人'),
                        TextSpan(
                          text: '：',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, color: AppColors.inkSoft),
                        ),
                        TextSpan(text: creator.displayName),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm), // 發起人↔獎勵 8
                  RewardBadge(task: task, viewerUid: viewer.uid),
                  const SizedBox(height: AppSpacing.xs), // 獎勵↔動作 8
                  // 動作（右下角）
                  Align(
                    alignment: Alignment.centerRight,
                    child: canClaim
                        ? ShadButton(
                            size: ShadButtonSize.sm,
                            backgroundColor: AppColors.ink,
                            foregroundColor: AppColors.white,
                            onPressed: onClaim,
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('我要接'),
                                SizedBox(width: 8),
                                AppSvgIcon(kArrowRightSvg,
                                    color: AppColors.white, size: 20),
                              ],
                            ),
                          )
                        : _StatusChip(task: task, viewerUid: viewer.uid),
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

/// 大號次數：3 大 / 5 小
class _CountLabel extends StatelessWidget {
  const _CountLabel({required this.confirmed, required this.required});

  final int confirmed;
  final int required;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '$confirmed',
          style: const TextStyle(
              fontSize: 26, fontWeight: FontWeight.w800, height: 1),
        ),
        Text(
          '/$required',
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.ink),
        ),
      ],
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
        ('進行中', const Color(0xFF9F353A)),
      TaskStatus.claimed => ('已被接走', AppColors.inkSoft),
      TaskStatus.completed => ('已完成', AppColors.ink),
      TaskStatus.rewardClaimed => ('獎勵已領', AppColors.inkSoft),
      TaskStatus.expired => ('已截止', AppColors.inkSoft),
      TaskStatus.cancelled => ('已取消', AppColors.inkSoft),
    };
    return Text(
      label,
      style: TextStyle(
          fontSize: AppType.label,
          // 「已被接走」較輕 w500，其餘 w600
          fontWeight:
              label == '已被接走' ? FontWeight.w500 : FontWeight.w600,
          color: color),
    );
  }
}
