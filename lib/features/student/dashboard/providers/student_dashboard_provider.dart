import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibeco_app/data/models/cleaning_record_model.dart';
import 'package:vibeco_app/data/models/schedule_models.dart';
import 'package:vibeco_app/features/auth/providers/auth_provider.dart';
import 'package:vibeco_app/features/auth/providers/auth_provider.dart' show authProvider;

class StudentDashboardState {
  final bool isLoading;
  final DutyScheduleModel? todaysDuty;
  final bool isOnDutyToday;
  final CleaningRecordModel? todaysSubmission;
  final List<CleaningRecordModel> recentHistory;
  final RankingModel? rankingPreview;
  final String motivationalQuote;

  const StudentDashboardState({
    this.isLoading = false,
    this.todaysDuty,
    this.isOnDutyToday = false,
    this.todaysSubmission,
    this.recentHistory = const [],
    this.rankingPreview,
    this.motivationalQuote = '',
  });

  StudentDashboardState copyWith({
    bool? isLoading,
    DutyScheduleModel? todaysDuty,
    bool? isOnDutyToday,
    CleaningRecordModel? todaysSubmission,
    List<CleaningRecordModel>? recentHistory,
    RankingModel? rankingPreview,
    String? motivationalQuote,
  }) {
    return StudentDashboardState(
      isLoading: isLoading ?? this.isLoading,
      todaysDuty: todaysDuty ?? this.todaysDuty,
      isOnDutyToday: isOnDutyToday ?? this.isOnDutyToday,
      todaysSubmission: todaysSubmission ?? this.todaysSubmission,
      recentHistory: recentHistory ?? this.recentHistory,
      rankingPreview: rankingPreview ?? this.rankingPreview,
      motivationalQuote: motivationalQuote ?? this.motivationalQuote,
    );
  }
}

class StudentDashboardNotifier extends StateNotifier<StudentDashboardState> {
  final Ref _ref;

  StudentDashboardNotifier(this._ref) : super(const StudentDashboardState()) {
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    state = state.copyWith(isLoading: true);
    final user = _ref.read(authProvider).student;
    if (user == null) {
      state = state.copyWith(isLoading: false);
      return;
    }

    final cleaningRepo = _ref.read(cleaningRepositoryProvider);
    final studentRepo = _ref.read(studentRepositoryProvider);

    // Load todays duty
    final duty = await studentRepo.getTodaysDuty(user.className);
    final isOnDuty = duty?.studentIds.contains(user.id) ?? false;

    // Load recent history
    final history = await cleaningRepo.getRecordsByStudent(user.id);
    
    // Load todays records to see if user has submitted
    final todaysRecords = await cleaningRepo.getTodaysRecords();
    CleaningRecordModel? todaySub;
    try {
      todaySub = todaysRecords.firstWhere((r) => r.studentId == user.id);
    } catch (_) {}

    // Load class ranking & preview
    final rankings = await studentRepo.getClassRanking(user.className);
    RankingModel? rankPrev;
    try {
      rankPrev = rankings.firstWhere((r) => r.studentId == user.id);
    } catch (_) {}

    // Pick random motivational card
    final quotes = [
      'A clean space is a productive space! 🌟',
      'Small actions lead to big changes! 💪',
      'Cleanliness is next to excellence! ✨',
      'Every clean corner counts! 🏆',
      'Together we make our school shine! 🌈',
      'Your effort makes a difference! 🎯',
      'Clean today, succeed tomorrow! 🚀',
      'Be the change you want to see! 🌱',
    ];
    final quote = quotes[DateTime.now().millisecond % quotes.length];

    state = StudentDashboardState(
      isLoading: false,
      todaysDuty: duty,
      isOnDutyToday: isOnDuty,
      todaysSubmission: todaySub,
      recentHistory: history.take(3).toList(),
      rankingPreview: rankPrev,
      motivationalQuote: quote,
    );
  }
}

final studentDashboardProvider =
    StateNotifierProvider<StudentDashboardNotifier, StudentDashboardState>((ref) {
  return StudentDashboardNotifier(ref);
});
