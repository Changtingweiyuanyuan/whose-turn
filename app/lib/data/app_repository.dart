import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../models/group.dart';
import '../models/notification_item.dart';
import '../models/task.dart';

/// 資料層介面。MVP 用 [FakeAppRepository]（in-memory），
/// Firebase 帳號建好後換成 FirestoreAppRepository，畫面不用動。
abstract class AppRepository extends ChangeNotifier {
  AppUser get currentUser;
  List<AppUser> get knownUsers;
  Group? get currentGroup;
  List<Task> get tasks;
  List<NotificationItem> get notifications;

  AppUser userOf(String uid);

  /// 刊頭 NO.xx：目前使用者在群組中的座號（1-based）。
  /// 未加入群組時為 null（刊頭不顯示編號）。
  int? get userNo {
    final index = currentGroup?.memberUids.indexOf(currentUser.uid) ?? -1;
    return index >= 0 ? index + 1 : null;
  }

  // --- 群組 ---
  Future<Group> createGroup(String name, {String? personalIcon});
  Future<Group?> joinGroupByCode(String inviteCode, {String? personalIcon});

  /// 查群組但不加入（加入前預覽，用來得知已被選走的個人圖示）。
  Future<Group?> findGroupByCode(String inviteCode);
  Future<void> leaveGroup();

  // --- 任務 ---
  Future<Task> createTask({
    required String title,
    required String emoji,
    required RewardType rewardType,
    required String rewardLabel,
    required int requiredCount,
    DateTime? deadline,
    String? assigneeUid,
  });
  Future<void> claimTask(String taskId);
  Future<void> abandonTask(String taskId);
  Future<void> cancelTask(String taskId);
  Future<void> submitCompletion(String taskId);
  Future<void> confirmCompletion(String taskId, String completionId);
  Future<void> rejectCompletion(String taskId, String completionId);
  Future<void> claimReward(String taskId);

  // --- 通知 ---
  Future<void> markNotificationRead(String notificationId);
  int get unreadCount;

  // --- 帳號 ---
  Future<void> bindLine();

  /// Demo 用：切換目前使用者，方便同時體驗發起人與接單人視角。
  Future<void> switchUser(String uid);
}

/// 訪客權限（已定案）：可加入群組、可接任務；建立群組與發起任務前必須綁定 LINE。
class GuestNotAllowedException implements Exception {
  const GuestNotAllowedException(this.action);
  final String action;
}
