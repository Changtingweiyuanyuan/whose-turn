// ignore_for_file: unused_element
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/task.dart';
import '../state/providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../widgets/app_sliding_tabs.dart';
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
  TaskWallSort.mystery: '神秘獎勵',
  TaskWallSort.reward: '現金',
};

const _weekdays = ['一', '二', '三', '四', '五', '六', '日'];

// Iconsax arrow-down2（broken 樣式）—— 直接用官方 SVG，最精準
const _sortArrowSvg =
    '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" '
    'viewBox="0 0 24 24" fill="none"><path d="M6.31017 11.22C4.66017 8.35 '
    '6.01017 6 9.33017 6H12.0002H14.6702C17.9802 6 19.3402 8.35 17.6802 '
    '11.22L16.3402 13.53L15.0002 15.84C13.3402 18.71 10.6302 18.71 8.97017 '
    '15.84" stroke="#ffffff" stroke-width="1.5" stroke-miterlimit="10" '
    'stroke-linecap="round" stroke-linejoin="round"/></svg>';

/// 任務看板（首頁）—— 黑底雜誌刊頭風。
class TaskWallScreen extends ConsumerStatefulWidget {
  const TaskWallScreen({super.key});

  @override
  ConsumerState<TaskWallScreen> createState() => _TaskWallScreenState();
}

class _TaskWallScreenState extends ConsumerState<TaskWallScreen> {
  TaskWallFilter _filter = TaskWallFilter.all;
  final TaskWallSort _sort = TaskWallSort.newest;

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
    final userNo = repo.userNo;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Masthead(openCount: openCount, userNo: userNo),
              const SizedBox(height: AppSpacing.md),
              // 排版式分頁 + 行內排序
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pagePadding),
                // 與「我的任務」共用同一種滑動分頁
                child: AppSlidingTabs(
                  labels: [
                    for (final f in TaskWallFilter.values) _filterLabels[f]!,
                  ],
                  selected: TaskWallFilter.values.indexOf(_filter),
                  onChanged: (i) =>
                      setState(() => _filter = TaskWallFilter.values[i]),
                ),
                // 排序控制先收起來（保留程式碼，之後要用再打開）
                // _SortControl(
                //   value: _sort,
                //   onChanged: (v) => setState(() => _sort = v),
                // ),
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
                            // 四色依序輪替
                            backgroundColor:
                                AppColors.cardCycle[i % AppColors.cardCycle.length],
                            onTap: () => context.push('/task/${task.id}'),
                            onClaim: () async {
                              await repo.claimTask(task.id);
                              if (context.mounted) {
                                ShadToaster.of(context).show(
                                  ShadToast(
                                    description: Text('接下「${task.title}」！加油 💪🏻'),
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
    );
  }
}

/// 雜誌刊頭：WHOSE TURN TODAY / NO.xx + 大標「今天換誰？」+ 副標。
class _Masthead extends StatelessWidget {
  const _Masthead({required this.openCount, required this.userNo});

  final int openCount;

  /// 目前使用者是第幾位（最少兩位數、不足補 0）；null＝未加入群組，不顯示。
  final int? userNo;

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
                  'WHOSE TURN TODAY',
                  style: TextStyle(
                    fontSize: AppType.kicker,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 3,
                    color: AppColors.orangeLine,
                  ),
                ),
              ),
              if (userNo != null)
                Text(
                  'NO.${userNo.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: AppType.body,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    color: AppColors.green,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            height: 2,
            decoration: BoxDecoration(
              color: AppColors.orangeLine,
              borderRadius: BorderRadius.circular(2), // 對齊選中 tab 底線
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // 大標，粗黑無襯線，誰=綠色
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w600,
                height: 1.1,
                color: AppColors.ink,
              ),
              children: [
                TextSpan(text: '今天換'),
                TextSpan(text: '誰', style: TextStyle(color: AppColors.green)),
                TextSpan(text: '?'),
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
                      fontSize: AppType.label, color: AppColors.inkSoft),
                ),
              ),
              Text(
                '星期$weekday',
                style: const TextStyle(
                    fontSize: AppType.label, color: AppColors.greenPale),
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
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // 底線：粉色圓角粗線，切換時從左側滑入 / 滑出（scaleX 動畫）
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                tween: Tween(begin: 0, end: selected ? 1.0 : 0.0),
                builder: (context, t, child) => Transform.scale(
                  scaleX: t,
                  alignment: Alignment.centerLeft,
                  child: child,
                ),
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.orangeLine,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            Padding(
              // 文字與底線間留 4px（底線 4 + 間距 4）
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: AppType.body,
                  fontWeight: FontWeight.w500,
                  color: selected ? AppColors.green : AppColors.greenPale,
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
  final _link = LayerLink();
  final _portal = OverlayPortalController();

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: (context) {
        return Stack(
          children: [
            // 點外面關閉
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _portal.hide,
              ),
            ),
            // 選單：右緣對齊觸發點右緣（＝距螢幕 20px），往下開
            CompositedTransformFollower(
              link: _link,
              targetAnchor: Alignment.bottomRight,
              followerAnchor: Alignment.topRight,
              offset: const Offset(0, 4),
              child: Container(
                width: 150,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.diluteInk,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.lightGray, width: 1),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 4,
                  children: [
                    for (final entry in _sortLabels.entries)
                      _SortItem(
                        label: entry.value,
                        selected: entry.key == widget.value,
                        onTap: () {
                          widget.onChanged(entry.key);
                          _portal.hide();
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
      child: CompositedTransformTarget(
        link: _link,
        child: GestureDetector(
          onTap: _portal.toggle,
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '排序 · ${_sortLabels[widget.value]}',
                style: const TextStyle(
                  fontSize: AppType.label,
                  fontWeight: FontWeight.w500,
                  color: AppColors.inkSoft,
                ),
              ),
              const SizedBox(width: 4),
              SvgPicture.string(
                _sortArrowSvg,
                width: 16,
                height: 16,
                colorFilter:
                    const ColorFilter.mode(AppColors.inkSoft, BlendMode.srcIn),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 排序選項：左對齊，選中前方帶粉色短線；hover 疊半透明白、圓角 6。
class _SortItem extends StatefulWidget {
  const _SortItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_SortItem> createState() => _SortItemState();
}

class _SortItemState extends State<_SortItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: _hover ? const Color(0x14FFFFFF) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              // 粉色短線指示器（選中才顯示；未選中留同寬空位讓文字對齊）
              Container(
                width: 16,
                height: 3,
                decoration: BoxDecoration(
                  color: widget.selected ? AppColors.pink : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.selected ? AppColors.pink : AppColors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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
