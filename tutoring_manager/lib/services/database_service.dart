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

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path;

    if (kIsWeb) {
      // Cho web, sử dụng tên database đơn giản - lưu trữ trong IndexedDB
      path = 'tutoring_manager.db';
      print('Initializing IndexedDB database for web: $path');
    } else {
      // Cho desktop, tạo thư mục và đường dẫn như trước
      Directory appDir = await getApplicationDocumentsDirectory();
      final dbDir = Directory(join(appDir.path, 'TutoringManager'));
      if (!await dbDir.exists()) {
        await dbDir.create(recursive: true);
      }
      path = join(dbDir.path, 'tutoring_manager.db');
      print('Database path: $path');
    }
    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    print('Creating database tables...');

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
    '''); // Students table
    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL,
        gender TEXT NOT NULL DEFAULT 'Khác',
        dateOfBirth INTEGER NOT NULL,
        birthPlace TEXT NOT NULL DEFAULT '',
        currentAddress TEXT NOT NULL DEFAULT '',
        schoolClass TEXT NOT NULL,
        phone TEXT,
        guardianName TEXT NOT NULL,
        guardianPhone TEXT NOT NULL,
        email TEXT NOT NULL DEFAULT '',
        ethnicity TEXT NOT NULL DEFAULT 'Kinh',
        note TEXT,
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

    print('Database initialized successfully with default data');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('Upgrading database from version $oldVersion to $newVersion');

    if (oldVersion < 2) {
      // Add missing columns to students table one by one
      List<String> columnsToAdd = [
        'ALTER TABLE students ADD COLUMN gender TEXT NOT NULL DEFAULT "Khác"',
        'ALTER TABLE students ADD COLUMN dateOfBirth INTEGER NOT NULL DEFAULT ${DateTime.now().millisecondsSinceEpoch}',
        'ALTER TABLE students ADD COLUMN birthPlace TEXT NOT NULL DEFAULT ""',
        'ALTER TABLE students ADD COLUMN currentAddress TEXT NOT NULL DEFAULT ""',
        'ALTER TABLE students ADD COLUMN email TEXT NOT NULL DEFAULT ""',
        'ALTER TABLE students ADD COLUMN ethnicity TEXT NOT NULL DEFAULT "Kinh"',
        'ALTER TABLE students ADD COLUMN note TEXT',
      ];

      for (String alterQuery in columnsToAdd) {
        try {
          await db.execute(alterQuery);
          print('Successfully executed: $alterQuery');
        } catch (e) {
          print('Column might already exist or error: $e');
          // Continue with next column
        }
      }

      // Update existing records with proper default values
      try {
        await db.execute(
          'UPDATE students SET dateOfBirth = ? WHERE dateOfBirth = 0',
          [DateTime.now().millisecondsSinceEpoch],
        );
        print('Successfully updated default dateOfBirth values');
      } catch (e) {
        print('Error updating dateOfBirth defaults: $e');
      }
    }

    if (oldVersion < 3) {
      // Add guardian columns that were missing in version 2
      List<String> guardianColumns = [
        'ALTER TABLE students ADD COLUMN guardianName TEXT NOT NULL DEFAULT ""',
        'ALTER TABLE students ADD COLUMN guardianPhone TEXT NOT NULL DEFAULT ""',
      ];

      for (String alterQuery in guardianColumns) {
        try {
          await db.execute(alterQuery);
          print('Successfully executed: $alterQuery');
        } catch (e) {
          print('Column might already exist or error: $e');
          // Continue with next column
        }
      }
    }

    print('Database upgrade completed');
  }

  // Teacher methods
  Future<Teacher?> loginTeacher(String username, String password) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'teachers',
        where: 'username = ? AND password = ?',
        whereArgs: [username, password],
      );

      if (maps.isNotEmpty) {
        print('Login successful for user: $username');
        return Teacher.fromMap(maps.first);
      }
      print('Login failed for user: $username');
      return null;
    } catch (e) {
      print('Error during login: $e');
      return null;
    }
  }

  // ClassRoom methods
  Future<int> insertClassRoom(ClassRoom classRoom) async {
    try {
      final db = await database;

      // Validate classroom data
      if (classRoom.className.isEmpty) {
        throw Exception('Tên lớp học không được để trống');
      }

      if (classRoom.schedule.isEmpty) {
        throw Exception('Lịch học không được để trống');
      }

      if (classRoom.teacherId <= 0) {
        throw Exception('ID giáo viên không hợp lệ');
      }

      // Check if teacher exists
      final teacherExists = await db.query(
        'teachers',
        where: 'id = ?',
        whereArgs: [classRoom.teacherId],
      );

      if (teacherExists.isEmpty) {
        throw Exception('Giáo viên không tồn tại');
      }

      final classRoomMap = classRoom.toMap();
      print('Inserting classroom data: $classRoomMap');

      final result = await db.insert('classrooms', classRoomMap);
      print('Inserted classroom with ID: $result');
      return result;
    } catch (e) {
      print('Error inserting classroom: $e');
      rethrow;
    }
  }

  Future<List<ClassRoom>> getClassRoomsByTeacher(int teacherId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'classrooms',
      where: 'teacherId = ?',
      whereArgs: [teacherId],
      orderBy: 'className ASC',
    );
    print('Found ${maps.length} classrooms for teacher $teacherId');
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
    print('Updated classroom with ID: ${classRoom.id}');
  }

  Future<void> deleteClassRoom(int id) async {
    final db = await database;
    // Delete related students first
    await db.delete('students', where: 'classRoomId = ?', whereArgs: [id]);
    // Delete related attendance records
    await db.rawDelete(
      '''
      DELETE FROM attendance 
      WHERE studentId IN (
        SELECT id FROM students WHERE classRoomId = ?
      )
    ''',
      [id],
    );
    // Delete classroom
    await db.delete('classrooms', where: 'id = ?', whereArgs: [id]);
    print('Deleted classroom with ID: $id');
  }

  // Student methods
  Future<int> insertStudent(Student student) async {
    try {
      final db = await database;

      // Validate student data before insertion
      if (student.firstName.isEmpty || student.lastName.isEmpty) {
        throw Exception('Tên và họ học sinh không được để trống');
      }

      if (student.guardianName.isEmpty || student.guardianPhone.isEmpty) {
        throw Exception('Tên và số điện thoại người thân không được để trống');
      }

      if (student.classRoomId <= 0) {
        throw Exception('ID lớp học không hợp lệ');
      }

      // Check if classroom exists
      final classroomExists = await db.query(
        'classrooms',
        where: 'id = ?',
        whereArgs: [student.classRoomId],
      );

      if (classroomExists.isEmpty) {
        throw Exception('Lớp học không tồn tại');
      }

      final studentMap = student.toMap();
      print('Inserting student data: $studentMap');

      final result = await db.insert('students', studentMap);
      print('Inserted student with ID: $result');
      return result;
    } catch (e) {
      print('Error inserting student: $e');
      rethrow;
    }
  }

  Future<List<Student>> getStudentsByClassRoom(int classRoomId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'students',
      where: 'classRoomId = ?',
      whereArgs: [classRoomId],
      orderBy: 'lastName ASC, firstName ASC',
    );
    print('Found ${maps.length} students for classroom $classRoomId');
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
    print('Updated student with ID: ${student.id}');
  }

  Future<void> deleteStudent(int id) async {
    final db = await database;
    // Delete related attendance records first
    await db.delete('attendance', where: 'studentId = ?', whereArgs: [id]);
    // Delete student
    await db.delete('students', where: 'id = ?', whereArgs: [id]);
    print('Deleted student with ID: $id');
  }

  // Attendance methods
  Future<int> insertAttendance(Attendance attendance) async {
    try {
      final db = await database;

      // Validate attendance data
      if (attendance.studentId <= 0) {
        throw Exception('ID học sinh không hợp lệ');
      }

      // Check if student exists
      final studentExists = await db.query(
        'students',
        where: 'id = ?',
        whereArgs: [attendance.studentId],
      );

      if (studentExists.isEmpty) {
        throw Exception('Học sinh không tồn tại');
      }

      // Check if attendance for this student and date already exists
      final existingAttendance = await db.query(
        'attendance',
        where: 'studentId = ? AND date = ?',
        whereArgs: [
          attendance.studentId,
          attendance.date.millisecondsSinceEpoch,
        ],
      );

      if (existingAttendance.isNotEmpty) {
        // Update existing attendance instead of inserting
        final existingId = existingAttendance.first['id'] as int;
        await db.update(
          'attendance',
          attendance.toMap(),
          where: 'id = ?',
          whereArgs: [existingId],
        );
        print('Updated existing attendance with ID: $existingId');
        return existingId;
      }

      final attendanceMap = attendance.toMap();
      print('Inserting attendance data: $attendanceMap');

      final result = await db.insert('attendance', attendanceMap);
      print('Inserted attendance with ID: $result');
      return result;
    } catch (e) {
      print('Error inserting attendance: $e');
      rethrow;
    }
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

  Future<List<Attendance>> getAttendanceByDate(
    int classRoomId,
    DateTime date,
  ) async {
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
    final db = await database;
    await db.update(
      'attendance',
      attendance.toMap(),
      where: 'id = ?',
      whereArgs: [attendance.id],
    );
    print('Updated attendance with ID: ${attendance.id}');
  }

  Future<void> deleteAttendance(int id) async {
    final db = await database;
    await db.delete('attendance', where: 'id = ?', whereArgs: [id]);
    print('Deleted attendance with ID: $id');
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      print('Database closed');
    }
  }

  // Additional utility methods
  Future<int> insertTeacher(Teacher teacher) async {
    final db = await database;
    final result = await db.insert('teachers', teacher.toMap());
    print('Inserted teacher with ID: $result');
    return result;
  }

  Future<List<Teacher>> getAllTeachers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('teachers');
    return List.generate(maps.length, (i) => Teacher.fromMap(maps[i]));
  }

  // Database statistics
  Future<Map<String, int>> getDatabaseStats() async {
    final db = await database;

    final teacherCount = await db.rawQuery(
      'SELECT COUNT(*) as count FROM teachers',
    );
    final classroomCount = await db.rawQuery(
      'SELECT COUNT(*) as count FROM classrooms',
    );
    final studentCount = await db.rawQuery(
      'SELECT COUNT(*) as count FROM students',
    );
    final attendanceCount = await db.rawQuery(
      'SELECT COUNT(*) as count FROM attendance',
    );

    return {
      'teachers': teacherCount.first['count'] as int,
      'classrooms': classroomCount.first['count'] as int,
      'students': studentCount.first['count'] as int,
      'attendance': attendanceCount.first['count'] as int,
    };
  }

  // Test database connection
  Future<bool> testConnection() async {
    try {
      final db = await database;
      await db.rawQuery('SELECT 1');
      print('Database connection test successful');
      return true;
    } catch (e) {
      print('Database connection test failed: $e');
      return false;
    }
  }

  // Check and repair database structure
  Future<Map<String, dynamic>> checkDatabaseIntegrity() async {
    try {
      final db = await database;
      Map<String, dynamic> result = {
        'isHealthy': true,
        'issues': <String>[],
        'tables': <String, bool>{},
      };

      // Check if all required tables exist
      final tables = ['teachers', 'classrooms', 'students', 'attendance'];
      for (String tableName in tables) {
        try {
          await db.rawQuery('SELECT COUNT(*) FROM $tableName');
          result['tables'][tableName] = true;
          print('Table $tableName exists and is accessible');
        } catch (e) {
          result['tables'][tableName] = false;
          result['issues'].add('Table $tableName is missing or corrupted');
          result['isHealthy'] = false;
          print('Table $tableName issue: $e');
        }
      }

      // Check if students table has all required columns
      try {
        final studentsInfo = await db.rawQuery('PRAGMA table_info(students)');
        List<String> requiredColumns = [
          'id',
          'firstName',
          'lastName',
          'gender',
          'dateOfBirth',
          'birthPlace',
          'currentAddress',
          'schoolClass',
          'phone',
          'guardianName',
          'guardianPhone',
          'email',
          'ethnicity',
          'note',
          'classRoomId',
          'createdAt',
        ];

        List<String> existingColumns =
            studentsInfo.map((col) => col['name'] as String).toList();

        for (String column in requiredColumns) {
          if (!existingColumns.contains(column)) {
            result['issues'].add(
              'Column $column is missing from students table',
            );
            result['isHealthy'] = false;
          }
        }

        print('Students table columns check completed');
      } catch (e) {
        result['issues'].add('Cannot check students table structure: $e');
        result['isHealthy'] = false;
      }

      return result;
    } catch (e) {
      print('Database integrity check failed: $e');
      return {
        'isHealthy': false,
        'issues': ['Database integrity check failed: $e'],
        'tables': <String, bool>{},
      };
    }
  }

  // Repair database structure
  Future<bool> repairDatabase() async {
    try {
      final db = await database;

      // Try to recreate tables if they don't exist
      await _onCreate(db, 2);

      print('Database repair attempt completed');
      return true;
    } catch (e) {
      print('Database repair failed: $e');
      return false;
    }
  }

  // Reset database completely
  Future<bool> resetDatabase() async {
    try {
      if (_database != null) {
        await _database!.close();
        _database = null;
      }

      String path;
      if (kIsWeb) {
        path = 'tutoring_manager.db';
      } else {
        Directory appDir = await getApplicationDocumentsDirectory();
        final dbDir = Directory(join(appDir.path, 'TutoringManager'));
        path = join(dbDir.path, 'tutoring_manager.db');
      }

      // Delete the database file
      final dbFile = File(path);
      if (await dbFile.exists()) {
        await dbFile.delete();
        print('Database file deleted: $path');
      }

      // Recreate database with latest schema
      _database = await _initDatabase();
      print('Database recreated successfully');
      return true;
    } catch (e) {
      print('Error resetting database: $e');
      return false;
    }
  }
}
