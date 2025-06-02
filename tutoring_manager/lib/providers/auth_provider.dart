import 'package:flutter/foundation.dart';
import '../models/teacher.dart';
import '../services/database_service.dart';

class AuthProvider with ChangeNotifier {
  Teacher? _currentTeacher;
  bool _isLoading = false;
  String? _errorMessage;

  Teacher? get currentTeacher => _currentTeacher;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentTeacher != null;

  final DatabaseService _databaseService = DatabaseService();

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final teacher = await _databaseService.loginTeacher(username, password);
      if (teacher != null) {
        _currentTeacher = teacher;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Tên đăng nhập hoặc mật khẩu không đúng!';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Lỗi đăng nhập: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _currentTeacher = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
