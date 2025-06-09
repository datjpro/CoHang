import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/teacher.dart';
import '../models/classroom.dart';
import '../models/student.dart';
import '../models/schedule.dart';
import '../widgets/database_test_widget.dart';

class DatabaseDebugScreen extends StatefulWidget {
  const DatabaseDebugScreen({super.key});

  @override
  State<DatabaseDebugScreen> createState() => _DatabaseDebugScreenState();
}

class _DatabaseDebugScreenState extends State<DatabaseDebugScreen> {
  final DatabaseService _dbService = DatabaseService();
  final TextEditingController _logController = TextEditingController();
  List<String> _logs = [];
  void _addLog(String message) {
    setState(() {
      _logs.add('[${DateTime.now().toString().substring(11, 19)}] $message');
      _logController.text = _logs.join('\n');
    });
    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _logController.selection = TextSelection.fromPosition(
        TextPosition(offset: _logController.text.length),
      );
    });
  }

  Future<void> _testInsertTeacher() async {
    try {
      _addLog('Testing teacher insertion...');

      final teacher = Teacher(
        username: 'test_teacher_${DateTime.now().millisecondsSinceEpoch}',
        password: 'password123',
        fullName: 'Giáo viên Test',
        phone: '0987654321',
        email: 'test@example.com',
        createdAt: DateTime.now(),
      );

      final id = await _dbService.insertTeacher(teacher);
      _addLog('✓ Teacher inserted successfully with ID: $id');
    } catch (e) {
      _addLog('✗ Error inserting teacher: $e');
    }
  }

  Future<void> _testInsertClassroom() async {
    try {
      _addLog('Testing classroom insertion...');

      // Get first teacher
      final teachers = await _dbService.getAllTeachers();
      if (teachers.isEmpty) {
        _addLog('✗ No teachers found. Please insert a teacher first.');
        return;
      }
      final classroom = ClassRoom(
        className: 'Lớp Test ${DateTime.now().millisecondsSinceEpoch}',
        subject: Subject.math,
        schedule: const ClassSchedule(
          sessions: [
            ScheduleSession(
              dayOfWeek: DayOfWeek.monday,
              timeSlot: TimeSlot.evening19_21,
            ),
            ScheduleSession(
              dayOfWeek: DayOfWeek.wednesday,
              timeSlot: TimeSlot.evening19_21,
            ),
          ],
        ),
        groupChatLink: 'https://chat.example.com/test',
        teacherId: teachers.first.id!,
        createdAt: DateTime.now(),
      );

      final id = await _dbService.insertClassRoom(classroom);
      _addLog('✓ Classroom inserted successfully with ID: $id');
    } catch (e) {
      _addLog('✗ Error inserting classroom: $e');
    }
  }

  Future<void> _testInsertStudent() async {
    try {
      _addLog('Testing student insertion...');

      // Get first teacher and their classrooms
      final teachers = await _dbService.getAllTeachers();
      if (teachers.isEmpty) {
        _addLog('✗ No teachers found. Please insert a teacher first.');
        return;
      }

      final classrooms = await _dbService.getClassRoomsByTeacher(
        teachers.first.id!,
      );
      if (classrooms.isEmpty) {
        _addLog('✗ No classrooms found. Please insert a classroom first.');
        return;
      }

      final student = Student(
        firstName: 'Test',
        lastName: 'Nguyễn Văn',
        gender: 'Nam',
        dateOfBirth: DateTime(2005, 1, 1),
        birthPlace: 'Hà Nội',
        currentAddress: '123 Test Street',
        schoolClass: '10A1',
        phone: '0123456789',
        guardianName: 'Nguyễn Văn Phụ Huynh',
        guardianPhone: '0987654321',
        email: 'student@example.com',
        ethnicity: 'Kinh',
        note: 'Học sinh test',
        classRoomId: classrooms.first.id!,
        createdAt: DateTime.now(),
      );

      final id = await _dbService.insertStudent(student);
      _addLog('✓ Student inserted successfully with ID: $id');
    } catch (e) {
      _addLog('✗ Error inserting student: $e');
    }
  }

  Future<void> _testInsertAttendance() async {
    try {
      _addLog('Testing attendance insertion...');

      // Get first teacher and their students
      final teachers = await _dbService.getAllTeachers();
      if (teachers.isEmpty) {
        _addLog('✗ No teachers found.');
        return;
      }

      final classrooms = await _dbService.getClassRoomsByTeacher(
        teachers.first.id!,
      );
      if (classrooms.isEmpty) {
        _addLog('✗ No classrooms found.');
        return;
      }

      final students = await _dbService.getStudentsByClassRoom(
        classrooms.first.id!,
      );
      if (students.isEmpty) {
        _addLog('✗ No students found.');
        return;
      }

      final attendance = Attendance(
        studentId: students.first.id!,
        date: DateTime.now(),
        isPresent: true,
        note: 'Test attendance',
      );

      final id = await _dbService.insertAttendance(attendance);
      _addLog('✓ Attendance inserted successfully with ID: $id');
    } catch (e) {
      _addLog('✗ Error inserting attendance: $e');
    }
  }

  Future<void> _clearLogs() async {
    setState(() {
      _logs.clear();
      _logController.clear();
    });
  }

  Future<void> _resetDatabase() async {
    try {
      _addLog('⚠️ Resetting database...');

      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Reset Database'),
              content: const Text(
                'This will completely delete all data and recreate the database with the correct schema. This action cannot be undone.\n\nAre you sure?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Reset'),
                ),
              ],
            ),
      );

      if (confirmed != true) {
        _addLog('Database reset cancelled');
        return;
      }

      await _dbService.resetDatabase();
      _addLog('✓ Database reset successfully');
      _addLog('✓ New database created with correct schema');

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Database reset successfully! You can now test insertions.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _addLog('✗ Error resetting database: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error resetting database: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Debug'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Database Status Widget
            const DatabaseTestWidget(),

            const SizedBox(height: 20),

            // Test Buttons
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Database Operations Test',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _testInsertTeacher,
                          icon: const Icon(Icons.person_add),
                          label: const Text('Test Insert Teacher'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _testInsertClassroom,
                          icon: const Icon(Icons.class_),
                          label: const Text('Test Insert Classroom'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _testInsertStudent,
                          icon: const Icon(Icons.school),
                          label: const Text('Test Insert Student'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _testInsertAttendance,
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Test Insert Attendance'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        // Reset Database Button
                        ElevatedButton.icon(
                          onPressed: _resetDatabase,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reset Database'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Log Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Operation Logs',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: _clearLogs,
                          icon: const Icon(Icons.clear),
                          label: const Text('Clear Logs'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Container(
                      height: 300,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _logController,
                        maxLines: null,
                        expands: true,
                        readOnly: true,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(12),
                          border: InputBorder.none,
                          hintText: 'Operation logs will appear here...',
                        ),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _logController.dispose();
    super.dispose();
  }
}
