import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/task.dart';
import '../state/providers.dart';
import '../theme/app_colors.dart';
import '../widgets/task_card.dart';

/// 我的任務：進行中（我接的）／等待確認（我發起、待我確認）／已完成。
class MyTasksScreen extends ConsumerWidget {
  const MyTasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(repositoryProvider);
    final me = repo.currentUser;

    final inProgress = repo.tasks
        .where((t) => t.claimedBy == me.uid && t.status == TaskStatus.claimed)
        .toList();
    final toConfirm = repo.tasks
        .where((t) => t.createdBy == me.uid && t.hasPendingCompletion)
        .toList();
    final done = repo.tasks
        .where((t) =>
            (t.claimedBy == me.uid || t.createdBy == me.uid) &&
            (t.status == TaskStatus.completed ||
                t.status == TaskStatus.rewardClaimed))
        .toList();

    final pendingCount = toConfirm
        .expand((t) => t.completions)
        .where((c) => c.status == CompletionStatus.pending)
        .length;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                const Text(
                  '我的任務',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                Text(
                  '⭐ ${me.starTotal}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ShadTabs<int>(
                value: 0,
                tabs: [
                  ShadTab(
                    value: 0,
                    content: _TaskList(
                        tasks: inProgress, emptyText: '還沒接任務\n去任務牆看看今天換誰？'),
                    child: const Text('進行中'),
                  ),
                  ShadTab(
                    value: 1,
                    content: _ConfirmList(tasks: toConfirm),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('等待確認'),
                        if (pendingCount > 0) ...[
                          const SizedBox(width: 4),
                          ShadBadge(
                            backgroundColor: AppColors.pink,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 0),
                            child: Text('$pendingCount',
                                style: const TextStyle(fontSize: 11)),
                          ),
                        ],
                      ],
                    ),
                  ),
                  ShadTab(
                    value: 2,
                    content:
                        _TaskList(tasks: done, emptyText: '完成的任務會出現在這裡'),
                    child: const Text('已完成'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskList extends ConsumerWidget {
  const _TaskList({required this.tasks, required this.emptyText});

  final List<Task> tasks;
  final String emptyText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(repositoryProvider);
    if (tasks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: Text(
            emptyText,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.navySoft, height: 1.6),
          ),
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 96),
      itemCount: tasks.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) => TaskCard(
        task: tasks[i],
        viewer: repo.currentUser,
        creator: repo.userOf(tasks[i].createdBy),
        onTap: () => context.push('/task/${tasks[i].id}'),
      ),
    );
  }
}

/// 等待確認 Tab：發起人視角，逐筆確認／退回。
class _ConfirmList extends ConsumerWidget {
  const _ConfirmList({required this.tasks});

  final List<Task> tasks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(repositoryProvider);
    final entries = [
      for (final t in tasks)
        for (final c in t.completions)
          if (c.status == CompletionStatus.pending) (task: t, completion: c),
    ];

    if (entries.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: Text('沒有待確認的完成紀錄',
              style: TextStyle(color: AppColors.navySoft)),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 96),
      itemCount: entries.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final (:task, :completion) = entries[i];
        final doer = repo.userOf(completion.userId);
        return ShadCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(doer.avatarEmoji, style: const TextStyle(fontSize: 30)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${doer.displayName} 完成了 ${task.title}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          DateFormat('今天 HH:mm').format(completion.submittedAt),
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.navySoft),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ShadButton.outline(
                    size: ShadButtonSize.sm,
                    onPressed: () =>
                        repo.rejectCompletion(task.id, completion.id),
                    child: const Text('退回'),
                  ),
                  const SizedBox(width: 8),
                  ShadButton(
                    size: ShadButtonSize.sm,
                    onPressed: () =>
                        repo.confirmCompletion(task.id, completion.id),
                    child: const Text('✔ 確認'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
