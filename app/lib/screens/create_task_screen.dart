import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/task.dart';
import '../state/providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../widgets/app_svg_icons.dart';
import '../widgets/noise_background.dart';
import '../widgets/task_icon.dart';
import '../widgets/app_back_button.dart';

// 全套手繪線稿圖示
const _emojiChoices = [
  'asset:plate', // 洗碗
  'asset:trash', // 倒垃圾
  'asset:broom', // 掃地
  'asset:basket', // 洗衣
  'asset:cart', // 採買
  'asset:bento', // 備餐
  'asset:dog', // 遛狗
  'asset:books', // 讀書
  'asset:gift', // 禮物
  'asset:car', // 接送
];

/// v1.0 只開放三種獎勵類型
const _rewardTypeLabels = {
  RewardType.normal: '一般',
  RewardType.money: '現金',
  RewardType.mystery: '神秘禮物',
};

class CreateTaskScreen extends ConsumerStatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  ConsumerState<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends ConsumerState<CreateTaskScreen> {
  final _formKey = GlobalKey<ShadFormState>();
  final _countController = TextEditingController(text: '1');

  String _emoji = _emojiChoices.first;
  RewardType _rewardType = RewardType.normal;
  bool _anyoneCanClaim = true;

  @override
  void dispose() {
    _countController.dispose();
    super.dispose();
  }

  void _stepCount(int delta) {
    final current = int.tryParse(_countController.text) ?? 1;
    _countController.text = '${(current + delta).clamp(1, 99)}';
  }

  Future<void> _submit() async {
    final form = _formKey.currentState!;
    if (!form.saveAndValidate()) return;
    final values = form.value;

    final reward = (values['reward'] as String).trim();
    final repo = ref.read(repositoryProvider);
    await repo.createTask(
      title: (values['title'] as String).trim(),
      emoji: _emoji,
      rewardType: _rewardType,
      rewardLabel: _rewardType == RewardType.money ? '$reward 元' : reward,
      requiredCount: int.parse(values['count'] as String),
      deadline: values['deadline'] as DateTime?,
      assigneeUid: _anyoneCanClaim ? null : values['assignee'] as String?,
    );
    if (mounted) {
      context.pop();
      ShadToaster.of(context).show(
        const ShadToast(description: Text('🍿 任務已發佈到任務牆！')),
      );
    }
  }

  /// 獎勵內容欄位標題依類型變化
  String get _rewardFieldLabel => switch (_rewardType) {
        RewardType.money => '獎勵金額',
        RewardType.mystery => '獎勵內容（內容將保密）',
        _ => '獎勵內容',
      };

  /// 獎勵內容欄位依獎勵類型變化（label 已移到外層 _FieldLabel）
  Widget _buildRewardField() {
    return switch (_rewardType) {
      RewardType.money => ShadInputFormField(
          id: 'reward',
          placeholder: const Text('例如：50'),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          trailing: const Text('元',
              style: TextStyle(fontSize: 13, color: Colors.white54)),
          validator: (v) {
            final n = int.tryParse(v.trim());
            if (n == null || n < 1) return '請輸入獎勵金額';
            return null;
          },
        ),
      RewardType.mystery => ShadInputFormField(
          id: 'reward',
          placeholder: const Text('例如：神秘禮物、驚喜行程…'),
          validator: (v) => v.trim().isEmpty ? '請輸入獎勵內容' : null,
        ),
      _ => ShadInputFormField(
          id: 'reward',
          placeholder: const Text('例如：珍奶一杯、看一場電影…'),
          validator: (v) => v.trim().isEmpty ? '請輸入獎勵內容' : null,
        ),
    };
  }

