import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/providers.dart';
import '../theme/app_colors.dart';
import '../widgets/line_bind_sheet.dart';

/// 我的：個人資訊、群組管理（F1）、綁定 LINE、demo 視角切換。
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(repositoryProvider);
    final me = repo.currentUser;
    final group = repo.currentGroup;
    final isMember = group?.memberUids.contains(me.uid) ?? false;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
        children: [
          const Text('我的',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),

          // ---- 個人卡 ----
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(me.avatarEmoji, style: const TextStyle(fontSize: 44)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(me.displayName,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(
                          me.isGuest ? '訪客帳號' : 'LINE 已綁定 ✅',
                          style: TextStyle(
                            fontSize: 13,
                            color: me.isGuest
                                ? AppColors.pink
                                : AppColors.navySoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text('⭐ ${me.starTotal}',
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ),

          // ---- 訪客提醒 ----
          if (me.isGuest) ...[
            const SizedBox(height: 12),
            Card(
              color: AppColors.yellowSoft,
              child: ListTile(
                leading: const Text('💾', style: TextStyle(fontSize: 26)),
                title: const Text('資料尚未備份',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('綁定 LINE 保存星星與紀錄，換手機也不會消失',
                    style: TextStyle(fontSize: 13)),
                trailing: FilledButton(
                  onPressed: () => showLineBindSheet(context, ref),
                  child: const Text('綁定'),
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),
          const Text('我的群組',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),

          // ---- 群組卡（F1）----
          if (group != null && isMember)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(group.avatarEmoji,
                            style: const TextStyle(fontSize: 34)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(group.name,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w700)),
                        ),
                        Text('${group.memberUids.length} 人',
                            style:
                                const TextStyle(color: AppColors.navySoft)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final uid in group.memberUids)
                          Chip(
                            backgroundColor: AppColors.cream,
                            side: BorderSide.none,
                            label: Text(
                              '${repo.userOf(uid).avatarEmoji} ${repo.userOf(uid).displayName}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Clipboard.setData(
                                  ClipboardData(text: group.inviteLink));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('邀請連結已複製：${group.inviteLink}')),
                              );
                            },
                            icon: const Icon(Icons.link_rounded, size: 18),
                            label: const Text('邀請好友'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () => _confirmLeave(context, ref),
                          child: const Text('離開',
                              style: TextStyle(color: AppColors.navySoft)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          else ...[
            Card(
              child: ListTile(
                leading: const Text('👨‍👩‍👧‍👦', style: TextStyle(fontSize: 26)),
                title: const Text('建立群組',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('我們家、501室、情侶生活…',
                    style: TextStyle(fontSize: 13)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _createGroupFlow(context, ref),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Text('🔗', style: TextStyle(fontSize: 26)),
                title: const Text('加入群組',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('輸入邀請碼', style: TextStyle(fontSize: 13)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _joinGroupFlow(context, ref),
              ),
            ),
          ],

          const SizedBox(height: 24),
          const Text('Demo 視角切換',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text(
            '雛形限定：切換身分同時體驗發起人與接單人',
            style: TextStyle(fontSize: 13, color: AppColors.navySoft),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                for (final u in repo.knownUsers)
                  RadioListTile<String>(
                    value: u.uid,
                    // ignore: deprecated_member_use
                    groupValue: me.uid,
                    // ignore: deprecated_member_use
                    onChanged: (uid) => repo.switchUser(uid!),
                    activeColor: AppColors.pink,
                    title: Text('${u.avatarEmoji} ${u.displayName}'),
                    subtitle: Text(
                      u.isGuest ? '訪客' : 'LINE',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLeave(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('離開群組？'),
        content: const Text('離開後看不到群組的任務牆。'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('離開')),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(repositoryProvider).leaveGroup();
    }
  }

  Future<void> _createGroupFlow(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(repositoryProvider);
    // 訪客 gate：建立群組前必須綁定 LINE
    if (repo.currentUser.isGuest) {
      final bound = await showLineBindSheet(context, ref);
      if (!bound) return;
    }
    if (!context.mounted) return;

    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('建立群組'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '群組名稱，例如：我們家'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('建立'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    await repo.createGroup(name, '🏠');
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('群組「$name」建立完成 🎉')));
    }
  }

  Future<void> _joinGroupFlow(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('加入群組'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '輸入邀請碼，例如 HOME2026'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('加入'),
          ),
        ],
      ),
    );
    if (code == null || code.isEmpty || !context.mounted) return;
    final group = await ref.read(repositoryProvider).joinGroupByCode(code);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(group == null ? '找不到這個邀請碼 🙈' : '歡迎加入「${group.name}」！'),
        ),
      );
    }
  }
}
