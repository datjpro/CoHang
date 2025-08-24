import 'package:flutter/foundation.dart';
import '../models/classroom.dart';
import '../models/student.dart';
import '../services/database_service.dart';

class ClassRoomProvider with ChangeNotifier {
  List<ClassRoom> _classRooms = [];
  List<Student> _students = [];
  ClassRoom? _selectedClassRoom;
  bool _isLoading = false;
  String? _errorMessage;

  List<ClassRoom> get classRooms => _classRooms;
  List<Student> get students => _students;
  ClassRoom? get selectedClassRoom => _selectedClassRoom;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final DatabaseService _databaseService = DatabaseService();

  Future<void> loadClassRooms(int teacherId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _classRooms = await _databaseService.getClassRoomsByTeacher(teacherId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Lỗi tải danh sách lớp: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addClassRoom(ClassRoom classRoom) async {
    try {
      final id = await _databaseService.insertClassRoom(classRoom);
      final newClassRoom = classRoom.copyWith(id: id);
      _classRooms.add(newClassRoom);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Lỗi thêm lớp học: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> updateClassRoom(ClassRoom classRoom) async {
    try {
      await _databaseService.updateClassRoom(classRoom);
      final index = _classRooms.indexWhere((c) => c.id == classRoom.id);
      if (index != -1) {
        _classRooms[index] = classRoom;
        if (_selectedClassRoom?.id == classRoom.id) {
          _selectedClassRoom = classRoom;
        }
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Lỗi cập nhật lớp học: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> deleteClassRoom(int id) async {
    try {
      await _databaseService.deleteClassRoom(id);
      _classRooms.removeWhere((c) => c.id == id);
      if (_selectedClassRoom?.id == id) {
        _selectedClassRoom = null;
        _students.clear();
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Lỗi xóa lớp học: ${e.toString()}';
      notifyListeners();
    }
  }

  void selectClassRoom(ClassRoom classRoom) {
    _selectedClassRoom = classRoom;
    loadStudents(classRoom.id!);
    notifyListeners();
  }

  void deselectClassRoom() {
    _selectedClassRoom = null;
    _students.clear();
    notifyListeners();
  }

  void clearSelection() {
    deselectClassRoom();
  }

  Future<void> loadStudents(int classRoomId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _students = await _databaseService.getStudentsByClassRoom(classRoomId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Lỗi tải danh sách học sinh: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addStudent(Student student) async {
    try {
      final id = await _databaseService.insertStudent(student);
      final newStudent = student.copyWith(id: id);
      _students.add(newStudent);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Lỗi thêm học sinh: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> updateStudent(Student student) async {
    try {
      await _databaseService.updateStudent(student);
      final index = _students.indexWhere((s) => s.id == student.id);
      if (index != -1) {
        _students[index] = student;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Lỗi cập nhật học sinh: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> deleteStudent(int id) async {
    try {
      await _databaseService.deleteStudent(id);
      _students.removeWhere((s) => s.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Lỗi xóa học sinh: ${e.toString()}';
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
