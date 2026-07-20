import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../state/providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../widgets/app_masthead.dart';
import '../widgets/app_sliding_tabs.dart';
import '../widgets/dashed_rule.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  int _tab = 0; // 0=未讀 1=已讀

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(repositoryProvider);
    final all = repo.notifications;
    final items = all.where((n) => _tab == 0 ? !n.read : n.read).toList();
    final unread = all.where((n) => !n.read).toList();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppMasthead(title: '通知'),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pagePadding,
            ),
            child: Row(
              children: [
                Expanded(
                  child: AppSlidingTabs(
                    labels: const ['未讀', '已讀'],
                    selected: _tab,
                    onChanged: (i) => setState(() => _tab = i),
                  ),
                ),
                // gap 對齊「資料尚未備份 ↔ 用 LINE 綁定」的 12
                const SizedBox(width: 12),
                ShadButton(
                  size: ShadButtonSize.sm,
                  enabled: unread.isNotEmpty,
                  backgroundColor: AppColors.green,
                  foregroundColor: AppColors.bg,
                  hoverBackgroundColor: AppColors.greenDark,
                  hoverForegroundColor: AppColors.bg,
                  onPressed: unread.isEmpty
                      ? null
                      : () async {
                          for (final n in unread) {
                            await repo.markNotificationRead(n.id);
                          }
                        },
                  child: const Text('全部已讀'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Text(
                      _tab == 0 ? '沒有未讀訊息 🎉' : '還沒有訊息\n有人發起任務時會通知你 👀',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.inkSoft,
                        height: 1.6,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 16),
                    itemBuilder: (context, i) {
                      final n = items[i];
                      return MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () async {
                            await repo.markNotificationRead(n.id);
                            if (n.taskId != null && context.mounted) {
                              context.push('/task/${n.taskId}');
                            }
                          },
                          // 1px 邊框：已讀＝紋理、未讀＝紅 D5665C
                          child: Container(
                            padding: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                AppRadius.card,
                              ),
                              color: n.read ? null : AppColors.red,
                              image: n.read
                                  ? const DecorationImage(
                                      image: AssetImage(
                                        'assets/images/card_border.png',
                                      ),
                                      repeat: ImageRepeat.repeat,
                                      fit: BoxFit.none,
                                    )
                                  : null,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.card - 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    n.title,
                                    style: const TextStyle(
                                      fontSize: AppType.body,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: AppType.spacingBold,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                  // 標題下虛線：同任務內容 block（上下 gap 6）
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 6),
                                    child: DashedRule(
                                      color: Color(0xFFF3F3F3),
                                      thickness: 1,
                                    ),
                                  ),
                                  Text(
                                    n.body,
                                    style: const TextStyle(
                                      fontSize: AppType.kicker,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.inkSoft,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    DateFormat(
                                      'MM/dd HH:mm',
                                    ).format(n.createdAt),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.inkSoft,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
