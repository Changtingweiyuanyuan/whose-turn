import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/task.dart';
import '../state/providers.dart';
import '../theme/app_colors.dart';
import '../widgets/task_card.dart';

enum TaskWallFilter { all, mine, claimed }

enum TaskWallSort { newest, deadline, mystery, reward }

const _sortLabels = {
  TaskWallSort.newest: '最新',
  TaskWallSort.deadline: '快截止',
  TaskWallSort.mystery: '神秘',
  TaskWallSort.reward: '高獎勵',
};

/// 任務牆（首頁）—— App 最重要畫面。
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
    var list = repo.tasks
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    '👀 今天換誰？',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ShadSelect<TaskWallSort>(
                  initialValue: _sort,
                  onChanged: (v) => setState(() => _sort = v ?? _sort),
                  selectedOptionBuilder: (context, value) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Iconsax.sort_copy,
                          size: 14, color: AppColors.inkSoft),
                      const SizedBox(width: 6),
                      Text(_sortLabels[value]!),
                    ],
                  ),
                  options: [
                    for (final entry in _sortLabels.entries)
                      ShadOption(value: entry.key, child: Text(entry.value)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _FilterPill(
                  label: '全部任務',
                  selected: _filter == TaskWallFilter.all,
                  onTap: () => setState(() => _filter = TaskWallFilter.all),
                ),
                _FilterPill(
                  label: '我發起的',
                  selected: _filter == TaskWallFilter.mine,
                  onTap: () => setState(() => _filter = TaskWallFilter.mine),
                ),
                _FilterPill(
                  label: '我接的',
                  selected: _filter == TaskWallFilter.claimed,
                  onTap: () => setState(() => _filter = TaskWallFilter.claimed),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: tasks.isEmpty
                ? const _EmptyWall()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
                    itemCount: tasks.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
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

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: selected
          ? ShadButton(
              size: ShadButtonSize.sm,
              onPressed: onTap,
              child: Text(label),
            )
          : ShadButton.ghost(
              size: ShadButtonSize.sm,
              onPressed: onTap,
              child: Text(label),
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
          SizedBox(height: 12),
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
