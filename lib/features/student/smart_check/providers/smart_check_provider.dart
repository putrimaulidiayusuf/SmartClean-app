import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vibeco_app/data/mock/mock_database.dart';
import 'package:vibeco_app/data/models/cleaning_record_model.dart';
import 'package:vibeco_app/features/auth/providers/auth_provider.dart';
import 'package:vibeco_app/features/student/dashboard/providers/student_dashboard_provider.dart';

class SmartCheckState {
  final bool isProcessing;
  final String? photoPath;
  final CleaningRecordModel? resultRecord;
  final String? errorMessage;

  const SmartCheckState({
    this.isProcessing = false,
    this.photoPath,
    this.resultRecord,
    this.errorMessage,
  });

  SmartCheckState copyWith({
    bool? isProcessing,
    String? photoPath,
    CleaningRecordModel? resultRecord,
    String? errorMessage,
    bool clearPhoto = false,
  }) {
    return SmartCheckState(
      isProcessing: isProcessing ?? this.isProcessing,
      photoPath: clearPhoto ? null : (photoPath ?? this.photoPath),
      resultRecord: resultRecord ?? this.resultRecord,
      errorMessage: errorMessage,
    );
  }
}

class SmartCheckNotifier extends StateNotifier<SmartCheckState> {
  final Ref _ref;
  final _picker = ImagePicker();

  SmartCheckNotifier(this._ref) : super(const SmartCheckState());

  Future<void> pickImage(ImageSource source) async {
    state = state.copyWith(errorMessage: null);
    try {
      final image = await _picker.pickImage(source: source, imageQuality: 80);
      if (image != null) {
        state = state.copyWith(photoPath: image.path);
      }
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to pick image: $e');
    }
  }

  Future<bool> processWithAi() async {
    if (state.photoPath == null) {
      state = state.copyWith(errorMessage: 'Please select a photo first');
      return false;
    }

    state = state.copyWith(isProcessing: true, errorMessage: null);

    // AI simulation delay
    await Future.delayed(const Duration(seconds: 3));

    final student = _ref.read(authProvider).student;
    if (student == null) {
      state = state.copyWith(isProcessing: false, errorMessage: 'User session invalid');
      return false;
    }

    final cleaningRepo = _ref.read(cleaningRepositoryProvider);

    // Mock AI Calculation
    final random = Random();
    final score = 70.0 + random.nextInt(28).toDouble(); // 70 to 98
    
    // Choose findings
    final findingsCount = 2 + random.nextInt(3); // 2-4 findings
    final shuffledFindings = List<String>.from(MockDatabase.findingsPool)..shuffle(random);
    final findings = shuffledFindings.take(findingsCount).toList();

    // Choose recommendations
    final recsCount = 1 + random.nextInt(3); // 1-3 recommendations
    final shuffledRecs = List<String>.from(MockDatabase.recommendationsPool)..shuffle(random);
    final recommendations = shuffledRecs.take(recsCount).toList();

    try {
      final record = await cleaningRepo.submitRecord(
        studentId: student.id,
        studentName: student.name,
        className: student.className,
        score: score,
        findings: findings,
        recommendations: recommendations,
        photoPath: state.photoPath,
      );

      state = state.copyWith(
        isProcessing: false,
        resultRecord: record,
      );

      // Refresh Dashboard data
      _ref.read(studentDashboardProvider.notifier).loadDashboardData();
      return true;
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: 'AI Assessment failed to submit: $e',
      );
      return false;
    }
  }

  void reset() {
    state = const SmartCheckState();
  }
}

final smartCheckProvider =
    StateNotifierProvider<SmartCheckNotifier, SmartCheckState>((ref) {
  return SmartCheckNotifier(ref);
});
