import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibeco_app/data/models/user_model.dart';
import 'package:vibeco_app/data/repositories/mock_auth_repository.dart';
import 'package:vibeco_app/data/repositories/mock_cleaning_repository.dart';
import 'package:vibeco_app/data/repositories/mock_student_repository.dart';
import 'package:vibeco_app/domain/repositories/auth_repository.dart';
import 'package:vibeco_app/domain/repositories/cleaning_repository.dart';
import 'package:vibeco_app/domain/repositories/student_repository.dart';

// Repository Providers
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return MockAuthRepository();
});

final cleaningRepositoryProvider = Provider<CleaningRepository>((ref) {
  return MockCleaningRepository();
});

final studentRepositoryProvider = Provider<StudentRepository>((ref) {
  return MockStudentRepository();
});

// Auth State Definition
class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final StudentModel? student;
  final TeacherModel? teacher;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.student,
    this.teacher,
  });

  bool get isAuthenticated => student != null || teacher != null;
  UserRole? get role {
    if (student != null) return UserRole.student;
    if (teacher != null) return teacher!.role;
    return null;
  }

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    StudentModel? student,
    TeacherModel? teacher,
    bool clearUser = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      student: clearUser ? null : (student ?? this.student),
      teacher: clearUser ? null : (teacher ?? this.teacher),
    );
  }
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AuthState()) {
    checkSession();
  }

  Future<void> checkSession() async {
    state = state.copyWith(isLoading: true);
    final isLogged = await _authRepository.isLoggedIn();
    if (isLogged && _authRepository is MockAuthRepository) {
      final user = await (_authRepository as MockAuthRepository).getCurrentUser();
      if (user is StudentModel) {
        state = state.copyWith(student: user, isLoading: false);
      } else if (user is TeacherModel) {
        state = state.copyWith(teacher: user, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, clearUser: true);
      }
    } else {
      state = state.copyWith(isLoading: false, clearUser: true);
    }
  }

  Future<bool> loginStudent(String nis, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final student = await _authRepository.loginStudent(nis, password);
      if (student != null) {
        state = state.copyWith(student: student, isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Invalid NIS or Password',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An error occurred. Please try again.',
      );
      return false;
    }
  }

  Future<bool> loginTeacher(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final teacher = await _authRepository.loginTeacher(email, password);
      if (teacher != null) {
        state = state.copyWith(teacher: teacher, isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Invalid Email or Password',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An error occurred. Please try again.',
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _authRepository.logout();
    state = const AuthState();
  }
}

// Auth State Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository);
});
