import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../state/providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../widgets/app_masthead.dart';
import '../widgets/dashed_rule.dart';

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
                        style:
                            TextStyle(color: AppColors.inkSoft, height: 1.6)),
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
                        // 1px 紋理邊框：同任務詳情的任務內容 block
                        child: Container(
                          padding: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppRadius.card),
                            image: const DecorationImage(
                              image: AssetImage(
                                  'assets/images/card_border.png'),
                              repeat: ImageRepeat.repeat,
                              fit: BoxFit.none,
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.card - 1),
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
                                      color: AppColors.ink),
                                ),
                                // 標題下虛線：同任務內容 block（上下 gap 6）
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 6),
                                  child: DashedRule(
                                      color: Color(0xFFF3F3F3), thickness: 1),
                                ),
                                Text(
                                  n.body,
                                  style: const TextStyle(
                                      fontSize: AppType.kicker,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.inkSoft),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  DateFormat('MM/dd HH:mm')
                                      .format(n.createdAt),
                                  style: const TextStyle(
                                      fontSize: 12, color: AppColors.inkSoft),
                                ),
                              ],
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
