import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibeco_app/data/models/cleaning_record_model.dart';
import 'package:vibeco_app/data/models/schedule_models.dart';
import 'package:vibeco_app/data/models/user_model.dart';
import 'package:vibeco_app/data/mock/mock_database.dart';
import 'package:vibeco_app/features/auth/providers/auth_provider.dart';

class HomeroomState {
  final bool isLoading;
  final String className;
  final double averageScore;
  final double weeklyAverageScore;
  final double monthlyAverageScore;
  final List<CleaningRecordModel> classRecords;
  final List<CleaningRecordModel> todaysRecords;
  final List<StudentModel> onDutyToday;
  final List<StudentModel> missingUploadsToday;
  final List<RankingModel> studentRankings;
  final List<String> galleryPhotos;
  final List<DutyScheduleModel> dutySchedule;
  final List<RankingModel> topPerformers;
  final List<StudentModel> rewardRecommendations;

  const HomeroomState({
    this.isLoading = false,
    this.className = '',
    this.averageScore = 0.0,
    this.weeklyAverageScore = 0.0,
    this.monthlyAverageScore = 0.0,
    this.classRecords = const [],
    this.todaysRecords = const [],
    this.onDutyToday = const [],
    this.missingUploadsToday = const [],
    this.studentRankings = const [],
    this.galleryPhotos = const [],
    this.dutySchedule = const [],
    this.topPerformers = const [],
    this.rewardRecommendations = const [],
  });

  HomeroomState copyWith({
    bool? isLoading,
    String? className,
    double? averageScore,
    double? weeklyAverageScore,
    double? monthlyAverageScore,
    List<CleaningRecordModel>? classRecords,
    List<CleaningRecordModel>? todaysRecords,
    List<StudentModel>? onDutyToday,
    List<StudentModel>? missingUploadsToday,
    List<RankingModel>? studentRankings,
    List<String>? galleryPhotos,
    List<DutyScheduleModel>? dutySchedule,
    List<RankingModel>? topPerformers,
    List<StudentModel>? rewardRecommendations,
  }) {
    return HomeroomState(
      isLoading: isLoading ?? this.isLoading,
      className: className ?? this.className,
      averageScore: averageScore ?? this.averageScore,
      weeklyAverageScore: weeklyAverageScore ?? this.weeklyAverageScore,
      monthlyAverageScore: monthlyAverageScore ?? this.monthlyAverageScore,
      classRecords: classRecords ?? this.classRecords,
      todaysRecords: todaysRecords ?? this.todaysRecords,
      onDutyToday: onDutyToday ?? this.onDutyToday,
      missingUploadsToday: missingUploadsToday ?? this.missingUploadsToday,
      studentRankings: studentRankings ?? this.studentRankings,
      galleryPhotos: galleryPhotos ?? this.galleryPhotos,
      dutySchedule: dutySchedule ?? this.dutySchedule,
      topPerformers: topPerformers ?? this.topPerformers,
      rewardRecommendations: rewardRecommendations ?? this.rewardRecommendations,
    );
  }
}

class HomeroomNotifier extends StateNotifier<HomeroomState> {
  final Ref _ref;

  HomeroomNotifier(this._ref) : super(const HomeroomState()) {
    loadHomeroomData();
  }

  Future<void> loadHomeroomData() async {
    state = state.copyWith(isLoading: true);
    
    final teacher = _ref.read(authProvider).teacher;
    if (teacher == null || !teacher.isHomeroom || teacher.className == null) {
      state = state.copyWith(isLoading: false);
      return;
    }

    final targetClass = teacher.className!;
    final cleaningRepo = _ref.read(cleaningRepositoryProvider);
    final studentRepo = _ref.read(studentRepositoryProvider);

    // Get all records of this class
    final records = await cleaningRepo.getRecordsByClass(targetClass);

    // Filter today's records
    final now = DateTime.now();
    final todays = records.where((r) =>
        r.date.year == now.year &&
        r.date.month == now.month &&
        r.date.day == now.day).toList();

    // Get today's duty roster
    final dutyRoster = await studentRepo.getTodaysDuty(targetClass);
    final List<StudentModel> onDuty = [];
    final List<StudentModel> missingUploads = [];

    if (dutyRoster != null) {
      for (final studentId in dutyRoster.studentIds) {
        final student = await studentRepo.getStudentById(studentId);
        if (student != null) {
          onDuty.add(student);
          // Check if they uploaded today
          final uploaded = todays.any((r) => r.studentId == studentId);
          if (!uploaded) {
            missingUploads.add(student);
          }
        }
      }
    }

    // Class rankings
    final rankings = await studentRepo.getClassRanking(targetClass);

    // Gallery Photos (any records with a valid photoPath)
    final photos = records
        .where((r) => r.photoPath != null && r.photoPath!.isNotEmpty)
        .map((r) => r.photoPath!)
        .toList();

    // Duty schedule (entire week)
    final schedule = await studentRepo.getDutySchedule(targetClass);

    // Top performers (students with avg score >= 90)
    final top = rankings.where((r) => r.averageScore >= 90.0).toList();

    // Reward recommendations
    final List<StudentModel> rewards = [];
    for (final performer in top) {
      final student = await studentRepo.getStudentById(performer.studentId);
      if (student != null) {
        rewards.add(student);
      }
    }

    // Averages calculation
    final totalAvg = records.isEmpty
        ? 0.0
        : records.map((r) => r.score).reduce((a, b) => a + b) / records.length;

    final weekAgo = now.subtract(const Duration(days: 7));
    final weeklyRecords = records.where((r) => r.date.isAfter(weekAgo)).toList();
    final weeklyAvg = weeklyRecords.isEmpty
        ? 0.0
        : weeklyRecords.map((r) => r.score).reduce((a, b) => a + b) /
            weeklyRecords.length;

    final monthAgo = now.subtract(const Duration(days: 30));
    final monthlyRecords = records.where((r) => r.date.isAfter(monthAgo)).toList();
    final monthlyAvg = monthlyRecords.isEmpty
        ? 0.0
        : monthlyRecords.map((r) => r.score).reduce((a, b) => a + b) /
            monthlyRecords.length;

    state = HomeroomState(
      isLoading: false,
      className: targetClass,
      averageScore: totalAvg,
      weeklyAverageScore: weeklyAvg,
      monthlyAverageScore: monthlyAvg,
      classRecords: records,
      todaysRecords: todays,
      onDutyToday: onDuty,
      missingUploadsToday: missingUploads,
      studentRankings: rankings,
      galleryPhotos: photos,
      dutySchedule: schedule,
      topPerformers: top,
      rewardRecommendations: rewards,
    );
  }
}

final homeroomProvider =
    StateNotifierProvider<HomeroomNotifier, HomeroomState>((ref) {
  return HomeroomNotifier(ref);
});
