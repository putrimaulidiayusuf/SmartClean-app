import 'package:uuid/uuid.dart';
import 'package:vibeco_app/data/mock/mock_cleaning_data.dart';
import 'package:vibeco_app/data/models/cleaning_record_model.dart';
import 'package:vibeco_app/data/models/schedule_models.dart';
import 'package:vibeco_app/domain/repositories/cleaning_repository.dart';

class MockCleaningRepository implements CleaningRepository {
  final _uuid = const Uuid();

  @override
  Future<List<CleaningRecordModel>> getRecordsByStudent(String studentId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockCleaningData.getRecordsByStudent(studentId);
  }

  @override
  Future<List<CleaningRecordModel>> getRecordsByClass(String className) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockCleaningData.getRecordsByClass(className);
  }

  @override
  Future<List<CleaningRecordModel>> getPendingRecords() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockCleaningData.getPendingRecords();
  }

  @override
  Future<List<CleaningRecordModel>> getVerifiedTodayRecords() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockCleaningData.getVerifiedToday();
  }

  @override
  Future<List<CleaningRecordModel>> getTodaysRecords() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockCleaningData.getTodaysRecords();
  }

  @override
  Future<CleaningRecordModel> submitRecord({
    required String studentId,
    required String studentName,
    required String className,
    required double score,
    required List<String> findings,
    required List<String> recommendations,
    String? photoPath,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    final record = CleaningRecordModel(
      id: 'cr_${_uuid.v4()}',
      studentId: studentId,
      studentName: studentName,
      className: className,
      date: DateTime.now(),
      score: score,
      findings: findings,
      recommendations: recommendations,
      photoPath: photoPath,
      status: CleaningStatus.pending,
      createdAt: DateTime.now(),
    );
    MockCleaningData.addRecord(record);
    return record;
  }

  @override
  Future<void> verifyRecord({
    required String recordId,
    required String teacherId,
    required String teacherName,
    required CleaningStatus status,
    double? newScore,
    String? notes,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Find record
    final record = MockCleaningData.allRecords.firstWhere((r) => r.id == recordId);
    
    // Create verification audit log
    final verification = VerificationModel(
      id: 'v_${_uuid.v4()}',
      recordId: recordId,
      teacherId: teacherId,
      teacherName: teacherName,
      action: status == CleaningStatus.verified ? 'approved' : 'rejected',
      newScore: newScore,
      oldScore: record.score,
      notes: notes,
      timestamp: DateTime.now(),
    );
    
    // Update record
    final updatedRecord = record.copyWith(
      status: status,
      score: newScore ?? record.score,
      verifiedBy: teacherId,
      verificationNotes: notes,
    );
    
    MockCleaningData.updateRecord(updatedRecord);
    MockCleaningData.addVerification(verification);
  }

  @override
  Future<List<VerificationModel>> getAuditLogs() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final logs = MockCleaningData.allVerifications.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return logs;
  }
}
