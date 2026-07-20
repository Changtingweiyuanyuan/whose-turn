enum AuthProvider { line, anonymous }

/// 訪客顯示名：由 uid 推導的固定 4 位編號（例：#GUEST 3894）。
/// 同一個匿名帳號永遠算出同一個編號，換頁、重整都不變。
String guestDisplayName(String uid) {
  var hash = 0;
  for (final unit in uid.codeUnits) {
    hash = (hash * 31 + unit) & 0x7fffffff;
  }
  return '#GUEST ${hash % 9000 + 1000}';
}

class AppUser {
  const AppUser({
    required this.uid,
    required this.displayName,
    required this.provider,
    this.avatarEmoji = '🙂',
    this.starTotal = 0,
  });

  final String uid;
  final String displayName;
  final AuthProvider provider;
  final String avatarEmoji;

  /// 累計星星 —— 永遠只加不扣。
  final int starTotal;

  bool get isGuest => provider == AuthProvider.anonymous;

  AppUser copyWith({
    String? displayName,
    int? starTotal,
    AuthProvider? provider,
    String? avatarEmoji,
  }) {
    return AppUser(
      uid: uid,
      displayName: displayName ?? this.displayName,
      provider: provider ?? this.provider,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      starTotal: starTotal ?? this.starTotal,
    );
  }
}
