import 'package:vibeco_app/data/models/user_model.dart';

abstract class AuthRepository {
  Future<StudentModel?> loginStudent(String nis, String password);
  Future<TeacherModel?> loginTeacher(String email, String password);
  Future<void> logout();
  Future<bool> isLoggedIn();
}
