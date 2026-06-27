import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibeco_app/data/models/cleaning_record_model.dart';
import 'package:vibeco_app/features/auth/providers/auth_provider.dart';

enum HistoryFilter { all, verified, pending, rejected }

class HistoryState {
  final bool isLoading;
  final List<CleaningRecordModel> allRecords;
  final List<CleaningRecordModel> filteredRecords;
  final HistoryFilter currentFilter;

  const HistoryState({
    this.isLoading = false,
    this.allRecords = const [],
    this.filteredRecords = const [],
    this.currentFilter = HistoryFilter.all,
  });

  HistoryState copyWith({
    bool? isLoading,
    List<CleaningRecordModel>? allRecords,
    List<CleaningRecordModel>? filteredRecords,
    HistoryFilter? currentFilter,
  }) {
    return HistoryState(
      isLoading: isLoading ?? this.isLoading,
      allRecords: allRecords ?? this.allRecords,
      filteredRecords: filteredRecords ?? this.filteredRecords,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }
}

class HistoryNotifier extends StateNotifier<HistoryState> {
  final Ref _ref;

  HistoryNotifier(this._ref) : super(const HistoryState()) {
    loadHistory();
  }

  Future<void> loadHistory() async {
    state = state.copyWith(isLoading: true);
    final user = _ref.read(authProvider).student;
    if (user == null) {
      state = state.copyWith(isLoading: false);
      return;
    }

    final cleaningRepo = _ref.read(cleaningRepositoryProvider);
    final records = await cleaningRepo.getRecordsByStudent(user.id);
    
    state = state.copyWith(
      isLoading: false,
      allRecords: records,
    );
    _applyFilter(state.currentFilter);
  }

  void setFilter(HistoryFilter filter) {
    state = state.copyWith(currentFilter: filter);
    _applyFilter(filter);
  }

  void _applyFilter(HistoryFilter filter) {
    if (filter == HistoryFilter.all) {
      state = state.copyWith(filteredRecords: state.allRecords);
      return;
    }

    final matchedStatus = filter == HistoryFilter.verified
        ? CleaningStatus.verified
        : filter == HistoryFilter.pending
            ? CleaningStatus.pending
            : CleaningStatus.rejected;

    final filtered = state.allRecords
        .where((r) => r.status == matchedStatus)
        .toList();

    state = state.copyWith(filteredRecords: filtered);
  }
}

final studentHistoryProvider =
    StateNotifierProvider<HistoryNotifier, HistoryState>((ref) {
  return HistoryNotifier(ref);
});
