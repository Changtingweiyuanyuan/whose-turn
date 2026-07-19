import '../models/app_user.dart';
import '../models/group.dart';
import '../models/notification_item.dart';
import '../models/task.dart';
import 'app_repository.dart';

/// In-memory 假後端：seed 一組「我們家」資料，
/// 讓六大功能在沒有 Firebase 的情況下完整可玩。
class FakeAppRepository extends AppRepository {
  FakeAppRepository({DateTime Function()? clock})
      : _now = clock ?? DateTime.now {
    _seed();
  }

  final DateTime Function() _now;
  int _idCounter = 0;
  String _nextId(String prefix) => '$prefix-${++_idCounter}';

  late AppUser _currentUser;
  final Map<String, AppUser> _users = {};
  Group? _group;
  final List<Task> _tasks = [];
  final List<NotificationItem> _notifications = [];

  // ---------------------------------------------------------------- seed

  void _seed() {
    final mom = AppUser(
      uid: 'line:mom',
      displayName: '媽媽',
      provider: AuthProvider.line,
      avatarEmoji: 'asset:smiley_blessed',
      starTotal: 12,
    );
    final bro = AppUser(
      uid: 'line:bro',
      displayName: '哥哥',
      provider: AuthProvider.line,
      avatarEmoji: 'asset:smiley_cheeky',
      starTotal: 7,
    );
    final me = AppUser(
      uid: 'anon-me',
      displayName: guestDisplayName('anon-me'),
      provider: AuthProvider.anonymous,
      avatarEmoji: 'asset:smiley_wink',
      starTotal: 3,
    );
    for (final u in [mom, bro, me]) {
      _users[u.uid] = u;
    }
    _currentUser = me;

    _group = Group(
      id: 'g-home',
      name: '我們家',
      inviteCode: 'HOME2026',
      createdBy: mom.uid,
      memberUids: [mom.uid, bro.uid, me.uid],
    );

    final now = _now();
    _tasks.addAll([
      Task(
        id: _nextId('t'),
        groupId: 'g-home',
        title: '洗碗一次',
        colorIndex: 1,
        emoji: 'asset:cleaning',
        rewardType: RewardType.normal,
        rewardLabel: '珍奶一杯',
        requiredCount: 5,
        createdBy: mom.uid,
        createdAt: now.subtract(const Duration(hours: 2)),
        claimedBy: me.uid,
        status: TaskStatus.claimed,
        completions: [
          Completion(
            id: _nextId('c'),
            userId: me.uid,
            submittedAt: now.subtract(const Duration(days: 2)),
            status: CompletionStatus.confirmed,
            resolvedAt: now.subtract(const Duration(days: 2)),
          ),
          Completion(
            id: _nextId('c'),
            userId: me.uid,
            submittedAt: now.subtract(const Duration(days: 1)),
            status: CompletionStatus.confirmed,
            resolvedAt: now.subtract(const Duration(days: 1)),
          ),
          Completion(
            id: _nextId('c'),
            userId: me.uid,
            submittedAt: now.subtract(const Duration(hours: 5)),
            status: CompletionStatus.confirmed,
            resolvedAt: now.subtract(const Duration(hours: 4)),
          ),
        ],
      ),
      Task(
        id: _nextId('t'),
        groupId: 'g-home',
        title: '倒垃圾',
        colorIndex: 2,
        emoji: 'asset:trash',
        rewardType: RewardType.money,
        rewardLabel: '50 元',
        requiredCount: 3,
        createdBy: 'line:mom',
        createdAt: now.subtract(const Duration(hours: 6)),
        deadline: now.add(const Duration(days: 1)),
      ),
      Task(
        id: _nextId('t'),
        groupId: 'g-home',
        title: '整理客廳',
        colorIndex: 0,
        emoji: 'asset:home',
        rewardType: RewardType.mystery,
        rewardLabel: '神秘禮物',
        requiredCount: 1,
        createdBy: bro.uid,
        createdAt: now.subtract(const Duration(minutes: 30)),
      ),
      Task(
        id: _nextId('t'),
        groupId: 'g-home',
        title: '遛狗',
        colorIndex: 3,
        emoji: 'asset:lucky_cat',
        rewardType: RewardType.experience,
        rewardLabel: '週末火鍋',
        requiredCount: 2,
        createdBy: mom.uid,
        createdAt: now.subtract(const Duration(days: 1)),
        deadline: now.add(const Duration(hours: 8)),
      ),
      // 高次數任務：進度以進度條呈現（> 5 次）
      Task(
        id: _nextId('t'),
        groupId: 'g-home',
        title: '背英文單字',
        colorIndex: 4,
        emoji: 'asset:book',
        rewardType: RewardType.normal,
        rewardLabel: 'Switch 遊戲一片',
        requiredCount: 20,
        createdBy: mom.uid,
        createdAt: now.subtract(const Duration(days: 7)),
        claimedBy: bro.uid,
        status: TaskStatus.claimed,
        completions: [
          for (var i = 0; i < 7; i++)
            Completion(
              id: _nextId('c'),
              userId: bro.uid,
              submittedAt: now.subtract(Duration(days: 7 - i)),
              status: CompletionStatus.confirmed,
              resolvedAt: now.subtract(Duration(days: 7 - i)),
            ),
        ],
      ),
    ]);

    _notifications.add(NotificationItem(
      id: _nextId('n'),
      recipientUid: me.uid,
      type: NotificationType.newTask,
      title: '有人發起了新任務！',
      body: '哥哥 發起了「整理客廳」，獎勵是神秘禮物',
      taskId: _tasks[2].id,
      createdAt: now.subtract(const Duration(minutes: 30)),
    ));
  }

