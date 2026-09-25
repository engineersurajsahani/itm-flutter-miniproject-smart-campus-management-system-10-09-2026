class Course {
  final int id;
  final String name;
  final String code;
  final int facultyId;
  final String? facultyName;
  final String? department;

  Course({
    required this.id,
    required this.name,
    required this.code,
    required this.facultyId,
    this.facultyName,
    this.department,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] is int ? json['id'] : (int.tryParse(json['id'].toString()) ?? 0),
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      facultyId: json['facultyId'] ?? json['faculty_id'] ?? 0,
      facultyName: json['facultyName'] ?? json['faculty_name'],
      department: json['department'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'facultyId': facultyId,
      'facultyName': facultyName,
      'department': department,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'facultyId': facultyId,
      'facultyName': facultyName,
      'department': department,
    };
  }

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'] is int ? map['id'] : (int.tryParse(map['id'].toString()) ?? 0),
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      facultyId: map['facultyId'] ?? map['faculty_id'] ?? 0,
      facultyName: map['facultyName'] ?? map['faculty_name'],
      department: map['department'],
    );
  }
}
