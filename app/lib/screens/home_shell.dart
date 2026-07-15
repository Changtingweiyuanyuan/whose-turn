import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../state/providers.dart';
import '../theme/app_colors.dart';
import '../widgets/line_bind_sheet.dart';
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
      body: IndexedStack(
        index: _index,
        children: const [
          TaskWallScreen(),
          MyTasksScreen(),
          NotificationsScreen(),
          ProfileScreen(),
        ],
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
          border: Border(top: BorderSide(color: AppColors.inkSoft, width: 0.5)),
        ),
        child: BottomAppBar(
          color: AppColors.ink,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          height: 62 + MediaQuery.of(context).padding.bottom,
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          child: Row(
            children: [
              _NavItem(
                icon: Iconsax.home_2_copy,
              label: '任務牆',
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
              icon: Iconsax.message_copy,
              label: '訊息',
              selected: _index == 2,
              badgeCount: unread,
              onTap: () => setState(() => _index = 2),
            ),
            _NavItem(
              icon: Iconsax.user_copy,
              label: '我的',
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
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
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
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
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
