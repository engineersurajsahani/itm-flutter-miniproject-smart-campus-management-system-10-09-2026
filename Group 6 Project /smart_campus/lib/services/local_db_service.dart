import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/notice.dart';
import '../models/attendance.dart';
import '../models/academic_record.dart';

class LocalDbService {
  static Database? _database;

  Future<Database?> get database async {
    if (kIsWeb) return null;
    if (_database != null) return _database!;
    _database = await initDb();
    return _database;
  }

  Future<Database?> initDb() async {
    if (kIsWeb) return null;

    try {
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, 'smart_campus.db');

      return await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE cached_users(
              id INTEGER PRIMARY KEY,
              name TEXT,
              email TEXT,
              role TEXT,
              department TEXT,
              token TEXT,
              createdAt TEXT
            )
          ''');

          await db.execute('''
            CREATE TABLE cached_notices(
              id INTEGER PRIMARY KEY,
              title TEXT,
              content TEXT,
              targetRole TEXT,
              postedBy INTEGER,
              postedByName TEXT,
              createdAt TEXT
            )
          ''');

          await db.execute('''
            CREATE TABLE cached_attendance(
              id INTEGER PRIMARY KEY,
              studentId INTEGER,
              studentName TEXT,
              courseId INTEGER,
              courseName TEXT,
              date TEXT,
              status TEXT,
              markedBy INTEGER
            )
          ''');

          await db.execute('''
            CREATE TABLE cached_grades(
              id INTEGER PRIMARY KEY,
              studentId INTEGER,
              studentName TEXT,
              courseId INTEGER,
              courseName TEXT,
              examType TEXT,
              marks REAL,
              totalMarks REAL,
              uploadedBy INTEGER
            )
          ''');
        },
      );
    } catch (e) {
      debugPrint('sqflite initDb skipped or failed: $e');
      return null;
    }
  }

  // Key-value helper methods using SharedPreferences (works on all platforms including Web)
  Future<void> saveData(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is String) {
      await prefs.setString(key, value);
    } else {
      await prefs.setString(key, jsonEncode(value));
    }
  }

  Future<dynamic> getData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final val = prefs.getString(key);
    if (val == null) return null;
    try {
      return jsonDecode(val);
    } catch (_) {
      return val;
    }
  }

  Future<void> removeData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  // User Caching
  Future<void> cacheUser(User user) async {
    final db = await database;
    if (db != null) {
      await db.insert(
        'cached_users',
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      await saveData('cached_user', user.toMap());
    }
  }

  Future<User?> getCachedUser() async {
    final db = await database;
    if (db != null) {
      final List<Map<String, dynamic>> maps = await db.query('cached_users', limit: 1);
      if (maps.isNotEmpty) {
        return User.fromMap(maps.first);
      }
    } else {
      final data = await getData('cached_user');
      if (data is Map<String, dynamic>) {
        return User.fromMap(data);
      }
    }
    return null;
  }

  // Notices Caching
  Future<void> cacheNotices(List<Notice> notices) async {
    final db = await database;
    if (db != null) {
      await db.transaction((txn) async {
        await txn.delete('cached_notices');
        for (var notice in notices) {
          await txn.insert('cached_notices', notice.toMap());
        }
      });
    } else {
      await saveData('cached_notices', notices.map((n) => n.toMap()).toList());
    }
  }

  Future<List<Notice>> getCachedNotices() async {
    final db = await database;
    if (db != null) {
      final List<Map<String, dynamic>> maps = await db.query('cached_notices');
      return maps.map((map) => Notice.fromMap(map)).toList();
    } else {
      final data = await getData('cached_notices');
      if (data is List) {
        return data.map((map) => Notice.fromMap(Map<String, dynamic>.from(map))).toList();
      }
    }
    return [];
  }

  // Attendance Caching
  Future<void> cacheAttendance(List<Attendance> attendanceList) async {
    final db = await database;
    if (db != null) {
      await db.transaction((txn) async {
        await txn.delete('cached_attendance');
        for (var attendance in attendanceList) {
          await txn.insert('cached_attendance', attendance.toMap());
        }
      });
    } else {
      await saveData('cached_attendance', attendanceList.map((a) => a.toMap()).toList());
    }
  }

  Future<List<Attendance>> getCachedAttendance() async {
    final db = await database;
    if (db != null) {
      final List<Map<String, dynamic>> maps = await db.query('cached_attendance');
      return maps.map((map) => Attendance.fromMap(map)).toList();
    } else {
      final data = await getData('cached_attendance');
      if (data is List) {
        return data.map((map) => Attendance.fromMap(Map<String, dynamic>.from(map))).toList();
      }
    }
    return [];
  }

  // Grades Caching
  Future<void> cacheGrades(List<AcademicRecord> grades) async {
    final db = await database;
    if (db != null) {
      await db.transaction((txn) async {
        await txn.delete('cached_grades');
        for (var grade in grades) {
          await txn.insert('cached_grades', grade.toMap());
        }
      });
    } else {
      await saveData('cached_grades', grades.map((g) => g.toMap()).toList());
    }
  }

  Future<List<AcademicRecord>> getCachedGrades() async {
    final db = await database;
    if (db != null) {
      final List<Map<String, dynamic>> maps = await db.query('cached_grades');
      return maps.map((map) => AcademicRecord.fromMap(map)).toList();
    } else {
      final data = await getData('cached_grades');
      if (data is List) {
        return data.map((map) => AcademicRecord.fromMap(Map<String, dynamic>.from(map))).toList();
      }
    }
    return [];
  }

  Future<void> clearAll() async {
    final db = await database;
    if (db != null) {
      await db.delete('cached_users');
      await db.delete('cached_notices');
      await db.delete('cached_attendance');
      await db.delete('cached_grades');
    }
    await removeData('cached_user');
    await removeData('cached_notices');
    await removeData('cached_attendance');
    await removeData('cached_grades');
  }
}
