import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';

import '../constants/personal_icons.dart';
import '../models/app_user.dart';
import '../models/group.dart';
import '../models/notification_item.dart';
import '../models/task.dart';
import 'app_repository.dart';
import 'line_auth/line_auth.dart';

/// Firestore 真後端（--dart-define=USE_FIREBASE=true 時啟用）。
///
/// 結構見 docs/data-model.md：
///   users/{uid}
///   users/{uid}/notifications/{id}
///   groups/{gid} + groups/{gid}/members/{uid}
///   tasks/{tid} + tasks/{tid}/completions/{cid}（completion 冗餘 groupId
///   供 collectionGroup 即時監聽）
class FirebaseAppRepository extends AppRepository {
  FirebaseAppRepository._(this._db, this._auth);

  final FirebaseFirestore _db;
  final fb.FirebaseAuth _auth;

  // ------------------------------------------------------------- state
  AppUser? _me;
  final Map<String, AppUser> _users = {};
  Group? _group;
  List<Task> _rawTasks = const [];
  final Map<String, List<Completion>> _completionsByTask = {};
  List<NotificationItem> _notifications = const [];

  final List<StreamSubscription<dynamic>> _rootSubs = [];
  final List<StreamSubscription<dynamic>> _groupSubs = [];
  final Map<String, StreamSubscription<dynamic>> _memberUserSubs = {};

  String get _uid => _auth.currentUser!.uid;

  // --------------------------------------------------------- bootstrap

  static Future<FirebaseAppRepository> bootstrap() async {
    final repo = FirebaseAppRepository._(
      FirebaseFirestore.instance,
      fb.FirebaseAuth.instance,
    );
    await repo._ensureUserDoc();
    repo._attachRootListeners();
    return repo;
  }

