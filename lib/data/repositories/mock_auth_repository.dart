import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibeco_app/data/mock/mock_database.dart';
import 'package:vibeco_app/data/models/user_model.dart';
import 'package:vibeco_app/domain/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  static const String _sessionKey = 'auth_session';
  static const String _roleKey = 'auth_role';

  @override
  Future<StudentModel?> loginStudent(String nis, String password) async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate network lag
    final student = MockDatabase.findStudentByNis(nis);
    if (student != null && password == 'password') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sessionKey, jsonEncode(student.toJson()));
      await prefs.setString(_roleKey, UserRole.student.name);
      return student;
    }
    return null;
  }

  @override
  Future<TeacherModel?> loginTeacher(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final teacher = MockDatabase.findTeacherByEmail(email);
    if (teacher != null && password == 'password') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sessionKey, jsonEncode(teacher.toJson()));
      await prefs.setString(_roleKey, teacher.role.name);
      return teacher;
    }
    return null;
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    await prefs.remove(_roleKey);
  }

  @override
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_sessionKey);
  }

  Future<dynamic> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionData = prefs.getString(_sessionKey);
    final roleData = prefs.getString(_roleKey);
    if (sessionData == null || roleData == null) return null;

    final decoded = jsonDecode(sessionData) as Map<String, dynamic>;
    if (roleData == UserRole.student.name) {
      return StudentModel.fromJson(decoded);
    } else {
      return TeacherModel.fromJson(decoded);
    }
  }
}
