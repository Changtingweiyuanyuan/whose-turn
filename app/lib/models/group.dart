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

  String get inviteLink => 'https://whoseturn.app/j/$inviteCode';
}
