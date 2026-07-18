import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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
    final userNo = repo.userNo;

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
                    separatorBuilder: (_, _) => const SizedBox(height: 16),
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
                            // 讀取狀態同款深底；未讀僅差在粉色 2px 邊框
                            color: AppColors.diluteInk,
                            borderRadius: BorderRadius.circular(8),
                            border: n.read
                                ? Border.all(color: AppColors.inkSoft, width: 1)
                                : Border.all(color: AppColors.pink, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                n.title,
                                style: const TextStyle(
                                    fontSize: AppType.body,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.white),
                              ),
                              const SizedBox(height: AppSpacing.sm), // 標題↔內文 8
                              Text(
                                n.body,
                                style: const TextStyle(
                                    fontSize: AppType.kicker,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white70),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                DateFormat('MM/dd HH:mm').format(n.createdAt),
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.main),
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
