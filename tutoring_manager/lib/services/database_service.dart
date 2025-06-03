import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/teacher.dart';
import '../models/classroom.dart';
import '../models/student.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  // Mock data cho web
  final List<Map<String, dynamic>> _mockClassRooms = [];
  final List<Map<String, dynamic>> _mockStudents = [];
  int _nextClassRoomId = 1;
  int _nextStudentId = 1;

  Future<Database> get database async {
    if (_database != null) return _database!;

    if (kIsWeb) {
      throw UnsupportedError(
        'Database not supported on web platform. Please run on Windows/Desktop.',
      );
    }

    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      throw UnsupportedError(
        'Database not supported on web platform. Please run on Windows/Desktop.',
      );
    }

    Directory appDir = await getApplicationDocumentsDirectory();
    final dbDir = Directory(join(appDir.path, 'TutoringManager'));
    if (!await dbDir.exists()) {
      await dbDir.create(recursive: true);
    }
    String path = join(dbDir.path, 'tutoring_manager.db');

    print('Database path: $path');
    print('Database directory exists: ${await dbDir.exists()}');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Teachers table
    await db.execute('''
      CREATE TABLE teachers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        fullName TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT NOT NULL,
        createdAt INTEGER NOT NULL
      )
    ''');

    // ClassRooms table
    await db.execute('''
      CREATE TABLE classrooms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        className TEXT NOT NULL,
        subject TEXT NOT NULL,
        schedule TEXT NOT NULL,
        groupChatLink TEXT NOT NULL,
        teacherId INTEGER NOT NULL,
        createdAt INTEGER NOT NULL,
        FOREIGN KEY (teacherId) REFERENCES teachers (id)
      )
    ''');

    // Students table
    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL,
        schoolClass TEXT NOT NULL,
        phone TEXT NOT NULL,
        parentName TEXT NOT NULL,
        parentPhone TEXT NOT NULL,
        classRoomId INTEGER NOT NULL,
        createdAt INTEGER NOT NULL,
        FOREIGN KEY (classRoomId) REFERENCES classrooms (id)
      )
    ''');

    // Attendance table
    await db.execute('''
      CREATE TABLE attendance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        studentId INTEGER NOT NULL,
        date INTEGER NOT NULL,
        isPresent INTEGER NOT NULL,
        note TEXT,
        FOREIGN KEY (studentId) REFERENCES students (id)
      )
    ''');

    // Insert default teacher account
    await db.insert('teachers', {
      'username': 'admin',
      'password': '123456',
      'fullName': 'Giáo viên mặc định',
      'phone': '0123456789',
      'email': 'admin@example.com',
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // Teacher methods
  Future<Teacher?> loginTeacher(String username, String password) async {
    if (kIsWeb) {
      // Mock login for web testing
      if (username == 'admin' && password == '123456') {
        return Teacher(
          id: 1,
          username: 'admin',
          password: '123456',
          fullName: 'Giáo viên mặc định',
          phone: '0123456789',
          email: 'admin@example.com',
          createdAt: DateTime.now(),
        );
      }
      return null;
    }

    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'teachers',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (maps.isNotEmpty) {
      return Teacher.fromMap(maps.first);
    }
    return null;
  }

  // ClassRoom methods
  Future<int> insertClassRoom(ClassRoom classRoom) async {
    if (kIsWeb) {
      // Mock insert for web
      final id = _nextClassRoomId++;
      _mockClassRooms.add({
        'id': id,
        'className': classRoom.className,
        'subject': classRoom.subject.name,
        'schedule': classRoom.schedule,
        'groupChatLink': classRoom.groupChatLink,
        'teacherId': classRoom.teacherId,
        'createdAt': classRoom.createdAt.millisecondsSinceEpoch,
      });
      return id;
    }
    final db = await database;
    return await db.insert('classrooms', classRoom.toMap());
  }

  Future<List<ClassRoom>> getClassRoomsByTeacher(int teacherId) async {
    if (kIsWeb) {
      // Return mock data for web
      final filteredClassRooms =
          _mockClassRooms.where((c) => c['teacherId'] == teacherId).toList();
      return filteredClassRooms.map((map) => ClassRoom.fromMap(map)).toList();
    }
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'classrooms',
      where: 'teacherId = ?',
      whereArgs: [teacherId],
      orderBy: 'className ASC',
    );
    return List.generate(maps.length, (i) => ClassRoom.fromMap(maps[i]));
  }

  Future<void> updateClassRoom(ClassRoom classRoom) async {
    if (kIsWeb) {
      // Mock update for web
      final index = _mockClassRooms.indexWhere((c) => c['id'] == classRoom.id);
      if (index != -1) {
        _mockClassRooms[index] = {
          'id': classRoom.id,
          'className': classRoom.className,
          'subject': classRoom.subject.name,
          'schedule': classRoom.schedule,
          'groupChatLink': classRoom.groupChatLink,
          'teacherId': classRoom.teacherId,
          'createdAt': classRoom.createdAt.millisecondsSinceEpoch,
        };
      }
      return;
    }
    final db = await database;
    await db.update(
      'classrooms',
      classRoom.toMap(),
      where: 'id = ?',
      whereArgs: [classRoom.id],
    );
  }

  Future<void> deleteClassRoom(int id) async {
    if (kIsWeb) {
      // Mock delete for web
      _mockClassRooms.removeWhere((c) => c['id'] == id);
      _mockStudents.removeWhere((s) => s['classRoomId'] == id);
      return;
    }
    final db = await database;
    await db.delete('classrooms', where: 'id = ?', whereArgs: [id]);
  }

  // Student methods
  Future<int> insertStudent(Student student) async {
    if (kIsWeb) {
      // Mock insert for web
      final id = _nextStudentId++;
      _mockStudents.add({
        'id': id,
        'firstName': student.firstName,
        'lastName': student.lastName,
        'schoolClass': student.schoolClass,
        'phone': student.phone,
        'parentName': student.parentName,
        'parentPhone': student.parentPhone,
        'classRoomId': student.classRoomId,
        'createdAt': student.createdAt.millisecondsSinceEpoch,
      });
      return id;
    }
    final db = await database;
    return await db.insert('students', student.toMap());
  }

  Future<List<Student>> getStudentsByClassRoom(int classRoomId) async {
    if (kIsWeb) {
      // Return mock data for web
      final filteredStudents =
          _mockStudents.where((s) => s['classRoomId'] == classRoomId).toList();
      return filteredStudents.map((map) => Student.fromMap(map)).toList();
    }
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'students',
      where: 'classRoomId = ?',
      whereArgs: [classRoomId],
      orderBy: 'lastName ASC, firstName ASC',
    );
    return List.generate(maps.length, (i) => Student.fromMap(maps[i]));
  }

  Future<void> updateStudent(Student student) async {
    if (kIsWeb) {
      // Mock update for web
      final index = _mockStudents.indexWhere((s) => s['id'] == student.id);
      if (index != -1) {
        _mockStudents[index] = {
          'id': student.id,
          'firstName': student.firstName,
          'lastName': student.lastName,
          'schoolClass': student.schoolClass,
          'phone': student.phone,
          'parentName': student.parentName,
          'parentPhone': student.parentPhone,
          'classRoomId': student.classRoomId,
          'createdAt': student.createdAt.millisecondsSinceEpoch,
        };
      }
      return;
    }
    final db = await database;
    await db.update(
      'students',
      student.toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  Future<void> deleteStudent(int id) async {
    if (kIsWeb) {
      // Mock delete for web
      _mockStudents.removeWhere((s) => s['id'] == id);
      return;
    }
    final db = await database;
    await db.delete('students', where: 'id = ?', whereArgs: [id]);
  }

  // Attendance methods (simplified for web)
  Future<int> insertAttendance(Attendance attendance) async {
    if (kIsWeb) {
      return 1; // Mock return
    }
    final db = await database;
    return await db.insert('attendance', attendance.toMap());
  }

  Future<List<Attendance>> getAttendanceByStudent(int studentId) async {
    if (kIsWeb) {
      return []; // Return empty list for web
    }
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'attendance',
      where: 'studentId = ?',
      whereArgs: [studentId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Attendance.fromMap(maps[i]));
  }

  Future<List<Attendance>> getAttendanceByDate(
    int classRoomId,
    DateTime date,
  ) async {
    if (kIsWeb) {
      return []; // Return empty list for web
    }
    final db = await database;
    final students = await getStudentsByClassRoom(classRoomId);
    List<Attendance> attendances = [];

    for (var student in students) {
      final maps = await db.query(
        'attendance',
        where: 'studentId = ? AND date = ?',
        whereArgs: [student.id, date.millisecondsSinceEpoch],
      );

      if (maps.isNotEmpty) {
        attendances.add(Attendance.fromMap(maps.first));
      }
    }

    return attendances;
  }

  Future<void> updateAttendance(Attendance attendance) async {
    if (kIsWeb) {
      return; // Mock update
    }
    final db = await database;
    await db.update(
      'attendance',
      attendance.toMap(),
      where: 'id = ?',
      whereArgs: [attendance.id],
    );
  }

  Future<void> deleteAttendance(int id) async {
    if (kIsWeb) {
      return; // Mock delete
    }
    final db = await database;
    await db.delete('attendance', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    if (kIsWeb) {
      return; // Do nothing on web
    }
    final db = await database;
    await db.close();
  }

  // Missing methods from models
  Future<int> insertTeacher(Teacher teacher) async {
    if (kIsWeb) {
      return 1; // Mock return
    }
    final db = await database;
    return await db.insert('teachers', teacher.toMap());
  }

  Future<List<Teacher>> getAllTeachers() async {
    if (kIsWeb) {
      return []; // Return empty list for web
    }
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('teachers');
    return List.generate(maps.length, (i) => Teacher.fromMap(maps[i]));
  }
}
