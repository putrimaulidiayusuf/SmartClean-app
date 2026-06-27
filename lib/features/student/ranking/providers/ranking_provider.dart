import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibeco_app/data/models/schedule_models.dart';
import 'package:vibeco_app/features/auth/providers/auth_provider.dart';

enum RankingScope { classScope, schoolScope }

class RankingState {
  final bool isLoading;
  final List<RankingModel> rankings;
  final RankingScope currentScope;

  const RankingState({
    this.isLoading = false,
    this.rankings = const [],
    this.currentScope = RankingScope.classScope,
  });

  RankingState copyWith({
    bool? isLoading,
    List<RankingModel>? rankings,
    RankingScope? currentScope,
  }) {
    return RankingState(
      isLoading: isLoading ?? this.isLoading,
      rankings: rankings ?? this.rankings,
      currentScope: currentScope ?? this.currentScope,
    );
  }
}

class RankingNotifier extends StateNotifier<RankingState> {
  final Ref _ref;

  RankingNotifier(this._ref) : super(const RankingState()) {
    loadRankings();
  }

  Future<void> loadRankings() async {
    state = state.copyWith(isLoading: true);
    final user = _ref.read(authProvider).student;
    if (user == null) {
      state = state.copyWith(isLoading: false);
      return;
    }

    final studentRepo = _ref.read(studentRepositoryProvider);
    List<RankingModel> rankingsList = [];

    if (state.currentScope == RankingScope.classScope) {
      rankingsList = await studentRepo.getClassRanking(user.className);
    } else {
      rankingsList = await studentRepo.getSchoolRanking();
    }

    state = state.copyWith(
      isLoading: false,
      rankings: rankingsList,
    );
  }

  void setScope(RankingScope scope) {
    if (state.currentScope == scope) return;
    state = state.copyWith(currentScope: scope);
    loadRankings();
  }
}

final studentRankingProvider =
    StateNotifierProvider<RankingNotifier, RankingState>((ref) {
  return RankingNotifier(ref);
});
