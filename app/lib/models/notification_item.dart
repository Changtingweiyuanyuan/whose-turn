enum NotificationType {
  newTask,
  claimed,
  pendingConfirm,
  starEarned,
  taskCompleted,
  deadlineNudge,
}

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.recipientUid,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.taskId,
    this.read = false,
  });

  final String id;
  final String recipientUid;
  final NotificationType type;
  final String title;
  final String body;
  final String? taskId;
  final DateTime createdAt;
  final bool read;

  NotificationItem copyWith({bool? read}) {
    return NotificationItem(
      id: id,
      recipientUid: recipientUid,
      type: type,
      title: title,
      body: body,
      taskId: taskId,
      createdAt: createdAt,
      read: read ?? this.read,
    );
  }
}
