import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/notification_item.dart';
import '../state/providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../widgets/app_masthead.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(repositoryProvider);
    final items = repo.notifications;
    final userNo =
        (repo.currentGroup?.memberUids.indexOf(repo.currentUser.uid) ?? -1) + 1;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppMasthead(title: '通知', userNo: userNo),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Text('還沒有訊息\n有人發起任務時會通知你 👀',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, height: 1.6)),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final n = items[i];
                      return GestureDetector(
                        onTap: () async {
                          await repo.markNotificationRead(n.id);
                          if (n.taskId != null && context.mounted) {
                            context.push('/task/${n.taskId}');
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            // 未讀：淡藍底；已讀：diluteInk 深底 + 淡白邊（同完成紀錄）
                            color: n.read ? AppColors.diluteInk : AppColors.main,
                            borderRadius: BorderRadius.circular(8),
                            border: n.read
                                ? Border.all(color: AppColors.inkSoft, width: 1)
                                : null,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                n.title,
                                style: TextStyle(
                                    fontSize: AppType.body,
                                    fontWeight: FontWeight.w600,
                                    color: n.read
                                        ? AppColors.white
                                        : AppColors.ink),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                n.body,
                                style: TextStyle(
                                    fontSize: 13,
                                    // 任務完成（獎勵揭曉）粗體強調，其餘 w500
                                    fontWeight:
                                        n.type == NotificationType.taskCompleted
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                    color: n.read
                                        ? Colors.white70
                                        : AppColors.inkSoft),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                DateFormat('MM/dd HH:mm').format(n.createdAt),
                                style: TextStyle(
                                    fontSize: 12,
                                    // 已讀（深底）用淡藍；未讀（淡藍底）用 inkSoft 免同色
                                    color: n.read
                                        ? AppColors.main
                                        : AppColors.inkSoft),
                              ),
                            ],
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
