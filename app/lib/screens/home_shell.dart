import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.pink,
        foregroundColor: AppColors.white,
        shape: const CircleBorder(),
        onPressed: _startCreateTask,
        child: const Icon(Icons.add_rounded, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: AppColors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            _NavItem(
              icon: Icons.home_rounded,
              label: '任務牆',
              selected: _index == 0,
              onTap: () => setState(() => _index = 0),
            ),
            _NavItem(
              icon: Icons.checklist_rounded,
              label: '我的任務',
              selected: _index == 1,
              onTap: () => setState(() => _index = 1),
            ),
            const Expanded(child: SizedBox()), // FAB 缺口
            _NavItem(
              icon: Icons.chat_bubble_outline_rounded,
              label: '訊息',
              selected: _index == 2,
              badgeCount: unread,
              onTap: () => setState(() => _index = 2),
            ),
            _NavItem(
              icon: Icons.person_outline_rounded,
              label: '我的',
              selected: _index == 3,
              onTap: () => setState(() => _index = 3),
            ),
          ],
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
    final color = selected ? AppColors.pink : AppColors.navySoft;
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
