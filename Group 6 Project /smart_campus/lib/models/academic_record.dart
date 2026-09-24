class AcademicRecord {
  final int id;
  final int studentId;
  final String? studentName;
  final int courseId;
  final String? courseName;
  final String examType;
  final double marks;
  final double totalMarks;
  final int? uploadedBy;

  AcademicRecord({
    required this.id,
    required this.studentId,
    this.studentName,
    required this.courseId,
    this.courseName,
    required this.examType,
    required this.marks,
    required this.totalMarks,
    this.uploadedBy,
  });

  double get percentage => (totalMarks > 0) ? (marks / totalMarks * 100) : 0.0;

  factory AcademicRecord.fromJson(Map<String, dynamic> json) {
    return AcademicRecord(
      id: json['id'] is int ? json['id'] : (int.tryParse(json['id'].toString()) ?? 0),
      studentId: json['studentId'] ?? json['student_id'] ?? 0,
      studentName: json['studentName'] ?? json['student_name'],
      courseId: json['courseId'] ?? json['course_id'] ?? 0,
      courseName: json['courseName'] ?? json['course_name'],
      examType: json['examType'] ?? json['exam_type'] ?? '',
      marks: (json['marks'] as num?)?.toDouble() ?? 0.0,
      totalMarks: (json['totalMarks'] as num?)?.toDouble() ?? (json['total_marks'] as num?)?.toDouble() ?? 100.0,
      uploadedBy: json['uploadedBy'] ?? json['uploaded_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'courseId': courseId,
      'courseName': courseName,
      'examType': examType,
      'marks': marks,
      'totalMarks': totalMarks,
      'uploadedBy': uploadedBy,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'courseId': courseId,
      'courseName': courseName,
      'examType': examType,
      'marks': marks,
      'totalMarks': totalMarks,
      'uploadedBy': uploadedBy,
    };
  }

  factory AcademicRecord.fromMap(Map<String, dynamic> map) {
    return AcademicRecord(
      id: map['id'] is int ? map['id'] : (int.tryParse(map['id'].toString()) ?? 0),
      studentId: map['studentId'] ?? map['student_id'] ?? 0,
      studentName: map['studentName'] ?? map['student_name'],
      courseId: map['courseId'] ?? map['course_id'] ?? 0,
      courseName: map['courseName'] ?? map['course_name'],
      examType: map['examType'] ?? map['exam_type'] ?? '',
      marks: (map['marks'] as num?)?.toDouble() ?? 0.0,
      totalMarks: (map['totalMarks'] as num?)?.toDouble() ?? (map['total_marks'] as num?)?.toDouble() ?? 100.0,
      uploadedBy: map['uploadedBy'] ?? map['uploaded_by'],
    );
  }
}
