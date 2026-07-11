import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../state/providers.dart';
import '../theme/app_colors.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(repositoryProvider);
    final items = repo.notifications;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              '訊息',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Text('還沒有訊息\n有人發起任務時會通知你 👀',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(color: AppColors.navySoft, height: 1.6)),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final n = items[i];
                      return Card(
                        color: n.read ? AppColors.white : AppColors.yellowSoft,
                        child: ListTile(
                          title: Text(
                            n.title,
                            style:
                                const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              '${n.body}\n${DateFormat('MM/dd HH:mm').format(n.createdAt)}',
                              style: const TextStyle(
                                  fontSize: 13, color: AppColors.navySoft),
                            ),
                          ),
                          isThreeLine: true,
                          onTap: () async {
                            await repo.markNotificationRead(n.id);
                            if (n.taskId != null && context.mounted) {
                              context.push('/task/${n.taskId}');
                            }
                          },
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
