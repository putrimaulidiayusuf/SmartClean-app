import 'package:vibeco_app/data/models/user_model.dart';
import 'package:vibeco_app/data/models/schedule_models.dart';

abstract class StudentRepository {
  Future<List<StudentModel>> getStudentsByClass(String className);
  Future<StudentModel?> getStudentById(String id);
  Future<List<DutyScheduleModel>> getDutySchedule(String className);
  Future<DutyScheduleModel?> getTodaysDuty(String className);
  Future<List<RankingModel>> getClassRanking(String className);
  Future<List<RankingModel>> getSchoolRanking();
}
