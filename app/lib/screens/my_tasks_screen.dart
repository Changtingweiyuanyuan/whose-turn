import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/task.dart';
import '../state/providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../widgets/app_masthead.dart';
import '../widgets/app_sliding_tabs.dart';
import '../widgets/person_avatar.dart';
import '../widgets/task_card.dart';

/// 我的任務：進行中（我接的）／等待確認（我發起、待我確認）／已完成。
class MyTasksScreen extends ConsumerStatefulWidget {
  const MyTasksScreen({super.key});

  @override
  ConsumerState<MyTasksScreen> createState() => _MyTasksScreenState();
}

class _MyTasksScreenState extends ConsumerState<MyTasksScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
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
    final userNo = repo.userNo;

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppMasthead(
              title: '我的任務', userNo: userNo, starTotal: me.starTotal),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
            child: AppSlidingTabs(
              labels: const ['進行中', '等待確認', '已完成'],
              selected: _tab,
              onChanged: (i) => setState(() => _tab = i),
              badgeIndex: 1,
              badgeCount: pendingCount,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pagePadding),
              child: IndexedStack(
                index: _tab,
                children: [
                  _TaskList(
                      tasks: inProgress, emptyText: '還沒接任務\n去任務看板看看今天換誰？'),
                  _ConfirmList(tasks: toConfirm),
                  _TaskList(tasks: done, emptyText: '完成的任務會出現在這裡'),
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
            style: const TextStyle(color: AppColors.inkSoft, height: 1.6),
          ),
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 96),
      itemCount: tasks.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, i) => TaskCard(
        task: tasks[i],
        viewer: repo.currentUser,
        creator: repo.userOf(tasks[i].createdBy),
        // 四色依序輪替，與首頁一致
        backgroundColor: AppColors.cardCycle[i % AppColors.cardCycle.length],
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
              style: TextStyle(color: AppColors.inkSoft)),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 96),
      itemCount: entries.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, i) {
        final (:task, :completion) = entries[i];
        final doer = repo.userOf(completion.userId);
        // 與任務詳情「完成紀錄」一致：四色輪替、無邊框
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.cardCycle[i % AppColors.cardCycle.length],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              PersonAvatar(doer.avatarEmoji,
                  size: 26,
                  fillColor: AppColors.ink,
                  orangeColor: AppColors.green),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${doer.displayName} 完成了 ${task.title}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.ink),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('MM/dd HH:mm').format(completion.submittedAt),
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.inkSoft),
                    ),
                  ],
                ),
              ),
              // 退回 = 次要 CTA：ink 底、hover inkHover
              ShadButton(
                size: ShadButtonSize.sm,
                backgroundColor: AppColors.bg,
                foregroundColor: AppColors.green,
                hoverBackgroundColor: AppColors.greenSoft,
                hoverForegroundColor: AppColors.green,
                decoration: ShadDecoration(
                    border: ShadBorder.all(color: AppColors.green, width: 1)),
                onPressed: () =>
                    repo.rejectCompletion(task.id, completion.id),
                child: const Text('退回'),
              ),
              const SizedBox(width: 8),
              // 確認 對齊「完成一次」：粉底白字
              ShadButton(
                size: ShadButtonSize.sm,
                backgroundColor: AppColors.green,
                foregroundColor: AppColors.bg,
                hoverBackgroundColor: AppColors.greenDark,
                hoverForegroundColor: AppColors.bg,
                onPressed: () =>
                    repo.confirmCompletion(task.id, completion.id),
                child: const Text('確認'),
              ),
            ],
          ),
        );
      },
    );
  }
}
