class Notice {
  final int id;
  final String title;
  final String content;
  final String targetRole;
  final int postedBy;
  final String? postedByName;
  final String? createdAt;

  Notice({
    required this.id,
    required this.title,
    required this.content,
    required this.targetRole,
    required this.postedBy,
    this.postedByName,
    this.createdAt,
  });

  String get author => postedByName ?? 'Admin';
  DateTime get createdDateTime => DateTime.tryParse(createdAt ?? '') ?? DateTime.now();

  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      targetRole: json['targetRole'] ?? json['target_role'] ?? 'all',
      postedBy: json['postedBy'] is int ? json['postedBy'] : (int.tryParse(json['posted_by']?.toString() ?? '') ?? 0),
      postedByName: json['postedByName'] ?? json['posted_by_name'] ?? json['poster_name'],
      createdAt: json['createdAt']?.toString() ?? json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'targetRole': targetRole,
      'postedBy': postedBy,
      'postedByName': postedByName,
      'createdAt': createdAt,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'targetRole': targetRole,
      'postedBy': postedBy,
      'postedByName': postedByName,
      'createdAt': createdAt,
    };
  }

  factory Notice.fromMap(Map<String, dynamic> map) {
    return Notice(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()) ?? 0,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      targetRole: map['targetRole'] ?? 'all',
      postedBy: map['postedBy'] is int ? map['postedBy'] : (int.tryParse(map['postedBy']?.toString() ?? '') ?? 0),
      postedByName: map['postedByName'],
      createdAt: map['createdAt']?.toString(),
    );
  }
}
