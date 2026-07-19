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
import '../widgets/person_avatar.dart';
import '../widgets/task_icon.dart';
import '../widgets/app_back_button.dart';

// 全套線稿圖示（Streamline Freehand duotone）
const _emojiChoices = [
  'asset:cleaning',
  'asset:trash',
  'asset:home',
  'asset:cart_check',
  'asset:shop_cart',
  'asset:book',
  'asset:newspaper',
  'asset:piggy_bank',
  'asset:price_tag',
  'asset:handshake',
  'asset:lucky_cat',
  'asset:camera',
  'asset:clapboard',
  'asset:game_controller',
  'asset:karaoke',
  'asset:stopwatch',
  'asset:magic_wand',
  'asset:pen_draw',
  'asset:code',
  'asset:earpods',
  'asset:ferris_wheel',
  'asset:hanger',
  'asset:fork_knife',
  'asset:dog_house',
  'asset:mario_mushroom',
  'asset:ball',
  'asset:clown',
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
  RewardType? _hoveredReward;
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
        const ShadToast(description: Text('任務已發佈到任務看板！')),
      );
    }
  }

  /// 獎勵內容欄位標題依類型變化
  String get _rewardFieldLabel => switch (_rewardType) {
        RewardType.money => '獎勵金額',
        RewardType.mystery => '獎勵內容［內容將保密］',
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
              style: TextStyle(
                  fontSize: AppType.kicker, color: AppColors.inkSoft)),
          validator: (v) {
            final n = int.tryParse(v.trim());
            if (n == null || n < 1) return '請輸入獎勵金額';
            return null;
          },
        ),
      RewardType.mystery => ShadInputFormField(
          id: 'reward',
          placeholder: const Text('例如：神秘禮物、驚喜行程...'),
          validator: (v) => v.trim().isEmpty ? '請輸入獎勵內容' : null,
        ),
      _ => ShadInputFormField(
          id: 'reward',
          placeholder: const Text('例如：珍奶一杯、看一場電影...'),
          validator: (v) => v.trim().isEmpty ? '請輸入獎勵內容' : null,
        ),
    };
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
      // header 對齊任務詳情：F3F3F3 底、綠返回鍵、粉花 + 綠字標題
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F3F3),
        foregroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: true,
        leading: const AppBackButton(),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppAssetIcon('assets/icons/flower_green.svg', size: 16),
            SizedBox(width: 6),
            Text('發起任務',
                style: TextStyle(
                    color: AppColors.green,
                    fontSize: AppType.label,
                    fontWeight: FontWeight.w500,
                    letterSpacing: AppType.spacing)),
          ],
        ),
      ),
      body: NoiseBackground(
        child: ShadForm(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            children: [
              const _FieldLabel('任務名稱'),
              ShadInputFormField(
                id: 'title',
                placeholder: const Text('例如：洗碗、倒垃圾、遛狗...'),
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
                          color: AppColors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _emoji == e
                                ? AppColors.greenMist
                                : AppColors.lightGray,
                            width: _emoji == e ? 2 : 1,
                          ),
                        ),
                        // 選中：icon 上蓋一層 50% 淡綠
                        foregroundDecoration: _emoji == e
                            ? const BoxDecoration(
                                color: Color(0x80DEEDE4),
                                shape: BoxShape.circle,
                              )
                            : null,
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
                    _StepButton(svg: kMinusSvg, onTap: () => _stepCount(-1)),
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
                            style: TextStyle(
                  fontSize: AppType.kicker, color: AppColors.inkSoft)),
                        validator: (v) {
                          final n = int.tryParse(v);
                          if (n == null || n < 1) return '至少 1 次';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StepButton(svg: kAddSvg, onTap: () => _stepCount(1)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const _FieldLabel('獎勵類型'),
              // 分段控制：容器同 input（F3F3F3 底），選中＝愛心綠
              Container(
                padding: const EdgeInsets.all(6), // 距容器 6px
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F3F3),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.lightGray, width: 1),
                ),
                child: Row(
                  spacing: 4, // 選項之間 gap 4px
                  children: [
                    for (final entry in _rewardTypeLabels.entries)
                      Expanded(
                        child: MouseRegion(
                          onEnter: (_) =>
                              setState(() => _hoveredReward = entry.key),
                          onExit: (_) =>
                              setState(() => _hoveredReward = null),
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () =>
                                setState(() => _rewardType = entry.key),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                // 選中=愛心綠底、hover=半透明黑、其餘透明
                                color: _rewardType == entry.key
                                    ? AppColors.green
                                    : (_hoveredReward == entry.key
                                        ? const Color(0x0F000000)
                                        : Colors.transparent),
                              ),
                              child: Text(
                                entry.value,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: _rewardType == entry.key
                                      ? AppColors.white
                                      : AppColors.ink,
                                ),
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
              const _FieldLabel('截止日期［可不填］'),
              ShadDatePickerFormField(
                id: 'deadline',
                width: double.infinity,
                backgroundColor: const Color(0xFFF3F3F3),
                foregroundColor: AppColors.ink,
                hoverBackgroundColor: const Color(0xFFF3F3F3),
                hoverForegroundColor: AppColors.ink,
                placeholder: const Text('選擇日期'),
                leading: const AppSvgIcon(kCalendarSvg,
                    color: AppColors.inkSoft, size: 18),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(
                    child: Text('誰都可以接',
                        style: TextStyle(
                            fontSize: AppType.body,
                            fontWeight: FontWeight.w500,
                            color: AppColors.ink)),
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
                LayoutBuilder(
                  builder: (context, constraints) =>
                      ShadSelectFormField<String>(
                    id: 'assignee',
                    // 撐滿：trigger 與 popover 都用可用寬度，不會溢出
                    minWidth: constraints.maxWidth,
                    maxWidth: constraints.maxWidth,
                    decoration:
                        const ShadDecoration(color: Color(0xFFF3F3F3)),
                    placeholder: const Text('選擇成員',
                        style: TextStyle(color: AppColors.inkSoft)),
                    options: [
                      for (final m in members)
                        ShadOption(
                          value: m.uid,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              PersonAvatar(m.avatarEmoji, size: 20),
                              const SizedBox(width: 6),
                              Text(m.displayName),
                            ],
                          ),
                        ),
                    ],
                    selectedOptionBuilder: (context, value) {
                      final m = repo.userOf(value);
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PersonAvatar(m.avatarEmoji, size: 20),
                          const SizedBox(width: 6),
                          Text(m.displayName,
                              style: const TextStyle(color: AppColors.ink)),
                        ],
                      );
                    },
                    validator: (v) =>
                        !_anyoneCanClaim && v == null ? '請選擇成員' : null,
                  ),
                ),
              ],
              const SizedBox(height: 28),
              ShadButton(
                width: double.infinity,
                backgroundColor: AppColors.green,
                foregroundColor: AppColors.bg,
                hoverBackgroundColor: AppColors.greenDark,
                hoverForegroundColor: AppColors.bg,
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

/// 數量 stepper 的 +/- 按鈕：愛心綠底、白 icon，hover 壓深綠。
/// IntrinsicHeight Row 內會撐到輸入框高度。
class _StepButton extends StatefulWidget {
  const _StepButton({required this.svg, required this.onTap});

  final String svg;
  final VoidCallback onTap;

  @override
  State<_StepButton> createState() => _StepButtonState();
}

class _StepButtonState extends State<_StepButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final bg = _hover ? AppColors.greenDark : AppColors.green;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Container(
          width: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(6),
          ),
          child: AppSvgIcon(widget.svg, color: AppColors.white, size: 20),
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
        // 對齊「完成紀錄 (n)」標題：body、w500、Ink
        style: const TextStyle(
          fontSize: AppType.body,
          fontWeight: FontWeight.w500,
          color: AppColors.ink,
        ),
      ),
    );
  }
}
