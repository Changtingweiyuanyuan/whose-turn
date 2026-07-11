import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../models/task.dart';
import '../state/providers.dart';
import '../theme/app_colors.dart';
import '../widgets/reward_badge.dart';
import '../widgets/star_progress.dart';

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
    final pending = task.completions
        .where((c) => c.status == CompletionStatus.pending)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('任務詳情')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
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
              child: Text(task.emoji, style: const TextStyle(fontSize: 56)),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              task.title,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 10),
          Center(child: RewardBadge(task: task, viewerUid: me.uid)),
          const SizedBox(height: 8),
          Center(
            child: Text(
              '${creator.avatarEmoji} 發起人：${creator.displayName}',
              style: const TextStyle(color: AppColors.navySoft),
            ),
          ),
          const SizedBox(height: 24),
          _InfoCard(
            children: [
              _InfoRow(label: '完成條件', value: '${task.title} ${task.requiredCount} 次'),
              _InfoRow(
                label: '獎勵內容',
                value: task.rewardLabelFor(me.uid) == '???'
                    ? '🎁 完成才揭曉'
                    : task.rewardLabel,
              ),
              if (task.deadline != null)
                _InfoRow(
                  label: '截止日期',
                  value: DateFormat('yyyy/MM/dd HH:mm').format(task.deadline!),
                ),
              if (task.assigneeUid != null)
                _InfoRow(
                  label: '指定給',
                  value: repo.userOf(task.assigneeUid!).displayName,
                ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 88,
                      child: Text('進度',
                          style: TextStyle(color: AppColors.navySoft)),
                    ),
                    StarProgress(
                      confirmed: task.confirmedCount,
                      required: task.requiredCount,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ---- 發起人視角：待確認清單 ----
          if (isCreator && pending.isNotEmpty) ...[
            const Text('等待確認',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            for (final c in pending)
              Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Text(repo.userOf(c.userId).avatarEmoji,
                      style: const TextStyle(fontSize: 26)),
                  title: Text('${repo.userOf(c.userId).displayName} 完成了一次'),
                  subtitle:
                      Text(DateFormat('MM/dd HH:mm').format(c.submittedAt)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OutlinedButton(
                        onPressed: () => repo.rejectCompletion(task.id, c.id),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          minimumSize: Size.zero,
                        ),
                        child: const Text('退回'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () => repo.confirmCompletion(task.id, c.id),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          minimumSize: Size.zero,
                        ),
                        child: const Text('✔ 確認'),
                      ),
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

    Widget primary(String label, Future<void> Function() onPressed) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 17),
          ),
          onPressed: () => onPressed(),
          child: Text(label),
        ),
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
        primary('我完成一次', () async {
          await repo.submitCompletion(task.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('已送出，等待發起人確認 ⏳')),
            );
          }
        }),
        if (task.hasPendingCompletion)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Center(
              child: Text('已完成一次・等待確認中',
                  style: TextStyle(color: AppColors.navySoft)),
            ),
          ),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: () => repo.abandonTask(task.id),
            child: const Text('放棄任務（回到任務牆）',
                style: TextStyle(color: AppColors.navySoft)),
          ),
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
          child: TextButton(
            onPressed: () async {
              await repo.cancelTask(task.id);
              if (context.mounted) context.pop();
            },
            child: const Text('取消任務', style: TextStyle(color: AppColors.navySoft)),
          ),
        ),
      ];
    }

    return const [];
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(children: children),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(label, style: const TextStyle(color: AppColors.navySoft)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