  // ------------------------------------------------------------- getters

  @override
  AppUser get currentUser => _currentUser;

  @override
  List<AppUser> get knownUsers => List.unmodifiable(_users.values);

  @override
  Group? get currentGroup => _group;

  @override
  List<Task> get tasks => List.unmodifiable(_tasks);

  @override
  List<NotificationItem> get notifications => List.unmodifiable(
        _notifications.where((n) => n.recipientUid == _currentUser.uid),
      );

  @override
  int get unreadCount => notifications.where((n) => !n.read).length;

  @override
  AppUser userOf(String uid) =>
      _users[uid] ??
      AppUser(uid: uid, displayName: '未知成員', provider: AuthProvider.anonymous);

  Task _task(String taskId) => _tasks.firstWhere((t) => t.id == taskId);

  void _replaceTask(Task updated) {
    final i = _tasks.indexWhere((t) => t.id == updated.id);
    _tasks[i] = updated;
  }

  void _notify({
    required String recipientUid,
    required NotificationType type,
    required String title,
    required String body,
    String? taskId,
  }) {
    if (recipientUid == _currentUser.uid) return; // 自己的動作不通知自己
    _notifications.insert(
      0,
      NotificationItem(
        id: _nextId('n'),
        recipientUid: recipientUid,
        type: type,
        title: title,
        body: body,
        taskId: taskId,
        createdAt: _now(),
      ),
    );
  }

  void _notifyGroup({
    required NotificationType type,
    required String title,
    required String body,
    String? taskId,
  }) {
    for (final uid in _group?.memberUids ?? const <String>[]) {
      _notify(
        recipientUid: uid,
        type: type,
        title: title,
        body: body,
        taskId: taskId,
      );
    }
  }

  // -------------------------------------------------------------- 群組

  @override
  Future<Group?> findGroupByCode(String inviteCode) async {
    if (_group != null &&
        _group!.inviteCode.toUpperCase() == inviteCode.trim().toUpperCase()) {
      return _group;
    }
    return null;
  }