  /// 數量 stepper 的 +/- 按鈕：白底黑框、無 hover 底、圓角同按鈕、icon 20px
  Widget _stepButton(String svg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.ink, width: 1),
        ),
        child: AppSvgIcon(svg, color: AppColors.ink, size: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(repositoryProvider);
    final members = repo.currentGroup?.memberUids
            .where((uid) => uid != repo.currentUser.uid)
            .map(repo.userOf)
            .toList() ??
        [];

    return Scaffold(
      backgroundColor: AppColors.ink,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: const AppBackButton(color: AppColors.white),
        title: const Text('發起任務',
            style: TextStyle(
                color: AppColors.pink,
                fontSize: AppType.label,
                fontWeight: FontWeight.w600)),
      ),
      body: NoiseBackground(
        child: ShadForm(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.fromLTRB(24,
                MediaQuery.of(context).padding.top + kToolbarHeight + 8, 24, 32),
            children: [
              const _FieldLabel('任務名稱'),
              ShadInputFormField(
                id: 'title',
                placeholder: const Text('例如：洗碗、倒垃圾、遛狗…'),
                validator: (v) => v.trim().isEmpty ? '請輸入任務名稱' : null,
              ),
              const SizedBox(height: 16),
              const _FieldLabel('圖示'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final e in _emojiChoices)
                    GestureDetector(
                      onTap: () => setState(() => _emoji = e),
                      child: Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color:
                              _emoji == e ? AppColors.pinkSoft : AppColors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _emoji == e
                                ? AppColors.pink
                                : AppColors.lightGray,
                            width: _emoji == e ? 2 : 1,
                          ),
                        ),
                        child: TaskIcon(icon: e, size: 26),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              const _FieldLabel('需要完成'),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _stepButton(kMinusSvg, () => _stepCount(-1)),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 96,
                      child: ShadInputFormField(
                        id: 'count',
                        controller: _countController,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(2),
                        ],
                        trailing: const Text('次',
                            style: TextStyle(fontSize: 13, color: Colors.white54)),
                        validator: (v) {
                          final n = int.tryParse(v);
                          if (n == null || n < 1) return '至少 1 次';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    _stepButton(kAddSvg, () => _stepCount(1)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const _FieldLabel('獎勵類型'),
              // 分段控制：容器同 input（diluteInk 底 + lightGray 1px 框），
              // 選中格只加粉色細框、微內縮、無填色
              Container(
                decoration: BoxDecoration(
                  color: AppColors.diluteInk,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.lightGray, width: 1),
                ),
                child: Row(
                  children: [
                    for (final entry in _rewardTypeLabels.entries)
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => setState(() => _rewardType = entry.key),
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: _rewardType == entry.key
                                    ? AppColors.pink
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              entry.value,
                              style: const TextStyle(
                                fontSize: AppType.body,
                                fontWeight: FontWeight.w500,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _FieldLabel(_rewardFieldLabel),
              _buildRewardField(),
              const SizedBox(height: 16),
              const _FieldLabel('截止日期（可不填）'),
              ShadDatePickerFormField(
                id: 'deadline',
                width: double.infinity,
                backgroundColor: AppColors.diluteInk,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(
                    child: Text('誰都可以接',
                        style: TextStyle(
                            fontSize: AppType.body,
                            fontWeight: FontWeight.w500,
                            color: AppColors.white)),
                  ),
                  ShadSwitch(
                    value: _anyoneCanClaim,
                    onChanged: (v) => setState(() => _anyoneCanClaim = v),
                  ),
                ],
              ),
              if (!_anyoneCanClaim) ...[
                const SizedBox(height: 8),
                const _FieldLabel('指定給'),
                ShadSelectFormField<String>(
                  id: 'assignee',
                  placeholder: const Text('選擇成員'),
                  options: [
                    for (final m in members)
                      ShadOption(
                        value: m.uid,
                        child: Text('${m.avatarEmoji} ${m.displayName}'),
                      ),
                  ],
                  selectedOptionBuilder: (context, value) {
                    final m = repo.userOf(value);
                    return Text('${m.avatarEmoji} ${m.displayName}');
                  },
                  validator: (v) =>
                      !_anyoneCanClaim && v == null ? '請選擇成員' : null,
                ),
              ],
              const SizedBox(height: 28),
              ShadButton(
                width: double.infinity,
                backgroundColor: AppColors.pink,
                foregroundColor: AppColors.white,
                onPressed: _submit,
                child: const Text('發佈任務'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

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
