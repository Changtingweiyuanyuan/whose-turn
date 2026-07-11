import 'package:flutter_test/flutter_test.dart';
import 'package:whose_turn/data/app_repository.dart';
import 'package:whose_turn/data/fake_app_repository.dart';
import 'package:whose_turn/models/task.dart';

void main() {
  late FakeAppRepository repo;

  setUp(() {
    repo = FakeAppRepository();
  });

  group('任務狀態機', () {
    test('接單：open → claimed，並通知發起人', () async {
      final open = repo.tasks.firstWhere((t) => t.status == TaskStatus.open);
      await repo.claimTask(open.id);

      final claimed = repo.tasks.firstWhere((t) => t.id == open.id);
      expect(claimed.status, TaskStatus.claimed);
      expect(claimed.claimedBy, repo.currentUser.uid);
    });

    test('發起人不能接自己的任務', () {
      final myTask = repo.tasks.firstWhere(
        (t) => t.createdBy == repo.currentUser.uid,
        orElse: () => repo.tasks.first,
      );
      if (myTask.createdBy == repo.currentUser.uid) {
        expect(myTask.canClaimBy(repo.currentUser.uid), isFalse);
      }
    });

    test('完成一次 → pending completion，確認後 +1⭐', () async {
      final task =
          repo.tasks.firstWhere((t) => t.claimedBy == repo.currentUser.uid);
      final doerUid = repo.currentUser.uid;
      final starsBefore = repo.currentUser.starTotal;

      await repo.submitCompletion(task.id);
      var updated = repo.tasks.firstWhere((t) => t.id == task.id);
      expect(updated.hasPendingCompletion, isTrue);

      final pending = updated.completions
          .firstWhere((c) => c.status == CompletionStatus.pending);

      // 切到發起人視角確認
      await repo.switchUser(task.createdBy);
      await repo.confirmCompletion(task.id, pending.id);

      updated = repo.tasks.firstWhere((t) => t.id == task.id);
      expect(
        updated.completions
            .where((c) => c.status == CompletionStatus.confirmed)
            .length,
        task.confirmedCount + 1,
      );
      expect(repo.userOf(doerUid).starTotal, starsBefore + 1);
    });

    test('退回不影響已確認次數，星星不會被扣', () async {
      final task =
          repo.tasks.firstWhere((t) => t.claimedBy == repo.currentUser.uid);
      final doerUid = repo.currentUser.uid;
      final starsBefore = repo.currentUser.starTotal;
      final confirmedBefore = task.confirmedCount;

      await repo.submitCompletion(task.id);
      final pending = repo.tasks
          .firstWhere((t) => t.id == task.id)
          .completions
          .firstWhere((c) => c.status == CompletionStatus.pending);

      await repo.switchUser(task.createdBy);
      await repo.rejectCompletion(task.id, pending.id);

      final updated = repo.tasks.firstWhere((t) => t.id == task.id);
      expect(updated.confirmedCount, confirmedBefore);
      expect(repo.userOf(doerUid).starTotal, starsBefore);
      expect(updated.status, TaskStatus.claimed);
    });

    test('確認次數達標 → completed，領取後 → rewardClaimed', () async {
      final task =
          repo.tasks.firstWhere((t) => t.claimedBy == repo.currentUser.uid);
      final claimant = repo.currentUser.uid;
      final remaining = task.requiredCount - task.confirmedCount;

      for (var i = 0; i < remaining; i++) {
        await repo.switchUser(claimant);
        await repo.submitCompletion(task.id);
        final pending = repo.tasks
            .firstWhere((t) => t.id == task.id)
            .completions
            .firstWhere((c) => c.status == CompletionStatus.pending);
        await repo.switchUser(task.createdBy);
        await repo.confirmCompletion(task.id, pending.id);
      }

      var updated = repo.tasks.firstWhere((t) => t.id == task.id);
      expect(updated.status, TaskStatus.completed);

      await repo.switchUser(claimant);
      await repo.claimReward(task.id);
      updated = repo.tasks.firstWhere((t) => t.id == task.id);
      expect(updated.status, TaskStatus.rewardClaimed);
    });

    test('放棄任務 → 回到 open、claimedBy 清空', () async {
      final task =
          repo.tasks.firstWhere((t) => t.claimedBy == repo.currentUser.uid);
      await repo.abandonTask(task.id);
      final updated = repo.tasks.firstWhere((t) => t.id == task.id);
      expect(updated.status, TaskStatus.open);
      expect(updated.claimedBy, isNull);
    });

    test('取消任務：只有 open 狀態可以取消', () async {
      final claimed =
          repo.tasks.firstWhere((t) => t.status == TaskStatus.claimed);
      await repo.cancelTask(claimed.id);
      expect(
        repo.tasks.firstWhere((t) => t.id == claimed.id).status,
        TaskStatus.claimed, // 不變
      );

      final open = repo.tasks.firstWhere((t) => t.status == TaskStatus.open);
      await repo.cancelTask(open.id);
      expect(
        repo.tasks.firstWhere((t) => t.id == open.id).status,
        TaskStatus.cancelled,
      );
    });
  });

  group('神秘獎勵', () {
    test('接單人完成前看到 ???，發起人隨時看得到內容', () {
      final mystery = repo.tasks.firstWhere((t) => t.isMystery);
      expect(mystery.rewardLabelFor(repo.currentUser.uid), '???');
      expect(mystery.rewardLabelFor(mystery.createdBy), mystery.rewardLabel);
    });
  });

  group('訪客權限（已定案）', () {
    test('訪客可以接任務', () {
      expect(repo.currentUser.isGuest, isTrue);
      final open = repo.tasks.firstWhere((t) => t.status == TaskStatus.open);
      expect(open.canClaimBy(repo.currentUser.uid), isTrue);
    });

    test('訪客不能建立群組', () async {
      expect(
        () => repo.createGroup('新群組', '🏠'),
        throwsA(isA<GuestNotAllowedException>()),
      );
    });

    test('訪客不能發起任務', () async {
      expect(
        () => repo.createTask(
          title: '測試',
          emoji: '🍵',
          rewardType: RewardType.normal,
          rewardLabel: '珍奶',
          requiredCount: 1,
        ),
        throwsA(isA<GuestNotAllowedException>()),
      );
    });

    test('綁定 LINE 後升級帳號，星星保留（合併政策）', () async {
      final starsBefore = repo.currentUser.starTotal;
      await repo.bindLine();
      expect(repo.currentUser.isGuest, isFalse);
      expect(repo.currentUser.starTotal, starsBefore);
    });
  });

  group('通知', () {
    test('發起任務會通知群組其他成員（品牌文案）', () async {
      await repo.bindLine(); // 先升級才能發任務
      await repo.createTask(
        title: '澆花',
        emoji: '🧺',
        rewardType: RewardType.normal,
        rewardLabel: '布丁',
        requiredCount: 1,
      );
      await repo.switchUser('line:mom');
      expect(
        repo.notifications.any((n) => n.title.contains('今天有人發起新任務')),
        isTrue,
      );
    });
  });
}
