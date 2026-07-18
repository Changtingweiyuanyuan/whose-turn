import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../state/providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../widgets/app_close_icon.dart';
import '../widgets/app_masthead.dart';
import '../widgets/app_svg_icons.dart';
import '../widgets/dashed_rule.dart';
import '../widgets/group_dialogs.dart';
import '../widgets/line_bind_sheet.dart';
import '../widgets/message_bubble_icon.dart';
import '../widgets/person_avatar.dart';

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
                PersonAvatar(me.avatarEmoji, size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(me.displayName,
                          style: const TextStyle(
                              fontSize: AppType.body,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white)),
											const SizedBox(height: AppSpacing.xs),
                      Text(
                        me.isGuest ? '訪客帳號' : 'LINE 已綁定，紀錄永久保存',
                        style: TextStyle(
                          fontSize: AppType.kicker,
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
                            fontSize: AppType.title,
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
                  const AppAssetIcon('assets/icons/cloud_phone_exchange.svg',
                      size: 44, fillColor: AppColors.ink),
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
                                fontSize: AppType.kicker, color: AppColors.inkSoft)),
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
                  fontSize: AppType.body,
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
                      const AppAssetIcon('assets/icons/teamwork_clap.svg',
                          size: 44),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(group.name,
                            style: const TextStyle(
                                fontSize: AppType.body,
                                fontWeight: FontWeight.w600,
                                color: AppColors.white)),
                      ),
                      Text('${group.memberUids.length} 人',
                          style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: 12),
									const DashedRule(color: AppColors.inkSoft),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final uid in group.memberUids)
                        // 家人 tag：ink 膠囊 + 個人圖示 + 白字；自己的框橘色
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.ink,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                                color: uid == me.uid
                                    ? AppColors.white
                                    : AppColors.inkSoft,
                                width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 深底保留原色；size 16 不撐高 tag
                              PersonAvatar(repo.userOf(uid).avatarEmoji,
                                  size: 16),
                              const SizedBox(width: 8),
                              Text(
                                repo.userOf(uid).displayName,
                                style: const TextStyle(
                                    fontSize: AppType.kicker,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.white),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  //const SizedBox(height: 12),
                  //const DashedRule(color: AppColors.inkSoft),
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
              icon: 'assets/icons/human_resources_hierarchy.svg',
              title: '建立群組［建立後無法修改］',
              subtitle: '可愛的家、305 室...',
              onTap: () => _createGroupFlow(context, ref),
            ),
            const SizedBox(height: 8),
            _ActionCard(
              icon: 'assets/icons/business_agreement.svg',
              title: '加入群組',
              subtitle: '輸入邀請碼',
              onTap: () => _joinGroupFlow(context, ref),
            ),
          ],

          const SizedBox(height: 24),
          const Text('Demo 視角切換',
              style: TextStyle(
                  fontSize: AppType.body,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white)),
          const SizedBox(height: 4),
          const Text(
            '雛形限定：切換身分同時體驗發起人與接單人',
            style: TextStyle(fontSize: AppType.kicker, color: Colors.white70),
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
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PersonAvatar(u.avatarEmoji,
                            size: 20, fillColor: AppColors.ink),
                        const SizedBox(width: 6),
                        Text(
                            '${u.displayName}（${u.isGuest ? '訪客' : 'LINE'}）'),
                      ],
                    ),
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
      // opaque 預設 true 會遮蔽背後頁面（底層變白畫布）；設 false 才看得到原頁
      opaque: false,
      // 套件預設 barrier 0xcc000000 太濃，改回正常半透明遮罩
      barrierColor: Colors.black54,
      builder: (ctx) => ShadDialog.alert(
        backgroundColor: AppColors.diluteInk,
        radius: BorderRadius.circular(AppRadius.card),
        // tiny 斷點預設會拿掉圓角，關掉才會保留 8px
        removeBorderRadiusWhenTiny: false,
        // content 與 actions 之間 24；標題與內文的間距在 title 欄內自控
        gap: AppSpacing.lg,
        closeIcon: const AppCloseIcon(color: AppColors.white, size: 22),
        closeIconPosition: const ShadPosition(top: 20, right: 20),
        // 併進 title 欄，避免 description 的 24px gap 撐開；文字大小自訂
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('確定要離開群組？',
                style: TextStyle(
                    fontSize: AppType.body,
                    fontWeight: FontWeight.w500,
                    color: AppColors.white)),
            SizedBox(height: 12),
            Text('離開後看不到群組的任務看板。',
                style: TextStyle(
                    fontSize: AppType.label,
                    fontWeight: FontWeight.w400,
                    color: Colors.white70)),
          ],
        ),
        // CTA 橫排靠右、不佔滿寬度、間距對齊其他 CTA
        expandActionsWhenTiny: false,
        actionsAxis: Axis.horizontal,
        actionsMainAxisAlignment: MainAxisAlignment.end,
        actionsGap: AppSpacing.sm,
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

    final message = await showCreateGroupDialog(context, ref);
    if (message != null && context.mounted) {
      ShadToaster.of(context).show(ShadToast(description: Text(message)));
    }
  }

  Future<void> _joinGroupFlow(BuildContext context, WidgetRef ref) async {
    final message = await showJoinGroupDialog(context, ref);
    if (message != null && context.mounted) {
      ShadToaster.of(context).show(ShadToast(description: Text(message)));
    }
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  /// 個人圖示 asset 路徑（assets/icons/xxx.svg）。
  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // 樣式對齊「資料尚未備份」：main 淺藍底、無框、ink 圖示與標題
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.main,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            AppAssetIcon(icon, size: 44, fillColor: AppColors.ink),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, color: AppColors.ink)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: AppType.kicker, color: AppColors.inkSoft)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // 前往箭頭：大小對齊星星（20）、ink
            const AppSvgIcon(kArrowNextSvg, color: AppColors.ink, size: 20),
          ],
        ),
      ),
    );
  }
}
