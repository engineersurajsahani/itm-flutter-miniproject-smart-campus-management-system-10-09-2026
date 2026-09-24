class Attendance {
  final int id;
  final int studentId;
  final String? studentName;
  final int courseId;
  final String? courseName;
  final String date;
  final String status;
  final int? markedBy;

  Attendance({
    required this.id,
    required this.studentId,
    this.studentName,
    required this.courseId,
    this.courseName,
    required this.date,
    required this.status,
    this.markedBy,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] is int ? json['id'] : (int.tryParse(json['id'].toString()) ?? 0),
      studentId: json['studentId'] ?? json['student_id'] ?? 0,
      studentName: json['studentName'] ?? json['student_name'],
      courseId: json['courseId'] ?? json['course_id'] ?? 0,
      courseName: json['courseName'] ?? json['course_name'],
      date: json['date'] ?? '',
      status: json['status'] ?? 'present',
      markedBy: json['markedBy'] ?? json['marked_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'courseId': courseId,
      'courseName': courseName,
      'date': date,
      'status': status,
      'markedBy': markedBy,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'courseId': courseId,
      'courseName': courseName,
      'date': date,
      'status': status,
      'markedBy': markedBy,
    };
  }

  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      id: map['id'] is int ? map['id'] : (int.tryParse(map['id'].toString()) ?? 0),
      studentId: map['studentId'] ?? map['student_id'] ?? 0,
      studentName: map['studentName'] ?? map['student_name'],
      courseId: map['courseId'] ?? map['course_id'] ?? 0,
      courseName: map['courseName'] ?? map['course_name'],
      date: map['date'] ?? '',
      status: map['status'] ?? 'present',
      markedBy: map['markedBy'] ?? map['marked_by'],
    );
  }
}
