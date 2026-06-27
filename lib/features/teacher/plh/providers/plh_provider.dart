import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibeco_app/data/models/cleaning_record_model.dart';
import 'package:vibeco_app/data/models/schedule_models.dart';
import 'package:vibeco_app/data/mock/mock_cleaning_data.dart';
import 'package:vibeco_app/features/auth/providers/auth_provider.dart';

class PlhState {
  final bool isLoading;
  final List<CleaningRecordModel> pendingQueue;
  final List<CleaningRecordModel> verifiedToday;
  final double schoolAverageScore;
  final List<RankingModel> schoolRankings;
  final List<VerificationModel> auditLogs;

  const PlhState({
    this.isLoading = false,
    this.pendingQueue = const [],
    this.verifiedToday = const [],
    this.schoolAverageScore = 0.0,
    this.schoolRankings = const [],
    this.auditLogs = const [],
  });

  PlhState copyWith({
    bool? isLoading,
    List<CleaningRecordModel>? pendingQueue,
    List<CleaningRecordModel>? verifiedToday,
    double? schoolAverageScore,
    List<RankingModel>? schoolRankings,
    List<VerificationModel>? auditLogs,
  }) {
    return PlhState(
      isLoading: isLoading ?? this.isLoading,
      pendingQueue: pendingQueue ?? this.pendingQueue,
      verifiedToday: verifiedToday ?? this.verifiedToday,
      schoolAverageScore: schoolAverageScore ?? this.schoolAverageScore,
      schoolRankings: schoolRankings ?? this.schoolRankings,
      auditLogs: auditLogs ?? this.auditLogs,
    );
  }
}

class PlhNotifier extends StateNotifier<PlhState> {
  final Ref _ref;

  PlhNotifier(this._ref) : super(const PlhState()) {
    loadPlhData();
  }

  Future<void> loadPlhData() async {
    state = state.copyWith(isLoading: true);

    final cleaningRepo = _ref.read(cleaningRepositoryProvider);
    final studentRepo = _ref.read(studentRepositoryProvider);

    final pending = await cleaningRepo.getPendingRecords();
    final verifiedTdy = await cleaningRepo.getVerifiedTodayRecords();
    
    // Average school score
    final avg = MockCleaningData.getAverageScore();

    // School rankings
    final rankings = await studentRepo.getSchoolRanking();

    // Audit logs
    final logs = await cleaningRepo.getAuditLogs();

    state = PlhState(
      isLoading: false,
      pendingQueue: pending,
      verifiedToday: verifiedTdy,
      schoolAverageScore: avg,
      schoolRankings: rankings,
      auditLogs: logs,
    );
  }

  Future<bool> verifyAssessment({
    required String recordId,
    required CleaningStatus status,
    double? newScore,
    String? notes,
  }) async {
    final teacher = _ref.read(authProvider).teacher;
    if (teacher == null) return false;

    final cleaningRepo = _ref.read(cleaningRepositoryProvider);

    try {
      await cleaningRepo.verifyRecord(
        recordId: recordId,
        teacherId: teacher.id,
        teacherName: teacher.name,
        status: status,
        newScore: newScore,
        notes: notes,
      );
      // Reload Dashboard data
      await loadPlhData();
      return true;
    } catch (_) {
      return false;
    }
  }
}

final plhProvider =
    StateNotifierProvider<PlhNotifier, PlhState>((ref) {
  return PlhNotifier(ref);
});
