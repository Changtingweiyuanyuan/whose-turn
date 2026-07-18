import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/group.dart';
import '../state/providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import 'app_close_icon.dart';
import 'personal_icon_picker.dart';

enum _GroupDialogMode { create, join }

/// 建立群組：填名稱 + 選個人圖示。回傳完成訊息（供呼叫端跳 toast），取消為 null。
Future<String?> showCreateGroupDialog(BuildContext context, WidgetRef ref) {
  return _show(context, ref, _GroupDialogMode.create);
}

/// 加入群組：輸入邀請碼（debounce 查詢）→ 選個人圖示。已被選走的圖示會 disabled。
Future<String?> showJoinGroupDialog(BuildContext context, WidgetRef ref) {
  return _show(context, ref, _GroupDialogMode.join);
}

Future<String?> _show(
    BuildContext context, WidgetRef ref, _GroupDialogMode mode) {
  return showShadDialog<String>(
    context: context,
    opaque: false,
    barrierColor: Colors.black54,
    builder: (_) => _GroupDialog(ref: ref, mode: mode),
  );
}

class _GroupDialog extends StatefulWidget {
  const _GroupDialog({required this.ref, required this.mode});

  final WidgetRef ref;
  final _GroupDialogMode mode;

  @override
  State<_GroupDialog> createState() => _GroupDialogState();
}

class _GroupDialogState extends State<_GroupDialog> {
  final _controller = TextEditingController();
  Timer? _debounce;

  String? _selectedIcon;

  // 加入流程：邀請碼查詢結果
  Group? _foundGroup;
  bool _notFound = false;

  bool get _isCreate => widget.mode == _GroupDialogMode.create;

  /// 建立時一律顯示 picker；加入時要先查到群組才顯示。
  bool get _showPicker => _isCreate || _foundGroup != null;

  /// 已被其他成員選走的個人圖示。
  Set<String> get _taken {
    final g = _foundGroup;
    if (g == null) return const {};
    final repo = widget.ref.read(repositoryProvider);
    return {
      for (final uid in g.memberUids)
        if (repo.userOf(uid).avatarEmoji.startsWith('asset:'))
          repo.userOf(uid).avatarEmoji,
    };
  }

  bool get _canConfirm {
    if (_selectedIcon == null) return false;
    if (_isCreate) return _controller.text.trim().isNotEmpty;
    return _foundGroup != null;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onCodeChanged(String value) {
    _debounce?.cancel();
    setState(() {
      _foundGroup = null;
      _notFound = false;
      _selectedIcon = null;
    });
    if (value.trim().isEmpty) return;
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final g =
          await widget.ref.read(repositoryProvider).findGroupByCode(value);
      if (!mounted) return;
      setState(() {
        _foundGroup = g;
        _notFound = g == null;
      });
    });
  }

  Future<void> _confirm() async {
    final repo = widget.ref.read(repositoryProvider);
    if (_isCreate) {
      final name = _controller.text.trim();
      await repo.createGroup(name, personalIcon: _selectedIcon);
      if (mounted) Navigator.pop(context, '群組「$name」建立完成 🎉');
    } else {
      final group = await repo.joinGroupByCode(_controller.text,
          personalIcon: _selectedIcon);
      if (mounted) {
        Navigator.pop(
            context, group == null ? '找不到這個邀請碼 🙈' : '歡迎加入「${group.name}」！');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ShadDialog(
      backgroundColor: AppColors.diluteInk,
      radius: BorderRadius.circular(AppRadius.card),
      removeBorderRadiusWhenTiny: false,
      gap: AppSpacing.md,
      closeIcon: const AppCloseIcon(color: AppColors.white, size: 22),
      closeIconPosition: const ShadPosition(top: 20, right: 20),
      title: Text(_isCreate ? '建立群組' : '加入群組',
          style: const TextStyle(
              fontSize: AppType.body,
              fontWeight: FontWeight.w500,
              color: AppColors.white)),
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
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ShadButton(
          backgroundColor: AppColors.pink,
          foregroundColor: AppColors.white,
          onPressed: _canConfirm ? _confirm : null,
          child: Text(_isCreate ? '建立' : '加入'),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _DialogLabel(_isCreate ? '群組名稱' : '邀請碼'),
          ShadInput(
            controller: _controller,
            autofocus: true,
            placeholder: Text(_isCreate ? '例如：可愛的家、305 室...' : '例如 HOME2026'),
            onChanged: _isCreate
                ? (_) => setState(() {})
                : _onCodeChanged,
          ),
          if (!_isCreate && _notFound) ...[
            const SizedBox(height: 8),
            const Text('找不到這個邀請碼 🙈',
                style: TextStyle(color: AppColors.pink, fontSize: AppType.label)),
          ],
          if (_showPicker) ...[
            const SizedBox(height: AppSpacing.md),
            const _DialogLabel('個人圖示'),
            PersonalIconPicker(
              selected: _selectedIcon,
              taken: _taken,
              onSelect: (i) => setState(() => _selectedIcon = i),
            ),
          ],
        ],
      ),
    );
  }
}

class _DialogLabel extends StatelessWidget {
  const _DialogLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: AppType.body,
          fontWeight: FontWeight.w500,
          color: AppColors.white,
        ),
      ),
    );
  }
}
