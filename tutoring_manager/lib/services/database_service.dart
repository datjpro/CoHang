import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/teacher.dart';
import '../models/classroom.dart';
import '../models/student.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    
    // Initialize SQLite for desktop
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'tutoring_manager.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
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
      'password': '123456', // In real app, this should be hashed
      'fullName': 'Giáo viên mặc định',
      'phone': '0123456789',
      'email': 'admin@example.com',
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // Teacher methods
  Future<Teacher?> loginTeacher(String username, String password) async {
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

  Future<int> insertTeacher(Teacher teacher) async {
    final db = await database;
    return await db.insert('teachers', teacher.toMap());
  }

  Future<List<Teacher>> getAllTeachers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('teachers');
    return List.generate(maps.length, (i) => Teacher.fromMap(maps[i]));
  }

  // ClassRoom methods
  Future<int> insertClassRoom(ClassRoom classRoom) async {
    final db = await database;
    return await db.insert('classrooms', classRoom.toMap());
  }

  Future<List<ClassRoom>> getClassRoomsByTeacher(int teacherId) async {
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
    final db = await database;
    await db.update(
      'classrooms',
      classRoom.toMap(),
      where: 'id = ?',
      whereArgs: [classRoom.id],
    );
  }

  Future<void> deleteClassRoom(int id) async {
    final db = await database;
    await db.delete(
      'classrooms',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Student methods
  Future<int> insertStudent(Student student) async {
    final db = await database;
    return await db.insert('students', student.toMap());
  }

  Future<List<Student>> getStudentsByClassRoom(int classRoomId) async {
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
    final db = await database;
    await db.update(
      'students',
      student.toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  Future<void> deleteStudent(int id) async {
    final db = await database;
    await db.delete(
      'students',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Attendance methods
  Future<int> insertAttendance(Attendance attendance) async {
    final db = await database;
    return await db.insert('attendance', attendance.toMap());
  }

  Future<List<Attendance>> getAttendanceByStudent(int studentId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'attendance',
      where: 'studentId = ?',
      whereArgs: [studentId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Attendance.fromMap(maps[i]));
  }

  Future<List<Attendance>> getAttendanceByDate(int classRoomId, DateTime date) async {
    final db = await database;
    // Get all students in the classroom first
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
    final db = await database;
    await db.update(
      'attendance',
      attendance.toMap(),
      where: 'id = ?',
      whereArgs: [attendance.id],
    );
  }

  Future<void> deleteAttendance(int id) async {
    final db = await database;
    await db.delete(
      'attendance',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
