import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// 集章式進度 —— 取代星星。
/// 次數 ≤ 8：一格一章（已確認=橘實心、進行中=粉描邊、未完成=淺灰空框）。
/// 次數 > 8：分段印章條 ████░░ 7/20，維持精確比例。
/// 檔名沿用 star_progress 以減少 import 變動；對外仍叫 StarProgress。
class StarProgress extends StatelessWidget {
  const StarProgress({
    super.key,
    required this.confirmed,
    required this.required,
    this.size = 18,
    this.showCount = true,
    this.active = false,
  });

  final int confirmed;
  final int required;
  final double size;
  final bool showCount;

  /// 任務進行中（已被接單），未完成的下一格用粉色描邊提示
  final bool active;

  @override
  Widget build(BuildContext context) {
    final countText = showCount
        ? Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              '$confirmed / $required',
              style: TextStyle(
                fontSize: size * 0.8,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
          )
        : null;

    if (required > 8) {
      return _SegmentBar(
        confirmed: confirmed,
        required: required,
        height: size * 0.5,
        trailing: countText,
      );
    }

    final stamp = size * 1.15;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < required; i++)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: _Stamp(
              size: stamp,
              state: i < confirmed
                  ? _StampState.done
                  : (active && i == confirmed
                      ? _StampState.next
                      : _StampState.empty),
            ),
          ),
        ?countText,
      ],
    );
  }
}

enum _StampState { done, next, empty }

class _Stamp extends StatelessWidget {
  const _Stamp({required this.size, required this.state});

  final double size;
  final _StampState state;

  @override
  Widget build(BuildContext context) {
    final (bg, border) = switch (state) {
      _StampState.done => (AppColors.orange, AppColors.orange),
      _StampState.next => (Colors.transparent, AppColors.pink),
      _StampState.empty => (Colors.transparent, AppColors.starEmpty),
    };
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(
          color: border,
          width: state == _StampState.next ? 2 : 1.5,
        ),
      ),
      child: state == _StampState.done
          ? Icon(Icons.check_rounded, size: size * 0.7, color: AppColors.white)
          : null,
    );
  }
}

class _SegmentBar extends StatelessWidget {
  const _SegmentBar({
    required this.confirmed,
    required this.required,
    required this.height,
    this.trailing,
  });

  final int confirmed;
  final int required;
  final double height;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: height * 10,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Row(
              children: [
                Expanded(
                  flex: confirmed,
                  child: Container(height: height, color: AppColors.orange),
                ),
                Expanded(
                  flex: (required - confirmed).clamp(0, required),
                  child: Container(height: height, color: AppColors.lightGray),
                ),
              ],
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}