  /// 首次進站（或 LINE 升級後）確保 users/{uid} 存在。
  Future<void> _ensureUserDoc() async {
    final user = _auth.currentUser!;
    final ref = _db.collection('users').doc(user.uid);
    final snap = await ref.get();
    if (!snap.exists) {
      final isAnon = user.isAnonymous;
      await ref.set({
        'displayName':
            user.displayName ?? (isAnon ? guestDisplayName(user.uid) : '我'),
        'avatarEmoji': kPersonalIcons.first,
        'provider': isAnon ? 'anonymous' : 'line',
        'starTotal': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  void _attachRootListeners() {
    // 我的 user doc
    _rootSubs.add(
      _db.collection('users').doc(_uid).snapshots().listen((snap) {
        if (snap.exists) {
          _me = _userFrom(snap.id, snap.data()!);
          _users[_uid] = _me!;
          notifyListeners();
        }
      }),
    );
    // 我的通知
    _rootSubs.add(
      _db
          .collection('users')
          .doc(_uid)
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .limit(100)
          .snapshots()
          .listen((snap) {
            _notifications = [
              for (final d in snap.docs) _notificationFrom(d.id, d.data()),
            ];
            notifyListeners();
          }),
    );
    // 我所屬的群組（membership → group）
    _rootSubs.add(
      _db
          .collectionGroup('members')
          .where('userId', isEqualTo: _uid)
          .limit(1)
          .snapshots()
          .listen((snap) {
            final groupId = snap.docs.isEmpty
                ? null
                : snap.docs.first.reference.parent.parent!.id;
            if (groupId != _group?.id ||
                (groupId == null) != (_group == null)) {
              _attachGroupListeners(groupId);
            }
          }),
    );
  }

  void _attachGroupListeners(String? groupId) {
    for (final s in _groupSubs) {
      s.cancel();
    }
    _groupSubs.clear();
    for (final s in _memberUserSubs.values) {
      s.cancel();
    }
    _memberUserSubs.clear();

    if (groupId == null) {
      _group = null;
      _rawTasks = const [];
      _completionsByTask.clear();
      notifyListeners();
      return;
    }

    final groupRef = _db.collection('groups').doc(groupId);

    // group doc + members
    _groupSubs.add(
      groupRef.snapshots().listen((snap) {
        if (!snap.exists) return;
        final memberUids = _group?.id == groupId
            ? _group!.memberUids
            : <String>[];
        _group = _groupFrom(snap.id, snap.data()!, memberUids);
        notifyListeners();
      }),
    );
    _groupSubs.add(
      groupRef.collection('members').snapshots().listen((snap) {
        final uids = [for (final d in snap.docs) d.id];
        if (_group != null && _group!.id == groupId) {
          _group = Group(
            id: _group!.id,
            name: _group!.name,
            inviteCode: _group!.inviteCode,
            createdBy: _group!.createdBy,
            memberUids: uids,
          );
        }
        _watchMemberUsers(uids);
        notifyListeners();
      }),
    );

    // tasks + completions（collectionGroup、以 groupId 過濾）
    _groupSubs.add(
      _db
          .collection('tasks')
          .where('groupId', isEqualTo: groupId)
          .snapshots()
          .listen((snap) {
            _rawTasks = [for (final d in snap.docs) _taskFrom(d.id, d.data())];
            notifyListeners();
          }),
    );
    _groupSubs.add(
      _db
          .collectionGroup('completions')
          .where('groupId', isEqualTo: groupId)
          .snapshots()
          .listen((snap) {
            _completionsByTask.clear();
            for (final d in snap.docs) {
              final taskId = d.reference.parent.parent!.id;
              (_completionsByTask[taskId] ??= []).add(
                _completionFrom(d.id, d.data()),
              );
            }
            for (final list in _completionsByTask.values) {
              list.sort((a, b) => a.submittedAt.compareTo(b.submittedAt));
            }
            notifyListeners();
          }),
    );
  }

  void _watchMemberUsers(List<String> uids) {
    // 移除已離開者
    for (final uid in _memberUserSubs.keys.toList()) {
      if (!uids.contains(uid)) {
        _memberUserSubs.remove(uid)!.cancel();
      }
    }
    // 新成員掛 listener
    for (final uid in uids) {
      if (_memberUserSubs.containsKey(uid)) continue;
      _memberUserSubs[uid] = _db
          .collection('users')
          .doc(uid)
          .snapshots()
          .listen((snap) {
            if (snap.exists) {
              _users[uid] = _userFrom(snap.id, snap.data()!);
              notifyListeners();
            }
          });
    }
  }

  @override
  void dispose() {
    for (final s in [..._rootSubs, ..._groupSubs, ..._memberUserSubs.values]) {
      s.cancel();
    }
    super.dispose();
  }

  // ------------------------------------------------------------ getters

  @override
  AppUser get currentUser =>
      _me ??
      AppUser(
        uid: _uid,
        displayName: guestDisplayName(_uid),
        provider: AuthProvider.anonymous,
      );

  @override
  List<AppUser> get knownUsers => List.unmodifiable([
    for (final uid in _group?.memberUids ?? const <String>[]) userOf(uid),
  ]);

  @override
  Group? get currentGroup => _group;

  @override
  List<Task> get tasks => List.unmodifiable([
    for (final t in _rawTasks)
      t.copyWith(completions: _completionsByTask[t.id] ?? const []),
  ]);

  @override
  List<NotificationItem> get notifications => List.unmodifiable(_notifications);

  @override
  int get unreadCount => _notifications.where((n) => !n.read).length;

  @override
  AppUser userOf(String uid) =>
      _users[uid] ??
      AppUser(uid: uid, displayName: '成員', provider: AuthProvider.line);

  Task _task(String taskId) => tasks.firstWhere((t) => t.id == taskId);

  // ------------------------------------------------------------- 群組

  static const _codeChars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  String _newInviteCode() {
    final rand = Random.secure();
    return List.generate(
      6,
      (_) => _codeChars[rand.nextInt(_codeChars.length)],
    ).join();
  }

  @override
  Future<Group> createGroup(String name, {String? personalIcon}) async {
    if (currentUser.isGuest) throw const GuestNotAllowedException('建立群組');
    final code = _newInviteCode();
    final groupRef = _db.collection('groups').doc();
    final batch = _db.batch();
    batch.set(groupRef, {
      'name': name,
      'inviteCode': code,
      'createdBy': _uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.set(groupRef.collection('members').doc(_uid), {
      'userId': _uid,
      'role': 'owner',
      'joinedAt': FieldValue.serverTimestamp(),
    });
    if (personalIcon != null) {
      batch.update(_db.collection('users').doc(_uid), {
        'avatarEmoji': personalIcon,
      });
    }
    await batch.commit();
    return Group(
      id: groupRef.id,
      name: name,
      inviteCode: code,
      createdBy: _uid,
      memberUids: [_uid],
    );
  }

  @override
  Future<Group?> findGroupByCode(String inviteCode) async {
    final snap = await _db
        .collection('groups')
        .where('inviteCode', isEqualTo: inviteCode.trim().toUpperCase())
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    final doc = snap.docs.first;
    final members = await doc.reference.collection('members').get();
    final uids = [for (final m in members.docs) m.id];
    // 預先抓成員的 user doc（加入前要顯示「已被選走」的個人圖示）
    for (final uid in uids) {
      if (_users.containsKey(uid)) continue;
      final u = await _db.collection('users').doc(uid).get();
      if (u.exists) _users[uid] = _userFrom(u.id, u.data()!);
    }
    return _groupFrom(doc.id, doc.data(), uids);
  }

  @override
  Future<Group?> joinGroupByCode(
    String inviteCode, {
    String? personalIcon,
  }) async {
    final group = await findGroupByCode(inviteCode);
    if (group == null) return null;
    final batch = _db.batch();
    batch.set(
      _db.collection('groups').doc(group.id).collection('members').doc(_uid),
      {
        'userId': _uid,
        'role': 'member',
        'joinedAt': FieldValue.serverTimestamp(),
      },
    );
    if (personalIcon != null) {
      batch.update(_db.collection('users').doc(_uid), {
        'avatarEmoji': personalIcon,
      });
    }
    await batch.commit();
    return group;
  }

  @override
  Future<void> leaveGroup() async {
    final g = _group;
    if (g == null) return;
    await _db
        .collection('groups')
        .doc(g.id)
        .collection('members')
        .doc(_uid)
        .delete();
  }

  // ------------------------------------------------------------- 任務

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
    if (currentUser.isGuest) throw const GuestNotAllowedException('發起任務');
    final g = _group!;
    // 建立時記錄卡片底色：依群組現有任務數輪替
    final colorIndex = tasks.length % Task.cardColorCount;
    final ref = await _db.collection('tasks').add({
      'groupId': g.id,
      'title': title,
      'emoji': emoji,
      'colorIndex': colorIndex,
      'rewardType': rewardType.name,
      'rewardLabel': rewardLabel,
      'requiredCount': requiredCount,
      'confirmedCount': 0,
      'deadline': deadline == null ? null : Timestamp.fromDate(deadline),
      'createdBy': _uid,
      'assigneeUid': assigneeUid,
      'claimedBy': null,
      'status': TaskStatus.open.name,
      'createdAt': FieldValue.serverTimestamp(),
    });
    _notifyGroup(
      type: NotificationType.newTask,
      title: '有人發起了新任務！',
      body:
          '${currentUser.displayName} 發起了「$title」，獎勵是${rewardType == RewardType.mystery ? '神秘禮物' : rewardLabel}',
      taskId: ref.id,
    );
    return Task(
      id: ref.id,
      groupId: g.id,
      title: title,
      emoji: emoji,
      rewardType: rewardType,
      rewardLabel: rewardLabel,
      requiredCount: requiredCount,
      deadline: deadline,
      createdBy: _uid,
      createdAt: DateTime.now(),
      assigneeUid: assigneeUid,
      colorIndex: colorIndex,
    );
  }

  @override
  Future<void> claimTask(String taskId) async {
    final task = _task(taskId);
    await _db.collection('tasks').doc(taskId).update({
      'claimedBy': _uid,
      'status': TaskStatus.claimed.name,
    });
    _notifyUser(
      task.createdBy,
      type: NotificationType.claimed,
      title: '任務有人接了！',
      body: '${currentUser.displayName} 接下了「${task.title}」',
      taskId: taskId,
    );
  }

  @override
  Future<void> abandonTask(String taskId) async {
    await _db.collection('tasks').doc(taskId).update({
      'claimedBy': null,
      'status': TaskStatus.open.name,
    });
  }

  @override
  Future<void> cancelTask(String taskId) async {
    await _db.collection('tasks').doc(taskId).update({
      'status': TaskStatus.cancelled.name,
    });
  }

  @override
  Future<void> submitCompletion(String taskId) async {
    final task = _task(taskId);
    await _db.collection('tasks').doc(taskId).collection('completions').add({
      'userId': _uid,
      'groupId': task.groupId, // 冗餘：collectionGroup 監聽用
      'submittedAt': FieldValue.serverTimestamp(),
      'status': CompletionStatus.pending.name,
      'resolvedAt': null,
    });
    _notifyUser(
      task.createdBy,
      type: NotificationType.pendingConfirm,
      title: '等你確認完成',
      body: '${currentUser.displayName} 完成了「${task.title}」一次，等你確認',
      taskId: taskId,
    );
  }

  @override
  Future<void> confirmCompletion(String taskId, String completionId) async {
    final task = _task(taskId);
    final completion = task.completions.firstWhere((c) => c.id == completionId);
    final newCount = task.confirmedCount + 1;
    final done = newCount >= task.requiredCount;

    final batch = _db.batch();
    batch.update(
      _db
          .collection('tasks')
          .doc(taskId)
          .collection('completions')
          .doc(completionId),
      {
        'status': CompletionStatus.confirmed.name,
        'resolvedAt': FieldValue.serverTimestamp(),
      },
    );
    batch.update(_db.collection('tasks').doc(taskId), {
      'confirmedCount': FieldValue.increment(1),
      if (done) 'status': TaskStatus.completed.name,
    });
    // ⭐ 只加不扣（rules 亦強制遞增）
    batch.update(_db.collection('users').doc(completion.userId), {
      'starTotal': FieldValue.increment(1),
    });
    await batch.commit();

    _notifyUser(
      completion.userId,
      type: done ? NotificationType.taskCompleted : NotificationType.starEarned,
      title: done ? '今天換你拿獎勵！' : '拿到一顆星星 ⭐',
      body: done
          ? '「${task.title}」全部完成，獎勵：${task.rewardLabel}'
          : '「${task.title}」完成 +1，目前 $newCount/${task.requiredCount}',
      taskId: taskId,
    );
  }

  @override
  Future<void> rejectCompletion(String taskId, String completionId) async {
    final task = _task(taskId);
    final completion = task.completions.firstWhere((c) => c.id == completionId);
    await _db
        .collection('tasks')
        .doc(taskId)
        .collection('completions')
        .doc(completionId)
        .update({
          'status': CompletionStatus.rejected.name,
          'resolvedAt': FieldValue.serverTimestamp(),
        });
    _notifyUser(
      completion.userId,
      type: NotificationType.pendingConfirm,
      title: '這次完成被退回',
      body: '「${task.title}」的完成被退回了，和發起人聊聊再試一次！',
      taskId: taskId,
    );
  }

  @override
  Future<void> claimReward(String taskId) async {
    await _db.collection('tasks').doc(taskId).update({
      'status': TaskStatus.rewardClaimed.name,
    });
  }

  // ------------------------------------------------------------- 通知

  @override
  Future<void> markNotificationRead(String notificationId) async {
    await _db
        .collection('users')
        .doc(_uid)
        .collection('notifications')
        .doc(notificationId)
        .update({'read': true});
  }

  void _notifyUser(
    String recipientUid, {
    required NotificationType type,
    required String title,
    required String body,
    String? taskId,
  }) {
    if (recipientUid == _uid) return; // 自己的動作不通知自己
    unawaited(
      _db
          .collection('users')
          .doc(recipientUid)
          .collection('notifications')
          .add({
            'type': type.name,
            'title': title,
            'body': body,
            'taskId': taskId,
            'read': false,
            'createdAt': FieldValue.serverTimestamp(),
          }),
    );
  }

  void _notifyGroup({
    required NotificationType type,
    required String title,
    required String body,
    String? taskId,
  }) {
    for (final uid in _group?.memberUids ?? const <String>[]) {
      _notifyUser(uid, type: type, title: title, body: body, taskId: taskId);
    }
  }

  // ------------------------------------------------------------- 帳號

  @override
  Future<void> bindLine() async {
    if (!kIsWeb) {
      throw UnsupportedError('LINE 綁定目前僅支援 Web');
    }
    // 整頁導向 LINE 授權頁；回來後由 main() 的 maybeHandleLineRedirect 接手。
    await startLineLogin(
      anonymousUid: _auth.currentUser?.isAnonymous == true
          ? _auth.currentUser!.uid
          : null,
    );
  }

  @override
  Future<void> switchUser(String uid) async {
    throw UnsupportedError('正式模式不提供視角切換');
  }

  @override
  Future<void> deleteAccount() async {
    final uid = _uid;
    final g = _group;

    // 1. 我發起的任務：連同 completions 子集合一起刪
    final myTasks =
        await _db.collection('tasks').where('createdBy', isEqualTo: uid).get();
    for (final t in myTasks.docs) {
      final comps = await t.reference.collection('completions').get();
      final batch = _db.batch();
      for (final c in comps.docs) {
        batch.delete(c.reference);
      }
      batch.delete(t.reference);
      await batch.commit();
    }

    // 2. 我在別人任務裡的完成紀錄（collectionGroup 一次撈、分批刪）
    final myComps = await _db
        .collectionGroup('completions')
        .where('userId', isEqualTo: uid)
        .get();
    for (var i = 0; i < myComps.docs.length; i += 400) {
      final batch = _db.batch();
      for (final c in myComps.docs.skip(i).take(400)) {
        batch.delete(c.reference);
      }
      await batch.commit();
    }

    // 3. 退出群組（刪成員 doc）
    if (g != null) {
      await _db
          .collection('groups')
          .doc(g.id)
          .collection('members')
          .doc(uid)
          .delete();
    }

    // 4. user doc + 通知子集合
    final notifs =
        await _db.collection('users').doc(uid).collection('notifications').get();
    for (var i = 0; i < notifs.docs.length; i += 400) {
      final batch = _db.batch();
      for (final n in notifs.docs.skip(i).take(400)) {
        batch.delete(n.reference);
      }
      await batch.commit();
    }
    await _db.collection('users').doc(uid).delete();

    // 5. 刪除登入帳號；LINE 帳號可能因需重新登入而失敗，資料已清空故僅登出。
    try {
      await _auth.currentUser?.delete();
    } on fb.FirebaseAuthException {
      await _auth.signOut();
    }
  }

  // ----------------------------------------------------------- mappers

  AppUser _userFrom(String uid, Map<String, dynamic> d) => AppUser(
    uid: uid,
    // 訪客一律顯示「訪客 XXXX」（uid 推導），不用 DB 裡的名字
    displayName: d['provider'] == 'line'
        ? (d['displayName'] as String?) ?? '成員'
        : guestDisplayName(uid),
    provider: d['provider'] == 'line'
        ? AuthProvider.line
        : AuthProvider.anonymous,
    avatarEmoji: (d['avatarEmoji'] as String?) ?? kPersonalIcons.first,
    starTotal: (d['starTotal'] as num?)?.toInt() ?? 0,
  );

  Group _groupFrom(String id, Map<String, dynamic> d, List<String> uids) =>
      Group(
        id: id,
        name: (d['name'] as String?) ?? '',
        inviteCode: (d['inviteCode'] as String?) ?? '',
        createdBy: (d['createdBy'] as String?) ?? '',
        memberUids: uids,
      );

  Task _taskFrom(String id, Map<String, dynamic> d) => Task(
    id: id,
    groupId: (d['groupId'] as String?) ?? '',
    title: (d['title'] as String?) ?? '',
    emoji: (d['emoji'] as String?) ?? 'asset:cleaning',
    rewardType:
        RewardType.values.asNameMap()[d['rewardType']] ?? RewardType.normal,
    rewardLabel: (d['rewardLabel'] as String?) ?? '',
    requiredCount: (d['requiredCount'] as num?)?.toInt() ?? 1,
    deadline: (d['deadline'] as Timestamp?)?.toDate(),
    createdBy: (d['createdBy'] as String?) ?? '',
    createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    assigneeUid: d['assigneeUid'] as String?,
    claimedBy: d['claimedBy'] as String?,
    status: TaskStatus.values.asNameMap()[d['status']] ?? TaskStatus.open,
    colorIndex: (d['colorIndex'] as num?)?.toInt() ?? Task.colorIndexFromId(id),
  );

  Completion _completionFrom(String id, Map<String, dynamic> d) => Completion(
    id: id,
    userId: (d['userId'] as String?) ?? '',
    submittedAt: (d['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    status:
        CompletionStatus.values.asNameMap()[d['status']] ??
        CompletionStatus.pending,
    resolvedAt: (d['resolvedAt'] as Timestamp?)?.toDate(),
  );

  NotificationItem _notificationFrom(String id, Map<String, dynamic> d) =>
      NotificationItem(
        id: id,
        recipientUid: _uid,
        type:
            NotificationType.values.asNameMap()[d['type']] ??
            NotificationType.newTask,
        title: (d['title'] as String?) ?? '',
        body: (d['body'] as String?) ?? '',
        taskId: d['taskId'] as String?,
        createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        read: (d['read'] as bool?) ?? false,
      );
}
