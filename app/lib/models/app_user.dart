enum AuthProvider { line, anonymous }

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
