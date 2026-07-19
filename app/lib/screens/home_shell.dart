import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../data/line_auth/line_auth_result.dart';
import '../state/providers.dart';
import '../theme/app_colors.dart';
import '../widgets/app_svg_icons.dart';
import '../widgets/line_bind_sheet.dart';
import '../widgets/message_bubble_icon.dart';
import '../widgets/noise_background.dart';
import 'my_tasks_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'task_wall_screen.dart';

/// 底部導覽外殼：任務看板／我的任務／(+)／訊息／我的。
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    // LINE 授權回跳的結果，成功或失敗都要讓使用者知道。
    // 延遲到首幀之後再 show：ShadToaster 的進場動畫在第一幀尚未就緒。
    final lineResult = ref.read(lineRedirectResultProvider);
    if (lineResult != LineRedirectResult.none) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        ShadToaster.of(context).show(
          ShadToast(
            description: Text(lineResult == LineRedirectResult.success
                ? 'LINE 綁定成功！'
                : 'LINE 綁定失敗，請再試一次'),
          ),
        );
      });
    }
  }


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
      // 中央建立鍵：綠色愛心大鍵，浮在導覽列上
      floatingActionButton: GestureDetector(
        onTap: _startCreateTask,
        child: SizedBox(
          width: 62,
          height: 62,
          child: Stack(
            alignment: Alignment.center,
            children: const [
              AppAssetIcon('assets/icons/heart.svg', size: 62),
              // 愛心視覺重心略偏上，加號往上微調置中
              Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: AppSvgIcon(kAddSvg, color: AppColors.white, size: 26),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          //border: Border(top: BorderSide(color: AppColors.inkSoft, width: 0.5)),
        ),
        child: BottomAppBar(
          color: AppColors.greenSoft,
          height: 62 + MediaQuery.of(context).padding.bottom,
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          child: Row(
            children: [
              _NavItem(
                iconBuilder: (color) => AppSvgIcon(kHomeBoardSvg, color: color),
              label: '任務看板',
              selected: _index == 0,
              onTap: () => setState(() => _index = 0),
            ),
            _NavItem(
              iconBuilder: (color) => AppSvgIcon(kTaskListSvg, color: color),
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
              iconBuilder: (color) => AppSvgIcon(kSettingsSvg, color: color),
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
    final color = selected ? AppColors.green : AppColors.ink;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 自訂 badge：橘圓 + 1.5px 邊框（與導覽底同色，做出切割感）
              Stack(
                clipBehavior: Clip.none,
                children: [
                  iconBuilder?.call(color) ?? Icon(icon, color: color),
                  if (badgeCount > 0)
                    Positioned(
                      top: -6,
                      right: -8,
                      child: Container(
                        height: 18,
                        constraints: const BoxConstraints(minWidth: 18),
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.orange,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                              color: AppColors.greenSoft, width: 1.5),
                        ),
                        child: Text(
                          '$badgeCount',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.white,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                ],
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
