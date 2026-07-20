/// 任務狀態機（詳見 docs/data-model.md）：
///
/// open ──我要接──▶ claimed ──我完成一次──▶ completion(pending)
///   │                 │                      ├─確認→ confirmedCount+1（+1⭐）
///   │                 │                      └─退回→ 回到 claimed
///   │                 │  confirmedCount == requiredCount → completed
///   │                 └─接單人放棄→ open
///   ├─發起人取消（僅 open）→ cancelled
///   └─截止到期→ expired（已得 ⭐ 保留）
/// completed ──領取獎勵──▶ rewardClaimed
enum TaskStatus { open, claimed, completed, rewardClaimed, expired, cancelled }

enum RewardType { normal, mystery, money, privilege, experience }

enum CompletionStatus { pending, confirmed, rejected }

class Completion {
  const Completion({
    required this.id,
    required this.userId,
    required this.submittedAt,
    this.status = CompletionStatus.pending,
    this.resolvedAt,
  });

  final String id;
  final String userId;
  final DateTime submittedAt;
  final CompletionStatus status;
  final DateTime? resolvedAt;

  Completion copyWith({CompletionStatus? status, DateTime? resolvedAt}) {
    return Completion(
      id: id,
      userId: userId,
      submittedAt: submittedAt,
      status: status ?? this.status,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }
}

class Task {
  const Task({
    required this.id,
    required this.groupId,
    required this.title,
    required this.emoji,
    required this.rewardType,
    required this.rewardLabel,
    required this.createdBy,
    required this.createdAt,
    this.requiredCount = 1,
    this.deadline,
    this.assigneeUid,
    this.claimedBy,
    this.status = TaskStatus.open,
    this.completions = const [],
    this.colorIndex = 0,
  });

  /// 卡片輪替色的色數（對應 AppColors.cardCycle）。
  static const cardColorCount = 5;

  /// 舊資料沒存 colorIndex 時的穩定備援：由 id 導出，不隨列表順序變動。
  static int colorIndexFromId(String id) =>
      id.codeUnits.fold<int>(0, (a, b) => a + b) % cardColorCount;

  final String id;
  final String groupId;
  final String title;
  final String emoji;
  final RewardType rewardType;
  final String rewardLabel;
  final int requiredCount;
  final DateTime? deadline;
  final String createdBy;
  final DateTime createdAt;

  /// 指定某人才能接；null = 誰都可以接。
  final String? assigneeUid;
  final String? claimedBy;
  final TaskStatus status;
  final List<Completion> completions;

  /// 建立任務時記錄的卡片底色索引（AppColors.cardCycle）。
  final int colorIndex;

  bool get isMystery => rewardType == RewardType.mystery;

  int get confirmedCount =>
      completions.where((c) => c.status == CompletionStatus.confirmed).length;

  bool get hasPendingCompletion =>
      completions.any((c) => c.status == CompletionStatus.pending);

  int get pendingCount =>
      completions.where((c) => c.status == CompletionStatus.pending).length;

  /// 已送出且未被退回的次數（等待確認 + 已確認），用來擋住超額送出。
  int get activeCount => confirmedCount + pendingCount;

  /// 對接單人顯示的獎勵文字：神秘任務完成前只看得到 ???
  String rewardLabelFor(String viewerUid) {
    if (!isMystery) return rewardLabel;
    final revealed =
        viewerUid == createdBy ||
        status == TaskStatus.completed ||
        status == TaskStatus.rewardClaimed;
    return revealed ? rewardLabel : '???';
  }

  bool canClaimBy(String uid) {
    if (status != TaskStatus.open) return false;
    if (uid == createdBy) return false;
    if (assigneeUid != null && assigneeUid != uid) return false;
    return true;
  }

  Task copyWith({
    String? claimedBy,
    bool clearClaimedBy = false,
    TaskStatus? status,
    List<Completion>? completions,
  }) {
    return Task(
      id: id,
      groupId: groupId,
      title: title,
      emoji: emoji,
      rewardType: rewardType,
      rewardLabel: rewardLabel,
      requiredCount: requiredCount,
      deadline: deadline,
      createdBy: createdBy,
      createdAt: createdAt,
      assigneeUid: assigneeUid,
      claimedBy: clearClaimedBy ? null : (claimedBy ?? this.claimedBy),
      status: status ?? this.status,
      completions: completions ?? this.completions,
      colorIndex: colorIndex,
    );
  }
}
