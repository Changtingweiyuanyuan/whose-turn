import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../state/providers.dart';
import '../widgets/app_back_button.dart';
import '../theme/app_colors.dart';

/// 任務完成慶祝頁 —— 神秘獎勵在這裡揭曉。
class CelebrationScreen extends ConsumerWidget {
  const CelebrationScreen({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(repositoryProvider);
    final task = repo.tasks.where((t) => t.id == taskId).firstOrNull;
    if (task == null) {
      return const Scaffold(body: Center(child: Text('任務不存在')));
    }

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('任務完成'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              const Text(
                '恭喜完成！',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                task.title,
                style: const TextStyle(
                    fontSize: 20, color: AppColors.inkSoft),
              ),
              const SizedBox(height: 32),
              Container(
                width: 180,
                height: 180,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(task.emoji, style: const TextStyle(fontSize: 72)),
              ),
              const SizedBox(height: 24),
              ShadBadge(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                child: Text(
                  '獎勵已解鎖：${task.rewardLabel}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text('太棒了！', style: TextStyle(color: AppColors.inkSoft)),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: ShadButton.outline(
                      foregroundColor: AppColors.ink,
                      onPressed: () => context.go('/'),
                      child: const Text('回任務看板'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ShadButton.secondary(
                      onPressed: () {
                        ShadToaster.of(context).show(
                          const ShadToast(
                              description: Text('分享功能 v1.1 登場，先自己開心一下 🍿')),
                        );
                      },
                      child: const Text('分享喜悅'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
