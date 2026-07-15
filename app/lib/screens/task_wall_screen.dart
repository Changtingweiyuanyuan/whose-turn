import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/task.dart';
import '../state/providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';
import '../theme/app_tokens.dart';
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

const _weekdays = ['一', '二', '三', '四', '五', '六', '日'];

/// 任務牆（首頁）—— 黑底雜誌刊頭風。
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
    final openCount = repo.tasks.where((t) => t.status == TaskStatus.open).length;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: ColoredBox(
        color: AppColors.ink,
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Masthead(openCount: openCount),
              const SizedBox(height: AppSpacing.md),
              // 排版式分頁 + 行內排序
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pagePadding),
                // spaceBetween（無 flex widget）避免干擾分頁的 IntrinsicWidth
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final f in TaskWallFilter.values)
                          _TabLabel(
                            label: _filterLabels[f]!,
                            selected: _filter == f,
                            onTap: () => setState(() => _filter = f),
                          ),
                      ],
                    ),
                    _SortControl(
                      value: _sort,
                      onChanged: (v) => setState(() => _sort = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: tasks.isEmpty
                    ? const _EmptyWall()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                            AppSpacing.pagePadding,
                            0,
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
                            // 藍/白輪替
                            backgroundColor:
                                i.isEven ? AppColors.main : AppColors.white,
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
        ),
      ),
    );
  }
}

/// 雜誌刊頭：HOUSEHOLD WEEKLY / NO.07 + 大標「今天換誰？」+ 副標。
class _Masthead extends StatelessWidget {
  const _Masthead({required this.openCount});

  final int openCount;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekday = _weekdays[(now.weekday - 1) % 7];

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
                  'HOUSEHOLD\nWEEKLY',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3,
                    color: AppColors.white,
                  ),
                ),
              ),
              Text(
                'NO.07',
                style: TextStyle(
                  fontSize: 15,
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
          // 大標，毛筆手寫感，誰=粉色
          RichText(
            text: TextSpan(
              style: AppFonts.brush(
                fontSize: 66,
                height: 1.0,
                color: AppColors.white,
              ),
              children: const [
                TextSpan(text: '今天換'),
                TextSpan(text: '誰', style: TextStyle(color: AppColors.pink)),
                TextSpan(text: '？'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Text(
                  '本週待接任務 · ${openCount.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                      fontSize: AppType.label, color: Colors.white70),
                ),
              ),
              Text(
                '星期$weekday',
                style: const TextStyle(
                    fontSize: AppType.label, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 排版式分頁：選中者白色粗字 + 粉色底線；未選中灰。
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
    // 底線用圓角色塊墊在文字後面（Stack），寬度貼合文字、可加圓角。
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(right: AppSpacing.lg, bottom: 4),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // 底線：粉色圓角粗線，Positioned 貼齊文字寬度
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: selected ? AppColors.pink : Colors.transparent,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: AppType.body,
                  fontWeight: FontWeight.w500,
                  color: selected ? AppColors.white : AppColors.main,
                ),
              ),
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
      // 對齊分頁文字（分頁文字下方還有 7+4 的底線空間）
      padding: const EdgeInsets.only(top: 1),
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
              color: Colors.white70,
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
            style: TextStyle(color: Colors.white70, height: 1.6),
          ),
        ],
      ),
    );
  }
}
