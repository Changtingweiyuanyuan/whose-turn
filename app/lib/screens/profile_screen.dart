import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../state/providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../widgets/app_close_icon.dart';
import '../widgets/app_masthead.dart';
import '../widgets/app_svg_icons.dart';
import '../widgets/dashed_rule.dart';
import '../widgets/line_bind_sheet.dart';
import '../widgets/message_bubble_icon.dart';

/// 我的：個人資訊、群組管理（F1）、綁定 LINE、demo 視角切換。
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(repositoryProvider);
    final me = repo.currentUser;
    final group = repo.currentGroup;
    final isMember = group?.memberUids.contains(me.uid) ?? false;
    final userNo =
        (repo.currentGroup?.memberUids.indexOf(repo.currentUser.uid) ?? -1) + 1;

    return SafeArea(
      child: Column(
        children: [
          AppMasthead(title: '個人設定', userNo: userNo),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
              children: [
                // ---- 個人卡（深色塊，同「我的群組」）----
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.diluteInk,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.inkSoft, width: 1),
            ),
            child: Row(
              children: [
                Text(me.avatarEmoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(me.displayName,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white)),
											const SizedBox(height: AppSpacing.xs),
                      Text(
                        me.isGuest ? '訪客帳號' : 'LINE 已綁定',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.inkSoft,
                        ),
                      ),
                    ],
                  ),
                ),
                // 星星對齊「我的任務」刊頭右側：粉色星 20 + w800 白數字
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AppSvgIcon(kStarSvg, color: AppColors.pink, size: 20),
                    const SizedBox(width: 6),
                    Text('${me.starTotal}',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.white)),
                  ],
                ),
              ],
            ),
          ),

          // ---- 訪客提醒（淡藍 main 底、無框）----
          if (me.isGuest) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.main,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Text('💾', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('資料尚未備份',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink)),
                        SizedBox(height: 4),
                        Text('綁定 LINE 保存星星與紀錄，換手機也不會消失',
                            style: TextStyle(
                                fontSize: 13, color: AppColors.inkSoft)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 綁定鍵樣式同「離開」（ink），內容同 LINE 綁定 CTA
                  ShadButton(
                    backgroundColor: AppColors.ink,
                    foregroundColor: AppColors.white,
                    hoverBackgroundColor: AppColors.inkHover,
                    hoverForegroundColor: AppColors.white,
                    leading: const MessageBubbleIcon(
                        color: AppColors.white, size: 18),
                    onPressed: () => showLineBindSheet(context, ref),
                    child: const Text('用 LINE 綁定'),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),
          const Text('我的群組',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.white)),
          const SizedBox(height: 8),

          // ---- 群組卡（F1）：深色塊，同「完成紀錄」 ----
          if (group != null && isMember)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.diluteInk,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.inkSoft, width: 1),
              ),
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
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.white)),
                      ),
                      Text('${group.memberUids.length} 人',
                          style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final uid in group.memberUids)
                        // 家人 tag：白膠囊 + 黑(ink) 1.5 邊框 + ink 字（無 emoji）
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(999),
                            border:
                                Border.all(color: AppColors.ink, width: 1.5),
                          ),
                          child: Text(
                            repo.userOf(uid).displayName,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const DashedRule(color: AppColors.inkSoft),
                  const SizedBox(height: 12),
                  // 邀請好友 = pink 佔滿；離開 = ink 只佔文字寬；gap 8
                  Row(
                    children: [
                      Expanded(
                        child: ShadButton(
                          backgroundColor: AppColors.main,
                          foregroundColor: AppColors.ink,
                          hoverBackgroundColor: AppColors.mainDark,
                          hoverForegroundColor: AppColors.ink,
                          leading: const AppSvgIcon(kLinkSvg,
                              color: AppColors.ink, size: 20),
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: group.inviteLink));
                            ShadToaster.of(context).show(
                              ShadToast(
                                description:
                                    Text.rich(TextSpan(children: [
                                      const TextSpan(text: '邀請連結已複製'),
                                      const TextSpan(
                                          text: '：',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600)),
                                      TextSpan(text: group.inviteLink),
                                    ])),
                              ),
                            );
                          },
                          child: const Text('邀請好友'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ShadButton(
                        backgroundColor: AppColors.ink,
                        foregroundColor: AppColors.white,
                        hoverBackgroundColor: AppColors.inkHover,
                        hoverForegroundColor: AppColors.white,
                        onPressed: () => _confirmLeave(context, ref),
                        child: const Text('離開'),
                      ),
                    ],
                  ),
                ],
              ),
            )
          else ...[
            _ActionCard(
              emoji: '👨‍👩‍👧‍👦',
              title: '建立群組',
              subtitle: '我們家、501室、情侶生活…',
              onTap: () => _createGroupFlow(context, ref),
            ),
            const SizedBox(height: 8),
            _ActionCard(
              emoji: '🔗',
              title: '加入群組',
              subtitle: '輸入邀請碼',
              onTap: () => _joinGroupFlow(context, ref),
            ),
          ],

          const SizedBox(height: 24),
          const Text('Demo 視角切換',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white)),
          const SizedBox(height: 4),
          const Text(
            '雛形限定：切換身分同時體驗發起人與接單人',
            style: TextStyle(fontSize: 13, color: Colors.white70),
          ),
          const SizedBox(height: 8),
          ShadCard(
            padding: const EdgeInsets.all(16),
            child: ShadRadioGroup<String>(
              initialValue: me.uid,
              onChanged: (uid) {
                if (uid != null) repo.switchUser(uid);
              },
              items: [
                for (final u in repo.knownUsers)
                  ShadRadio(
                    value: u.uid,
                    label: Text(
                        '${u.avatarEmoji} ${u.displayName}（${u.isGuest ? '訪客' : 'LINE'}）'),
                  ),
              ],
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
    final confirmed = await showShadDialog<bool>(
      context: context,
      builder: (ctx) => ShadDialog.alert(
        backgroundColor: AppColors.diluteInk,
        gap: 12,
        closeIcon: const AppCloseIcon(color: AppColors.white, size: 22),
        closeIconPosition: const ShadPosition(top: 20, right: 20),
        title: const Text('離開群組？',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.white)),
        description: const Text('離開後看不到群組的任務看板。',
            style: TextStyle(color: Colors.white70)),
        actions: [
          ShadButton(
            backgroundColor: AppColors.ink,
            foregroundColor: AppColors.white,
            hoverBackgroundColor: AppColors.inkHover,
            hoverForegroundColor: AppColors.white,
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          ShadButton(
            backgroundColor: AppColors.pink,
            foregroundColor: AppColors.white,
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('離開'),
          ),
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

    final name = await _promptText(
      context,
      title: '建立群組',
      placeholder: '群組名稱，例如：我們家',
      confirmLabel: '建立',
    );
    if (name == null || name.isEmpty) return;
    await repo.createGroup(name, '🏠');
    if (context.mounted) {
      ShadToaster.of(context).show(
        ShadToast(description: Text('群組「$name」建立完成 🎉')),
      );
    }
  }

  Future<void> _joinGroupFlow(BuildContext context, WidgetRef ref) async {
    final code = await _promptText(
      context,
      title: '加入群組',
      placeholder: '輸入邀請碼，例如 HOME2026',
      confirmLabel: '加入',
    );
    if (code == null || code.isEmpty || !context.mounted) return;
    final group = await ref.read(repositoryProvider).joinGroupByCode(code);
    if (context.mounted) {
      ShadToaster.of(context).show(
        ShadToast(
          description:
              Text(group == null ? '找不到這個邀請碼 🙈' : '歡迎加入「${group.name}」！'),
        ),
      );
    }
  }

  Future<String?> _promptText(
    BuildContext context, {
    required String title,
    required String placeholder,
    required String confirmLabel,
  }) {
    final controller = TextEditingController();
    return showShadDialog<String>(
      context: context,
      builder: (ctx) => ShadDialog(
        closeIcon: const AppCloseIcon(color: AppColors.ink, size: 22),
        closeIconPosition: const ShadPosition(top: 20, right: 20),
        title: Text(title),
        actions: [
          ShadButton.outline(
            foregroundColor: AppColors.ink,
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          ShadButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(confirmLabel),
          ),
        ],
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: ShadInput(
            controller: controller,
            autofocus: true,
            placeholder: Text(placeholder),
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ShadCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.inkSoft)),
                ],
              ),
            ),
            const Icon(Iconsax.arrow_right_3_copy,
                size: 18, color: AppColors.inkSoft),
          ],
        ),
      ),
    );
  }
}
