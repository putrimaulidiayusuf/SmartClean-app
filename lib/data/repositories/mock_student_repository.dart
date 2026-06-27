import 'package:vibeco_app/data/mock/mock_database.dart';
import 'package:vibeco_app/data/mock/mock_cleaning_data.dart';
import 'package:vibeco_app/data/models/user_model.dart';
import 'package:vibeco_app/data/models/schedule_models.dart';
import 'package:vibeco_app/domain/repositories/student_repository.dart';

class MockStudentRepository implements StudentRepository {
  @override
  Future<List<StudentModel>> getStudentsByClass(String className) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockDatabase.getStudentsByClass(className);
  }

  @override
  Future<StudentModel?> getStudentById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return MockDatabase.allStudents.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<DutyScheduleModel>> getDutySchedule(String className) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockDatabase.getDutySchedule(className);
  }

  @override
  Future<DutyScheduleModel?> getTodaysDuty(String className) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockDatabase.getTodaysDuty(className);
  }

  @override
  Future<List<RankingModel>> getClassRanking(String className) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockCleaningData.getClassRanking(className);
  }

  @override
  Future<List<RankingModel>> getSchoolRanking() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockCleaningData.getSchoolRanking();
  }
}
