import 'package:flutter/material.dart';

import '../constants/personal_icons.dart';
import '../theme/app_colors.dart';
import 'person_avatar.dart';

/// 個人圖示選擇器 —— 呈現同「發起任務」的圖示：白圓底、
/// 選中＝DEEDE4 2px 邊框 + 50% DEEDE4 疊層；笑臉橘色改愛心綠。
///
/// 已被其他成員選走的（[taken]）像 disabled 按鈕：變暗色、排到最後、點擊沒反應。
class PersonalIconPicker extends StatelessWidget {
  const PersonalIconPicker({
    super.key,
    required this.selected,
    required this.onSelect,
    this.taken = const {},
  });

  /// 目前選中的圖示（'asset:smiley_xxx'），未選為 null。
  final String? selected;
  final ValueChanged<String> onSelect;

  /// 已被其他成員選走的圖示。
  final Set<String> taken;

  /// 與任務卡片左側圖示同寬高。
  static const double _cell = 44;
  static const double _icon = 28;

  @override
  Widget build(BuildContext context) {
    // 可選的維持原順序在前，已被選走的排到最後。
    final available = kPersonalIcons.where((i) => !taken.contains(i));
    final used = kPersonalIcons.where((i) => taken.contains(i));
    final ordered = [...available, ...used];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final icon in ordered)
          if (taken.contains(icon))
            // 已被選走：變暗、不可點（像 disabled 按鈕）
            Opacity(
              opacity: 0.4,
              child: Container(
                width: _cell,
                height: _cell,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.inkSoft,
                  shape: BoxShape.circle,
                ),
                child: PersonAvatar(icon,
                    size: _icon, fillColor: AppColors.ink),
              ),
            )
          else
            GestureDetector(
              onTap: () => onSelect(icon),
              child: Container(
                width: _cell,
                height: _cell,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected == icon
                        ? AppColors.greenMist
                        : AppColors.lightGray,
                    width: selected == icon ? 2 : 1,
                  ),
                ),
                // 選中：icon 上蓋一層 50% 淡綠（同發起任務）
                foregroundDecoration: selected == icon
                    ? const BoxDecoration(
                        color: Color(0x80DEEDE4),
                        shape: BoxShape.circle,
                      )
                    : null,
                child: PersonAvatar(icon,
                    size: _icon,
                    fillColor: AppColors.ink,
                    orangeColor: AppColors.green),
              ),
            ),
      ],
    );
  }
}
