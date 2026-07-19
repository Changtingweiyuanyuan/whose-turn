import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/task.dart';
import '../state/providers.dart';
import '../widgets/app_back_button.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../widgets/app_svg_icons.dart';
import '../widgets/noise_background.dart';
import '../widgets/person_avatar.dart';
import '../widgets/star_progress.dart';
import '../widgets/task_icon.dart';

class TaskDetailScreen extends ConsumerWidget {
  const TaskDetailScreen({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(repositoryProvider);
    final task = repo.tasks.where((t) => t.id == taskId).firstOrNull;
    if (task == null) {
      return const Scaffold(body: Center(child: Text('任務不存在')));
    }

    final me = repo.currentUser;
    final creator = repo.userOf(task.createdBy);
    final isCreator = task.createdBy == me.uid;
    final isClaimant = task.claimedBy == me.uid;
    // 完成紀錄：待確認在最上面，其餘依時間新→舊
    final history = task.completions.toList()
      ..sort((a, b) {
        final aPending = a.status == CompletionStatus.pending ? 0 : 1;
        final bPending = b.status == CompletionStatus.pending ? 0 : 1;
        if (aPending != bPending) return aPending - bPending;
        return b.submittedAt.compareTo(a.submittedAt);
      });

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.greenMist,
        foregroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: true,
        leading: const AppBackButton(),
        title: const Text(
          '任務詳情',
          style: TextStyle(
            color: AppColors.inkSoft,
            fontSize: AppType.label,
            fontWeight: FontWeight.w600,
            letterSpacing: AppType.spacingBold,
          ),
        ),
      ),
      body: NoiseBackground(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pagePadding,
            24,
            AppSpacing.pagePadding,
            24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.ink, width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: TaskIcon(icon: task.emoji, size: 36),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  task.title,
                  // 詳情大標＝title（與卡片標題 cardTitle 脫鉤）
                  style: const TextStyle(
                    fontSize: AppType.title,
                    fontWeight: FontWeight.w600,
                    letterSpacing: AppType.spacingBold,
                    color: AppColors.green,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm), // 標題↔發起人 8
              Center(
                child: Text.rich(
                  TextSpan(
                    style: const TextStyle(
                      fontSize: AppType.label,
                      color: AppColors.inkSoft,
                    ),
                    children: [
                      const TextSpan(text: '發起人'),
                      const TextSpan(
                        text: '：',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          letterSpacing: AppType.spacingBold,
                          color: AppColors.inkSoft,
                        ),
                      ),
                      TextSpan(text: creator.displayName),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                // 1px 紋理邊框：同任務卡作法。
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/card_border.png'),
                    repeat: ImageRepeat.repeat,
                    fit: BoxFit.none,
                  ),
                ),
                child: ShadCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  radius: BorderRadius.circular(AppRadius.card - 1),
                  border: ShadBorder.none,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoRow(
                        label: '完成條件',
                        value: '${task.title} ${task.requiredCount} 次',
                      ),
                      const SizedBox(height: 8),
                      task.rewardLabelFor(me.uid) == '???'
                          ? const _InfoRow(
                              label: '獎勵內容',
                              valueChild: Row(
                                children: [
                                  Text(
                                    '神秘禮物',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: AppType.spacingBold,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  AppSvgIcon(
                                    kGiftSlashSvg,
                                    color: AppColors.ink,
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      '完成才知道',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: AppType.spacingBold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : task.rewardType == RewardType.money
                          ? _InfoRow(
                              label: '獎勵內容',
                              valueChild: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    task.rewardLabel,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: AppType.spacingBold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const AppSvgIcon(
                                    kCashSvg,
                                    color: AppColors.ink,
                                    size: 16,
                                  ),
                                ],
                              ),
                            )
                          : _InfoRow(
                              label: '獎勵內容',
                              value: task.rewardLabel,
                              valueWeight: FontWeight.w600,
                            ),
                      if (task.deadline != null) ...[
                        const SizedBox(height: 8),
                        _InfoRow(
                          label: '截止日期',
                          value: DateFormat(
                            'yyyy/MM/dd HH:mm',
                          ).format(task.deadline!),
                        ),
                      ],
                      if (task.assigneeUid != null) ...[
                        const SizedBox(height: 8),
                        _InfoRow(
                          label: '指定給',
                          value: repo.userOf(task.assigneeUid!).displayName,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const SizedBox(
                            width: _kInfoLabelWidth,
                            child: Text(
                              '進度',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: AppColors.inkSoft,
                              ),
                            ),
                          ),
                          const SizedBox(width: _kInfoLabelGap),
                          StarProgress(
                            confirmed: task.confirmedCount,
                            required: task.requiredCount,
                            size: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ---- 完成紀錄（唯一可捲動區；待確認可操作 + 歷史保留）----
              if (history.isNotEmpty) ...[
                Text(
                  '完成紀錄 (${history.length})',
                  style: const TextStyle(
                    fontSize: AppType.body,
                    fontWeight: FontWeight.w500,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      for (final (i, c) in history.indexed)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              // 與任務卡同一組四色輪替、無邊框
                              color: AppColors
                                  .cardCycle[i % AppColors.cardCycle.length],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                PersonAvatar(
                                  repo.userOf(c.userId).avatarEmoji,
                                  size: 26,
                                  fillColor: AppColors.ink,
                                  orangeColor: AppColors.green,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${repo.userOf(c.userId).displayName} 完成了一次',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.ink,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        DateFormat(
                                          'MM/dd HH:mm',
                                        ).format(c.submittedAt),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.inkSoft,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (c.status == CompletionStatus.pending &&
                                    isCreator)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // 退回 = 次要 CTA：ink 底、hover inkHover
                                      ShadButton(
                                        size: ShadButtonSize.sm,
                                        backgroundColor: AppColors.bg,
                                        foregroundColor: AppColors.green,
                                        hoverBackgroundColor:
                                            AppColors.greenSoft,
                                        hoverForegroundColor: AppColors.green,
                                        decoration: ShadDecoration(
                                          border: ShadBorder.all(
                                            color: AppColors.green,
                                            width: 1,
                                          ),
                                        ),
                                        onPressed: () => repo.rejectCompletion(
                                          task.id,
                                          c.id,
                                        ),
                                        child: const Text('退回'),
                                      ),
                                      const SizedBox(width: 8),
                                      // 確認 對齊「完成一次」：粉底白字
                                      ShadButton(
                                        size: ShadButtonSize.sm,
                                        backgroundColor: AppColors.green,
                                        foregroundColor: AppColors.bg,
                                        hoverBackgroundColor:
                                            AppColors.greenDark,
                                        hoverForegroundColor: AppColors.bg,
                                        onPressed: () => repo.confirmCompletion(
                                          task.id,
                                          c.id,
                                        ),
                                        child: const Text('確認'),
                                      ),
                                    ],
                                  )
                                else
                                  _CompletionStatusLabel(status: c.status),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ] else
                const Spacer(),
              const SizedBox(height: 16),

              // ---- 主要動作（固定底部）----
              ..._buildActions(
                context,
                ref,
                task,
                isCreator: isCreator,
                isClaimant: isClaimant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildActions(
    BuildContext context,
    WidgetRef ref,
    Task task, {
    required bool isCreator,
    required bool isClaimant,
  }) {
    final repo = ref.read(repositoryProvider);
    final me = repo.currentUser;

    // 與 LINE 綁定按鈕一致：粉底白字、預設尺寸與字級、預設 hover
    Widget primary(String label, Future<void> Function() onPressed) {
      return ShadButton(
        width: double.infinity,
        backgroundColor: AppColors.green,
        foregroundColor: AppColors.bg,
        hoverBackgroundColor: AppColors.greenDark,
        hoverForegroundColor: AppColors.bg,
        onPressed: () => onPressed(),
        child: Text(label),
      );
    }

    if (task.canClaimBy(me.uid)) {
      return [
        primary('我要接', () async {
          await repo.claimTask(task.id);
        }),
      ];
    }

    if (isClaimant && task.status == TaskStatus.claimed) {
      // 次要 CTA：ink 底白字；hover 維持 ink 疊半透明白
      final abandon = ShadButton(
        width: double.infinity,
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.green,
        hoverBackgroundColor: AppColors.greenSoft,
        hoverForegroundColor: AppColors.green,
        decoration: ShadDecoration(
          border: ShadBorder.all(color: AppColors.green, width: 1),
        ),
        onPressed: () => repo.abandonTask(task.id),
        child: const Text('放棄任務'),
      );

      // 已送出（等待確認＋已確認）達次數上限，不再顯示「完成一次」
      if (task.activeCount >= task.requiredCount) {
        return [abandon];
      }

      return [
        primary('完成一次', () async {
          await repo.submitCompletion(task.id);
          if (context.mounted) {
            ShadToaster.of(
              context,
            ).show(const ShadToast(description: Text('已送出，等待發起人確認')));
          }
        }),
        const SizedBox(height: 8),
        abandon,
      ];
    }

    if (isClaimant && task.status == TaskStatus.completed) {
      return [
        primary('領取獎勵', () async {
          await repo.claimReward(task.id);
          if (context.mounted) {
            ShadToaster.of(context).show(
              ShadToast(
                description: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: '🎉 恭喜完成！獎勵已解鎖'),
                      const TextSpan(
                        text: '：',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          letterSpacing: AppType.spacingBold,
                        ),
                      ),
                      TextSpan(text: task.rewardLabel),
                    ],
                  ),
                ),
              ),
            );
          }
        }),
      ];
    }

    if (isClaimant && task.status == TaskStatus.rewardClaimed) {
      // 已領取＝不可再點：實心暗粉色、hover 不變化（雜訊底不用半透明）
      return [
        ShadButton(
          width: double.infinity,
          backgroundColor: AppColors.pinkDark,
          foregroundColor: AppColors.white,
          hoverBackgroundColor: AppColors.pinkDark,
          hoverForegroundColor: AppColors.white,
          onPressed: () {},
          child: const Text('已領取獎勵'),
        ),
      ];
    }

    if (isCreator && task.status == TaskStatus.open) {
      return [
        ShadButton(
          width: double.infinity,
          backgroundColor: AppColors.bg,
          foregroundColor: AppColors.green,
          hoverBackgroundColor: AppColors.greenSoft,
          hoverForegroundColor: AppColors.green,
          decoration: ShadDecoration(
            border: ShadBorder.all(color: AppColors.green, width: 1),
          ),
          onPressed: () async {
            await repo.cancelTask(task.id);
            if (context.mounted) context.pop();
          },
          child: const Text('取消任務'),
        ),
      ];
    }

    return const [];
  }
}

class _CompletionStatusLabel extends StatelessWidget {
  const _CompletionStatusLabel({required this.status});

  final CompletionStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      CompletionStatus.pending => ('等待確認', AppColors.inkSoft),
      CompletionStatus.confirmed => ('已確認', AppColors.green),
      CompletionStatus.rejected => ('已退回', AppColors.inkSoft),
    };
    final text = Text(
      label,
      style: TextStyle(
        fontSize: AppType.kicker,
        fontWeight: FontWeight.w500,
        color: color,
      ),
    );
    if (status != CompletionStatus.confirmed) return text;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppSvgIcon(kStarSvg, color: AppColors.green, size: 15),
        const SizedBox(width: 4),
        text,
      ],
    );
  }
}

/// 標籤欄寬（4 個 16px 中文字 + 0.8 全站字距），value 與它固定間距 20px。
const double _kInfoLabelWidth = 72;
const double _kInfoLabelGap = 20;

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    this.value,
    this.valueChild,
    this.valueWeight = FontWeight.w500,
  }) : assert(value != null || valueChild != null);

  final String label;
  final String? value;

  /// 自訂 value 內容（如神秘禮物：文字+icon+文字），優先於 [value]。
  final Widget? valueChild;

  /// value 文字字重（預設 w500）
  final FontWeight valueWeight;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: _kInfoLabelWidth,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.inkSoft,
            ),
          ),
        ),
        const SizedBox(width: _kInfoLabelGap),
        Expanded(
          child:
              valueChild ??
              Text(value!, style: TextStyle(fontWeight: valueWeight)),
        ),
      ],
    );
  }
}
