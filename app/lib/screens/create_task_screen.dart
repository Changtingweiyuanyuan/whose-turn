import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/task.dart';
import '../state/providers.dart';
import '../widgets/app_back_button.dart';
import '../theme/app_colors.dart';

const _emojiChoices = ['🍵', '🗑️', '🐶', '🧺', '🧹', '🛒', '🍱', '🎁', '📚', '🚗'];

const _rewardTypeLabels = {
  RewardType.normal: '一般',
  RewardType.mystery: '神秘',
  RewardType.money: '金額',
  RewardType.privilege: '特權',
  RewardType.experience: '體驗',
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

    final repo = ref.read(repositoryProvider);
    await repo.createTask(
      title: (values['title'] as String).trim(),
      emoji: _emoji,
      rewardType: values['rewardType'] as RewardType,
      rewardLabel: (values['reward'] as String).trim(),
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

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(repositoryProvider);
    final members = repo.currentGroup?.memberUids
            .where((uid) => uid != repo.currentUser.uid)
            .map(repo.userOf)
            .toList() ??
        [];

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('發起任務'),
      ),
      body: ShadForm(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          children: [
            ShadInputFormField(
              id: 'title',
              label: const Text('任務名稱'),
              placeholder: const Text('例如：洗碗、倒垃圾、遛狗…'),
              validator: (v) => v.trim().isEmpty ? '請輸入任務名稱' : null,
            ),
            const SizedBox(height: 16),
            const _FieldLabel('圖示'),
            Wrap(
              spacing: 8,
              children: [
                for (final e in _emojiChoices)
                  GestureDetector(
                    onTap: () => setState(() => _emoji = e),
                    child: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _emoji == e ? AppColors.pinkSoft : AppColors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _emoji == e ? AppColors.pink : AppColors.lightGray,
                          width: _emoji == e ? 2 : 1,
                        ),
                      ),
                      child: Text(e, style: const TextStyle(fontSize: 22)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const _FieldLabel('完成次數'),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShadButton.outline(
                  size: ShadButtonSize.sm,
                  onPressed: () => _stepCount(-1),
                  child: const Icon(LucideIcons.minus, size: 16),
                ),
                SizedBox(
                  width: 96,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ShadInputFormField(
                      id: 'count',
                      controller: _countController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800),
                      validator: (v) {
                        final n = int.tryParse(v);
                        if (n == null || n < 1) return '至少 1 次';
                        return null;
                      },
                    ),
                  ),
                ),
                ShadButton.outline(
                  size: ShadButtonSize.sm,
                  onPressed: () => _stepCount(1),
                  child: const Icon(LucideIcons.plus, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ShadInputFormField(
              id: 'reward',
              label: const Text('獎勵內容'),
              placeholder: const Text('例如：珍奶一杯、50 元、神秘禮物…'),
              validator: (v) => v.trim().isEmpty ? '請輸入獎勵內容' : null,
            ),
            const SizedBox(height: 16),
            ShadRadioGroupFormField<RewardType>(
              id: 'rewardType',
              label: const Text('獎勵類型'),
              initialValue: RewardType.normal,
              axis: Axis.horizontal,
              items: [
                for (final entry in _rewardTypeLabels.entries)
                  ShadRadio(
                    value: entry.key,
                    label: Text(entry.value),
                  ),
              ],
              validator: (v) => v == null ? '請選擇獎勵類型' : null,
            ),
            const SizedBox(height: 16),
            ShadDatePickerFormField(
              id: 'deadline',
              label: const Text('截止日期（可不填）'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(
                  child: Text('誰都可以接',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                ShadSwitch(
                  value: _anyoneCanClaim,
                  onChanged: (v) => setState(() => _anyoneCanClaim = v),
                ),
              ],
            ),
            if (!_anyoneCanClaim) ...[
              const SizedBox(height: 8),
              ShadSelectFormField<String>(
                id: 'assignee',
                label: const Text('指定給'),
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
            ShadButton.secondary(
              width: double.infinity,
              size: ShadButtonSize.lg,
              onPressed: _submit,
              child: const Text(
                '發佈任務',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
            ),
          ],
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
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.navySoft,
        ),
      ),
    );
  }
}
