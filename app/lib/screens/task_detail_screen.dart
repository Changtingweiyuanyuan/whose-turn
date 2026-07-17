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
      backgroundColor: AppColors.ink,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: const AppBackButton(color: AppColors.white),
        title: const Text('任務詳情',
            style: TextStyle(
                color: AppColors.pink,
                fontSize: AppType.body,
                fontWeight: FontWeight.w500)),
      ),
      body: NoiseBackground(
        child: ListView(
        padding: EdgeInsets.fromLTRB(
            24, MediaQuery.of(context).padding.top + kToolbarHeight + 8, 24, 32),
        children: [
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: TaskIcon(icon: task.emoji, size: 72),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              task.title,
              style: const TextStyle(
                fontSize: AppType.cardTitle,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Center(
            child: Text.rich(
              TextSpan(
                style: const TextStyle(
                    fontSize: AppType.label, color: AppColors.inkSoft),
                children: [
                  const TextSpan(text: '發起人'),
                  const TextSpan(
                    text: '：',
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: AppColors.inkSoft),
                  ),
                  TextSpan(text: creator.displayName),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ShadCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            border: ShadBorder.none,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(
                    label: '完成條件',
                    value: '${task.title} ${task.requiredCount} 次'),
                const SizedBox(height: 8),
                _InfoRow(
                  label: '獎勵內容',
                  value: task.rewardLabelFor(me.uid) == '???'
                      ? '神秘禮物，完成才揭曉'
                      : task.rewardLabel,
                ),
                if (task.deadline != null) ...[
                  const SizedBox(height: 8),
                  _InfoRow(
                    label: '截止日期',
                    value: DateFormat('yyyy/MM/dd HH:mm').format(task.deadline!),
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
                      width: 88,
                      child: Text('進度',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: AppColors.inkSoft)),
                    ),
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
          const SizedBox(height: 24),

          // ---- 完成紀錄（待確認可操作 + 歷史保留）----
          if (history.isNotEmpty) ...[
            const Text('完成紀錄',
                style: TextStyle(
                    fontSize: AppType.body,
                    fontWeight: FontWeight.w500,
                    color: AppColors.white)),
            const SizedBox(height: 8),
            for (final c in history)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.diluteInk,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.inkSoft, width: 1),
                  ),
                  child: Row(
                    children: [
                      Text(repo.userOf(c.userId).avatarEmoji,
                          style: const TextStyle(fontSize: 26)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${repo.userOf(c.userId).displayName} 完成了一次',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.white),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat('MM/dd HH:mm').format(c.submittedAt),
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      if (c.status == CompletionStatus.pending && isCreator)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ShadButton.outline(
                              size: ShadButtonSize.sm,
                              onPressed: () =>
                                  repo.rejectCompletion(task.id, c.id),
                              child: const Text('退回'),
                            ),
                            const SizedBox(width: 8),
                            ShadButton(
                              size: ShadButtonSize.sm,
                              onPressed: () =>
                                  repo.confirmCompletion(task.id, c.id),
                              child: const Text('✔ 確認'),
                            ),
                          ],
                        )
                      else
                        _CompletionStatusLabel(status: c.status),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
          ],

          // ---- 主要動作 ----
          ..._buildActions(context, ref, task,
              isCreator: isCreator, isClaimant: isClaimant),
        ],
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
        backgroundColor: AppColors.pink,
        foregroundColor: AppColors.white,
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
      return [
        primary('完成一次', () async {
          await repo.submitCompletion(task.id);
          if (context.mounted) {
            ShadToaster.of(context).show(
              const ShadToast(description: Text('已送出，等待發起人確認')),
            );
          }
        }),
        const SizedBox(height: 8),
        // 與「下次再說」一致：整條 ghost、白字、淡白 hover
        ShadButton.ghost(
          width: double.infinity,
          foregroundColor: AppColors.white,
          hoverForegroundColor: AppColors.white,
          hoverBackgroundColor: AppColors.white.withValues(alpha: 0.08),
          onPressed: () => repo.abandonTask(task.id),
          child: const Text('放棄任務'),
        ),
      ];
    }

    if (isClaimant && task.status == TaskStatus.completed) {
      return [
        primary('🎉 領取獎勵', () async {
          await repo.claimReward(task.id);
          if (context.mounted) context.pushReplacement('/celebrate/${task.id}');
        }),
      ];
    }

    if (isCreator && task.status == TaskStatus.open) {
      return [
        Center(
          child: ShadButton.link(
            foregroundColor: AppColors.orange,
            onPressed: () async {
              await repo.cancelTask(task.id);
              if (context.mounted) context.pop();
            },
            child: const Text('取消任務'),
          ),
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
      CompletionStatus.pending => ('等待確認', Colors.white70),
      CompletionStatus.confirmed => ('已確認', AppColors.pink),
      CompletionStatus.rejected => ('已退回', Colors.white70),
    };
    final text = Text(
      label,
      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: color),
    );
    if (status != CompletionStatus.confirmed) return text;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppSvgIcon(kStarSvg, color: AppColors.pink, size: 15),
        const SizedBox(width: 4),
        text,
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 88,
          child: Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w500, color: AppColors.inkSoft)),
        ),
        Expanded(
          child:
              Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}
