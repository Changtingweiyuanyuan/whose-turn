import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../state/providers.dart';
import '../theme/app_colors.dart';
import '../widgets/line_bind_sheet.dart';
import '../widgets/message_bubble_icon.dart';
import '../widgets/noise_background.dart';
import 'my_tasks_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'task_wall_screen.dart';

/// 底部導覽外殼：任務牆／我的任務／(+)／訊息／我的。
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  Future<void> _startCreateTask() async {
    final repo = ref.read(repositoryProvider);
    // 訪客 gate：發起任務前必須綁定 LINE
    if (repo.currentUser.isGuest) {
      final bound = await showLineBindSheet(context, ref);
      if (!bound) return;
    }
    if (mounted) context.push('/create-task');
  }

  @override
  Widget build(BuildContext context) {
    final unread = ref.watch(repositoryProvider).unreadCount;

    return Scaffold(
      // 讓頁面內容延伸到導覽列後方，缺口才會露出黑底而非淺色
      extendBody: true,
      // 全站共用黑底顆粒背景
      body: NoiseBackground(
        child: IndexedStack(
          index: _index,
          children: const [
            TaskWallScreen(),
            MyTasksScreen(),
            NotificationsScreen(),
            ProfileScreen(),
          ],
        ),
      ),
      // 中央建立鍵：粉色圓形大鍵，坐落在圓弧 notch 上
      floatingActionButton: GestureDetector(
        onTap: _startCreateTask,
        child: Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            color: AppColors.pink,
            shape: BoxShape.circle,
          ),
          child: const Icon(Iconsax.add_copy, size: 30, color: AppColors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          //border: Border(top: BorderSide(color: AppColors.inkSoft, width: 0.5)),
        ),
        child: BottomAppBar(
          color: AppColors.diluteInk,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          height: 62 + MediaQuery.of(context).padding.bottom,
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          child: Row(
            children: [
              _NavItem(
                icon: Iconsax.home_2_copy,
              label: '任務看板',
              selected: _index == 0,
              onTap: () => setState(() => _index = 0),
            ),
            _NavItem(
              icon: Iconsax.task_square_copy,
              label: '我的任務',
              selected: _index == 1,
              onTap: () => setState(() => _index = 1),
            ),
            const Expanded(child: SizedBox()), // FAB 缺口
            _NavItem(
              iconBuilder: (color) =>
                  MessageBubbleIcon(color: color, size: 24),
              label: '通知',
              selected: _index == 2,
              badgeCount: unread,
              onTap: () => setState(() => _index = 2),
            ),
            _NavItem(
              icon: Iconsax.user_copy,
              label: '個人設定',
              selected: _index == 3,
              onTap: () => setState(() => _index = 3),
            ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.iconBuilder,
    this.badgeCount = 0,
  }) : assert(icon != null || iconBuilder != null);

  /// 一般 Iconsax icon；與 [iconBuilder] 二選一。
  final IconData? icon;

  /// 自訂 icon（會收到目前的顏色，供 SVG 上色）；優先於 [icon]。
  final Widget Function(Color color)? iconBuilder;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.pink : Colors.white54;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Badge.count(
                count: badgeCount,
                isLabelVisible: badgeCount > 0,
                backgroundColor: AppColors.pink,
                child: iconBuilder?.call(color) ?? Icon(icon, color: color),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