  @override
  Future<Group> createGroup(String name, {String? personalIcon}) async {
    if (_currentUser.isGuest) throw const GuestNotAllowedException('建立群組');
    if (personalIcon != null) _setMyAvatar(personalIcon);
    final group = Group(
      id: _nextId('g'),
      name: name,
      inviteCode: 'INV${_idCounter}X',
      createdBy: _currentUser.uid,
      memberUids: [_currentUser.uid],
    );
    _group = group;
    notifyListeners();
    return group;
  }

  @override
  Future<Group?> joinGroupByCode(String inviteCode,
      {String? personalIcon}) async {
    if (_group != null &&
        _group!.inviteCode.toUpperCase() == inviteCode.trim().toUpperCase()) {
      if (personalIcon != null) _setMyAvatar(personalIcon);
      if (!_group!.memberUids.contains(_currentUser.uid)) {
        _group = Group(
          id: _group!.id,
          name: _group!.name,
          inviteCode: _group!.inviteCode,
          createdBy: _group!.createdBy,
          memberUids: [..._group!.memberUids, _currentUser.uid],
        );
      }
      notifyListeners();
      return _group;
    }
    return null;
  }

  /// 更新目前使用者的個人圖示（同步 _users 快取）。
  void _setMyAvatar(String avatar) {
    _currentUser = _currentUser.copyWith(avatarEmoji: avatar);
    _users[_currentUser.uid] = _currentUser;
  }

  @override
  Future<void> leaveGroup() async {
    if (_group == null) return;
    _group = Group(
      id: _group!.id,
      name: _group!.name,
      inviteCode: _group!.inviteCode,
      createdBy: _group!.createdBy,
      memberUids:
          _group!.memberUids.where((u) => u != _currentUser.uid).toList(),
    );
    notifyListeners();
  }

  // -------------------------------------------------------------- 任務

  @override
  Future<Task> createTask({
    required String title,
    required String emoji,
    required RewardType rewardType,
    required String rewardLabel,
    required int requiredCount,
    DateTime? deadline,
    String? assigneeUid,
  }) async {
    if (_currentUser.isGuest) throw const GuestNotAllowedException('發起任務');
    final task = Task(
      id: _nextId('t'),
      groupId: _group!.id,
      title: title,
      emoji: emoji,
      rewardType: rewardType,
      rewardLabel: rewardLabel,
      requiredCount: requiredCount,
      deadline: deadline,
      assigneeUid: assigneeUid,
      createdBy: _currentUser.uid,
      createdAt: _now(),
      // 建立時記錄卡片底色：依現有任務數輪替
      colorIndex: _tasks.length % Task.cardColorCount,
    );
    _tasks.insert(0, task);
    _notifyGroup(
      type: NotificationType.newTask,
      title: '有人發起了新任務！',
      body: '${_currentUser.displayName} 發起了「$title」',
      taskId: task.id,
    );
    notifyListeners();
    return task;
  }

  @override
  Future<void> claimTask(String taskId) async {
    final task = _task(taskId);
    assert(task.canClaimBy(_currentUser.uid));
    _replaceTask(
      task.copyWith(claimedBy: _currentUser.uid, status: TaskStatus.claimed),
    );
    _notify(
      recipientUid: task.createdBy,
      type: NotificationType.claimed,
      title: '有人接下你的任務了！',
      body: '${_currentUser.displayName} 接下了「${task.title}」',
      taskId: taskId,
    );
    notifyListeners();
  }

  @override
  Future<void> abandonTask(String taskId) async {
    final task = _task(taskId);
    // 放棄後任務回到任務看板；已確認的 ⭐ 保留（永遠不能扣）
    _replaceTask(task.copyWith(clearClaimedBy: true, status: TaskStatus.open));
    notifyListeners();
  }

  @override
  Future<void> cancelTask(String taskId) async {
    final task = _task(taskId);
    if (task.status != TaskStatus.open) return; // 已被接單不可取消
    _replaceTask(task.copyWith(status: TaskStatus.cancelled));
    notifyListeners();
  }

