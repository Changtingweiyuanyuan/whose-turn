import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/task.dart';
import '../state/providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../widgets/brand_eye.dart';
import '../widgets/task_card.dart';

enum TaskWallFilter { all, mine, claimed }

enum TaskWallSort { newest, deadline, mystery, reward }

const _filterLabels = {
  TaskWallFilter.all: '全部任務',
  TaskWallFilter.mine: '我發起的',
  TaskWallFilter.claimed: '我接的',
};

const _sortLabels = {
  TaskWallSort.newest: '最新',
  TaskWallSort.deadline: '快截止',
  TaskWallSort.mystery: '神秘',
  TaskWallSort.reward: '高獎勵',
};

/// 任務牆（首頁）—— App 最重要畫面，編輯排版風。
class TaskWallScreen extends ConsumerStatefulWidget {
  const TaskWallScreen({super.key});

  @override
  ConsumerState<TaskWallScreen> createState() => _TaskWallScreenState();
}

class _TaskWallScreenState extends ConsumerState<TaskWallScreen> {
  TaskWallFilter _filter = TaskWallFilter.all;
  TaskWallSort _sort = TaskWallSort.newest;

  List<Task> _visibleTasks() {
    final repo = ref.watch(repositoryProvider);
    final me = repo.currentUser.uid;
    final list = repo.tasks
        .where((t) =>
            t.status != TaskStatus.cancelled &&
            t.status != TaskStatus.rewardClaimed)
        .where((t) => switch (_filter) {
              TaskWallFilter.all => true,
              TaskWallFilter.mine => t.createdBy == me,
              TaskWallFilter.claimed => t.claimedBy == me,
            })
        .toList();

    list.sort((a, b) => switch (_sort) {
          TaskWallSort.newest => b.createdAt.compareTo(a.createdAt),
          TaskWallSort.deadline => (a.deadline ?? DateTime(2999))
              .compareTo(b.deadline ?? DateTime(2999)),
          TaskWallSort.mystery =>
            (b.isMystery ? 1 : 0).compareTo(a.isMystery ? 1 : 0),
          TaskWallSort.reward => b.requiredCount.compareTo(a.requiredCount),
        });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(repositoryProvider);
    final tasks = _visibleTasks();

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- 刊頭 ----
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.pagePadding, AppSpacing.lg, AppSpacing.pagePadding, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TASK BOARD ／ 今天的任務牆',
                  style: TextStyle(
                    fontSize: AppType.kicker,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: AppColors.inkSoft,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: Text(
                        '今天換誰？',
                        style: TextStyle(
                          fontSize: AppType.display,
                          fontWeight: FontWeight.w800,
                          height: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const BrandEye(size: 30),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // ---- 排版式分頁導覽 + 行內排序 ----
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pagePadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final f in TaskWallFilter.values)
                  _TabLabel(
                    label: _filterLabels[f]!,
                    selected: _filter == f,
                    onTap: () => setState(() => _filter = f),
                  ),
                const Spacer(),
                _SortControl(
                  value: _sort,
                  onChanged: (v) => setState(() => _sort = v),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.lightGray),
          Expanded(
            child: tasks.isEmpty
                ? const _EmptyWall()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.pagePadding,
                        AppSpacing.md,
                        AppSpacing.pagePadding,
                        AppSpacing.bottomNavClearance),
                    itemCount: tasks.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, i) {
                      final task = tasks[i];
                      return TaskCard(
                        task: task,
                        viewer: repo.currentUser,
                        creator: repo.userOf(task.createdBy),
                        onTap: () => context.push('/task/${task.id}'),
                        onClaim: () async {
                          await repo.claimTask(task.id);
                          if (context.mounted) {
                            ShadToaster.of(context).show(
                              ShadToast(
                                description: Text('接下「${task.title}」！加油 💪'),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// 排版式分頁：選中者墨黑粗字 + 橘色底線；未選中淺灰。
class _TabLabel extends StatelessWidget {
  const _TabLabel({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(right: AppSpacing.md, bottom: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: AppType.body,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected ? AppColors.ink : AppColors.inkSoft,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 3,
              width: selected ? 24 : 0,
              color: AppColors.orange,
            ),
          ],
        ),
      ),
    );
  }
}

/// 行內排序：像刊物欄位標籤而非 SaaS 下拉。
class _SortControl extends StatefulWidget {
  const _SortControl({required this.value, required this.onChanged});

  final TaskWallSort value;
  final ValueChanged<TaskWallSort> onChanged;

  @override
  State<_SortControl> createState() => _SortControlState();
}

class _SortControlState extends State<_SortControl> {
  final _controller = ShadPopoverController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ShadPopover(
        controller: _controller,
        popover: (context) => SizedBox(
          width: 120,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final entry in _sortLabels.entries)
                ShadButton.ghost(
                  onPressed: () {
                    widget.onChanged(entry.key);
                    _controller.hide();
                  },
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(entry.value,
                        style: TextStyle(
                          color: AppColors.ink,
                          fontWeight: entry.key == widget.value
                              ? FontWeight.w800
                              : FontWeight.w500,
                        )),
                  ),
                ),
            ],
          ),
        ),
        child: GestureDetector(
          onTap: _controller.toggle,
          behavior: HitTestBehavior.opaque,
          child: Text(
            '排序 · ${_sortLabels[widget.value]} ▾',
            style: const TextStyle(
              fontSize: AppType.label,
              fontWeight: FontWeight.w700,
              color: AppColors.inkSoft,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyWall extends StatelessWidget {
  const _EmptyWall();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🫧', style: TextStyle(fontSize: 52)),
          SizedBox(height: AppSpacing.md),
          Text(
            '目前沒有任務\n發起一個，看看今天換誰？',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.inkSoft, height: 1.6),
          ),
        ],
      ),
    );
  }
}
