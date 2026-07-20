class Group {
  const Group({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.createdBy,
    this.memberUids = const [],
  });

  final String id;
  final String name;
  final String inviteCode;
  final String createdBy;
  final List<String> memberUids;

  /// 邀請連結：web 上用當前站台網址（dev=localhost、prod=pages.dev），
  /// 非 http 環境（測試）退回正式站網址。
  String get inviteLink {
    final base = Uri.base.scheme.startsWith('http')
        ? Uri.base.origin
        : 'https://whose-turn-21w.pages.dev';
    return '$base/j/$inviteCode';
  }
}
