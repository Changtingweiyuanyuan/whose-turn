import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/task.dart';
import '../state/providers.dart';
import '../theme/app_colors.dart';
import '../widgets/task_card.dart';

enum TaskWallFilter { all, mine, claimed }

enum TaskWallSort { newest, deadline, mystery, reward }

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
                const Text(
                  '👀 今天換誰？',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                PopupMenuButton<TaskWallSort>(
                  icon: const Icon(Icons.sort_rounded, color: AppColors.navy),
                  initialValue: _sort,
                  onSelected: (v) => setState(() => _sort = v),
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                        value: TaskWallSort.newest, child: Text('最新')),
                    PopupMenuItem(
                        value: TaskWallSort.deadline, child: Text('快截止')),
                    PopupMenuItem(
                        value: TaskWallSort.mystery, child: Text('神秘')),
                    PopupMenuItem(
                        value: TaskWallSort.reward, child: Text('高獎勵')),
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
                _FilterChip(
                  label: '全部任務',
                  selected: _filter == TaskWallFilter.all,
                  onTap: () => setState(() => _filter = TaskWallFilter.all),
                ),
                _FilterChip(
                  label: '我發起的',
                  selected: _filter == TaskWallFilter.mine,
                  onTap: () => setState(() => _filter = TaskWallFilter.mine),
                ),
                _FilterChip(
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('接下「${task.title}」！加油 💪')),
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
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
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? AppColors.navy : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.white : AppColors.navySoft,
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
          SizedBox(height: 12),
          Text(
            '目前沒有任務\n發起一個，看看今天換誰？',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.navySoft, height: 1.6),
          ),
        ],
      ),
    );
  }
}
