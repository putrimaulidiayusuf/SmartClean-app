import 'package:vibeco_app/data/models/cleaning_record_model.dart';
import 'package:vibeco_app/data/models/schedule_models.dart';

abstract class CleaningRepository {
  Future<List<CleaningRecordModel>> getRecordsByStudent(String studentId);
  Future<List<CleaningRecordModel>> getRecordsByClass(String className);
  Future<List<CleaningRecordModel>> getPendingRecords();
  Future<List<CleaningRecordModel>> getVerifiedTodayRecords();
  Future<List<CleaningRecordModel>> getTodaysRecords();
  Future<CleaningRecordModel> submitRecord({
    required String studentId,
    required String studentName,
    required String className,
    required double score,
    required List<String> findings,
    required List<String> recommendations,
    String? photoPath,
  });
  Future<void> verifyRecord({
    required String recordId,
    required String teacherId,
    required String teacherName,
    required CleaningStatus status,
    double? newScore,
    String? notes,
  });
  Future<List<VerificationModel>> getAuditLogs();
}
