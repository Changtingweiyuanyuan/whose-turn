import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/task.dart';
import '../state/providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../widgets/app_svg_icons.dart';
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
    final userNo =
        (repo.currentGroup?.memberUids.indexOf(me.uid) ?? -1) + 1;

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MyTasksMasthead(userNo: userNo, starTotal: me.starTotal),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
            child: _SlidingTabs(
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
                      tasks: inProgress, emptyText: '還沒接任務\n去任務牆看看今天換誰？'),
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

/// 我的任務刊頭：沿用圖三雜誌刊頭，標題改「我的任務」（字較小）。
class _MyTasksMasthead extends StatelessWidget {
  const _MyTasksMasthead({required this.userNo, required this.starTotal});

  final int userNo;
  final int starTotal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.pagePadding, AppSpacing.md, AppSpacing.pagePadding, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'WHOSE TURN TODAY',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 3,
                    color: AppColors.white,
                  ),
                ),
              ),
              Text(
                'NO.${userNo.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  color: AppColors.pink,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(height: 2, color: AppColors.pink),
          const SizedBox(height: AppSpacing.md),
          // 標題與星星同一排，星星靠最右
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(
                child: Text(
                  '我的任務',
                  style: TextStyle(
                    fontSize: 20,
                    height: 1.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppSvgIcon(kStarSvg, color: AppColors.pink, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    '$starTotal',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 滑動底線分頁（圖二）：三格平均分佈，選中底線在整條基線上滑動。
class _SlidingTabs extends StatelessWidget {
  const _SlidingTabs({
    required this.labels,
    required this.selected,
    required this.onChanged,
    this.badgeIndex = -1,
    this.badgeCount = 0,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;
  final int badgeIndex;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final n = labels.length;
    // 選中格中心的對齊 x：0→-1, 中→0, 末→1
    final x = n == 1 ? 0.0 : -1.0 + 2.0 * selected / (n - 1);

    return Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < n; i++)
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(i),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          labels[i],
                          style: TextStyle(
                            fontSize: AppType.body,
                            fontWeight: FontWeight.w500,
                            color:
                                i == selected ? AppColors.white : AppColors.main,
                          ),
                        ),
                        if (i == badgeIndex && badgeCount > 0) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: const BoxDecoration(
                              color: AppColors.pink,
                              shape: BoxShape.circle,
                            ),
                            child: Text('$badgeCount',
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.white)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        // 基線 + 滑動的粉色底線
        Stack(
          children: [
            Container(height: 1, color: Colors.white24),
            AnimatedAlign(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              alignment: Alignment(x, 0),
              child: FractionallySizedBox(
                widthFactor: 1 / n,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.pink,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
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
            style: const TextStyle(color: Colors.white70, height: 1.6),
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
        // 藍/白輪替，與首頁一致
        backgroundColor: i.isEven ? AppColors.main : AppColors.white,
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
              style: TextStyle(color: Colors.white70)),
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
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          DateFormat('今天 HH:mm').format(completion.submittedAt),
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.inkSoft),
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
