import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../models/task.dart';
import '../state/providers.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _rewardController = TextEditingController();

  String _emoji = _emojiChoices.first;
  int _requiredCount = 1;
  RewardType _rewardType = RewardType.normal;
  DateTime? _deadline;
  bool _anyoneCanClaim = true;
  String? _assigneeUid;

  @override
  void dispose() {
    _titleController.dispose();
    _rewardController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final repo = ref.read(repositoryProvider);
    await repo.createTask(
      title: _titleController.text.trim(),
      emoji: _emoji,
      rewardType: _rewardType,
      rewardLabel: _rewardController.text.trim(),
      requiredCount: _requiredCount,
      deadline: _deadline,
      assigneeUid: _anyoneCanClaim ? null : _assigneeUid,
    );
    if (mounted) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🍿 任務已發佈到任務牆！')),
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
      appBar: AppBar(title: const Text('發起任務')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          children: [
            const _FieldLabel('任務名稱'),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: '例如：洗碗、倒垃圾、遛狗…'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? '請輸入任務名稱' : null,
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
              children: [
                _StepperButton(
                  icon: Icons.remove_rounded,
                  onTap: () => setState(
                      () => _requiredCount = (_requiredCount - 1).clamp(1, 99)),
                ),
                Container(
                  width: 72,
                  alignment: Alignment.center,
                  child: Text(
                    '$_requiredCount',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                ),
                _StepperButton(
                  icon: Icons.add_rounded,
                  onTap: () => setState(
                      () => _requiredCount = (_requiredCount + 1).clamp(1, 99)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const _FieldLabel('獎勵內容'),
            TextFormField(
              controller: _rewardController,
              decoration:
                  const InputDecoration(hintText: '例如：珍奶一杯、50 元、神秘禮物…'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? '請輸入獎勵內容' : null,
            ),
            const SizedBox(height: 16),
            const _FieldLabel('獎勵類型'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in _rewardTypeLabels.entries)
                  ChoiceChip(
                    label: Text(entry.value),
                    selected: _rewardType == entry.key,
                    selectedColor: AppColors.pink,
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _rewardType == entry.key
                          ? AppColors.white
                          : AppColors.navy,
                    ),
                    onSelected: (_) => setState(() => _rewardType = entry.key),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const _FieldLabel('截止日期（可不填）'),
            OutlinedButton.icon(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) setState(() => _deadline = picked);
              },
              icon: const Icon(Icons.calendar_today_rounded, size: 18),
              label: Text(
                _deadline == null
                    ? '選擇日期'
                    : DateFormat('yyyy/MM/dd').format(_deadline!),
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('誰都可以接',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              activeThumbColor: AppColors.pink,
              value: _anyoneCanClaim,
              onChanged: (v) => setState(() => _anyoneCanClaim = v),
            ),
            if (!_anyoneCanClaim) ...[
              const _FieldLabel('指定給'),
              DropdownButtonFormField<String>(
                initialValue: _assigneeUid,
                hint: const Text('選擇成員'),
                items: [
                  for (final m in members)
                    DropdownMenuItem(
                      value: m.uid,
                      child: Text('${m.avatarEmoji} ${m.displayName}'),
                    ),
                ],
                onChanged: (v) => setState(() => _assigneeUid = v),
                validator: (v) => !_anyoneCanClaim && v == null ? '請選擇成員' : null,
              ),
            ],
            const SizedBox(height: 28),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.yellow,
                foregroundColor: AppColors.navy,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
              onPressed: _submit,
              child: const Text('發佈任務'),
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

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.lightGray),
        ),
        child: Icon(icon, color: AppColors.navy),
      ),
    );
  }
}