  @override
  Future<void> submitCompletion(String taskId) async {
    final task = _task(taskId);
    final completion = Completion(
      id: _nextId('c'),
      userId: _currentUser.uid,
      submittedAt: _now(),
    );
    _replaceTask(task.copyWith(completions: [...task.completions, completion]));
    _notify(
      recipientUid: task.createdBy,
      type: NotificationType.pendingConfirm,
      title: '有人回報完成，等你確認',
      body: '${_currentUser.displayName} 完成了「${task.title}」',
      taskId: taskId,
    );
    notifyListeners();
  }

  @override
  Future<void> confirmCompletion(String taskId, String completionId) async {
    final task = _task(taskId);
    final completions = task.completions
        .map((c) => c.id == completionId
            ? c.copyWith(status: CompletionStatus.confirmed, resolvedAt: _now())
            : c)
        .toList();

    var updated = task.copyWith(completions: completions);
    final doneUid = task.completions
        .firstWhere((c) => c.id == completionId)
        .userId;

    // +1 ⭐（永遠不能扣）
    final doer = _users[doneUid]!;
    _users[doneUid] = doer.copyWith(starTotal: doer.starTotal + 1);
    if (_currentUser.uid == doneUid) _currentUser = _users[doneUid]!;

    if (updated.confirmedCount >= updated.requiredCount) {
      updated = updated.copyWith(status: TaskStatus.completed);
      _notify(
        recipientUid: doneUid,
        type: NotificationType.taskCompleted,
        title: '可以領獎勵囉！',
        body: '「${task.title}」全部完成，獎勵：${task.rewardLabel}',
        taskId: taskId,
      );
    } else {
      _notify(
        recipientUid: doneUid,
        type: NotificationType.starEarned,
        title: '確認成功，進度更新！',
        body: '「${task.title}」${updated.confirmedCount} / ${updated.requiredCount}',
        taskId: taskId,
      );
    }
    _replaceTask(updated);
    notifyListeners();
  }

  @override
  Future<void> rejectCompletion(String taskId, String completionId) async {
    final task = _task(taskId);
    final completions = task.completions
        .map((c) => c.id == completionId
            ? c.copyWith(status: CompletionStatus.rejected, resolvedAt: _now())
            : c)
        .toList();
    _replaceTask(task.copyWith(completions: completions));
    final doneUid =
        task.completions.firstWhere((c) => c.id == completionId).userId;
    _notify(
      recipientUid: doneUid,
      type: NotificationType.pendingConfirm,
      title: '回報未通過，請重新完成',
      body: '「${task.title}」的完成紀錄被退回，再試一次！',
      taskId: taskId,
    );
    notifyListeners();
  }

  @override
  Future<void> claimReward(String taskId) async {
    final task = _task(taskId);
    if (task.status != TaskStatus.completed) return;
    _replaceTask(task.copyWith(status: TaskStatus.rewardClaimed));
    notifyListeners();
  }

  // -------------------------------------------------------------- 通知

  @override
  Future<void> markNotificationRead(String notificationId) async {
    final i = _notifications.indexWhere((n) => n.id == notificationId);
    if (i >= 0) _notifications[i] = _notifications[i].copyWith(read: true);
    notifyListeners();
  }

  // -------------------------------------------------------------- 帳號

  @override
  Future<void> bindLine() async {
    // 真實版：flutter_line_sdk 登入 → POST /auth/line → signInWithCustomToken。
    // Fake 版：直接把訪客升級成 LINE 帳號（星星與紀錄自動保留 = 合併政策）。
    final upgraded = AppUser(
      uid: _currentUser.uid,
      displayName: _currentUser.displayName.replaceAll('(訪客)', ''),
      provider: AuthProvider.line,
      avatarEmoji: _currentUser.avatarEmoji,
      starTotal: _currentUser.starTotal,
    );
    _users[_currentUser.uid] = upgraded;
    _currentUser = upgraded;
    notifyListeners();
  }

  @override
  Future<void> switchUser(String uid) async {
    _currentUser = _users[uid]!;
    notifyListeners();
  }
}
