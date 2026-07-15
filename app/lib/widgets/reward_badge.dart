import 'package:flutter/material.dart';

import '../models/task.dart';
import '../theme/app_colors.dart';

/// 獎勵標籤 —— 三種印刷感造型：
/// 一般 = 貼紙（方角色塊）／現金 = 票券（左右撕票缺口）／神秘 = 封蠟刮刮樂。
/// 設計原則：Reward 醒目、hover 不變色。
class RewardBadge extends StatelessWidget {
  const RewardBadge({
    super.key,
    required this.task,
    required this.viewerUid,
    this.large = false,
  });

  final Task task;
  final String viewerUid;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final label = task.rewardLabelFor(viewerUid);
    final fontSize = large ? 15.0 : 13.0;
    final padV = large ? 6.0 : 4.0;
    final padH = large ? 14.0 : 11.0;

    switch (task.rewardType) {
      case RewardType.mystery:
        final hidden = label == '???';
        return _Sticker(
          bg: AppColors.ink,
          fg: AppColors.white,
          padV: padV,
          padH: padH,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('✦',
                  style: TextStyle(fontSize: fontSize, color: AppColors.pink)),
              const SizedBox(width: 5),
              Text(
                hidden ? '神秘禮物' : label,
                style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white),
              ),
            ],
          ),
        );
      case RewardType.money:
        return _Ticket(
          padV: padV,
          padH: padH,
          child: Text(
            label,
            style: TextStyle(
                fontSize: fontSize + 1,
                fontWeight: FontWeight.w800,
                color: AppColors.ink),
          ),
        );
      default:
        return _Sticker(
          bg: AppColors.mainSoft,
          fg: AppColors.ink,
          padV: padV,
          padH: padH,
          child: Text(
            label,
            style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: AppColors.ink),
          ),
        );
    }
  }
}

class _Sticker extends StatelessWidget {
  const _Sticker({
    required this.bg,
    required this.fg,
    required this.padV,
    required this.padH,
    required this.child,
  });

  final Color bg;
  final Color fg;
  final double padV;
  final double padH;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: child,
    );
  }
}

/// 票券造型：黃底 + 左右各一個半圓撕票缺口。
class _Ticket extends StatelessWidget {
  const _Ticket({required this.padV, required this.padH, required this.child});

  final double padV;
  final double padH;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _TicketClipper(),
      child: Container(
        color: AppColors.orange,
        padding: EdgeInsets.symmetric(horizontal: padH + 4, vertical: padV),
        child: child,
      ),
    );
  }
}

class _TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final r = size.height * 0.22;
    final cy = size.height / 2;
    return Path.combine(
      PathOperation.difference,
      Path()
        ..addRRect(RRect.fromRectAndRadius(
            Offset.zero & size, const Radius.circular(4))),
      Path()
        ..addOval(Rect.fromCircle(center: Offset(0, cy), radius: r))
        ..addOval(Rect.fromCircle(center: Offset(size.width, cy), radius: r)),
    );
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
