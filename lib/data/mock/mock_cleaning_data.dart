import 'dart:math';
import 'package:vibeco_app/data/models/cleaning_record_model.dart';
import 'package:vibeco_app/data/models/schedule_models.dart';
import 'package:vibeco_app/data/mock/mock_database.dart';

class MockCleaningData {
  MockCleaningData._();

  static final Random _random = Random(42); // Seeded for consistency
  static List<CleaningRecordModel>? _cachedRecords;
  static List<VerificationModel>? _cachedVerifications;

  static List<CleaningRecordModel> get records {
    _cachedRecords ??= _generateRecords();
    return _cachedRecords!;
  }

  static List<VerificationModel> get verifications {
    _cachedVerifications ??= _generateVerifications();
    return _cachedVerifications!;
  }

  // Mutable list for adding new records at runtime
  static final List<CleaningRecordModel> _runtimeRecords = [];
  static final List<VerificationModel> _runtimeVerifications = [];

  static List<CleaningRecordModel> get allRecords =>
      [...records, ..._runtimeRecords];

  static List<VerificationModel> get allVerifications =>
      [...verifications, ..._runtimeVerifications];

  static void addRecord(CleaningRecordModel record) {
    _runtimeRecords.add(record);
  }

  static void addVerification(VerificationModel verification) {
    _runtimeVerifications.add(verification);
  }

  static void updateRecord(CleaningRecordModel updated) {
    // Check runtime records first
    final rIdx = _runtimeRecords.indexWhere((r) => r.id == updated.id);
    if (rIdx != -1) {
      _runtimeRecords[rIdx] = updated;
      return;
    }
    // Check cached records
    final cIdx = _cachedRecords?.indexWhere((r) => r.id == updated.id) ?? -1;
    if (cIdx != -1) {
      _cachedRecords![cIdx] = updated;
    }
  }

  static List<CleaningRecordModel> _generateRecords() {
    final records = <CleaningRecordModel>[];
    final now = DateTime.now();

    // Generate records for the past 30 days
    for (int daysAgo = 1; daysAgo <= 30; daysAgo++) {
      final date = now.subtract(Duration(days: daysAgo));
      // Skip weekends
      if (date.weekday > 5) continue;

      // Get duty students for this day
      final dayIndex = date.weekday - 1; // 0=Mon, 4=Fri

      for (final className in [MockDatabase.class1Name, MockDatabase.class2Name]) {
        final students = MockDatabase.getStudentsByClass(className);
        final startIdx = dayIndex * 3;
        final endIdx = (startIdx + 3).clamp(0, students.length);
        final dutyStudents = students.sublist(startIdx, endIdx);

        for (final student in dutyStudents) {
          // 85% chance of submitting
          if (_random.nextDouble() > 0.85) continue;

          final score = 65.0 + _random.nextInt(34).toDouble();
          final findingsCount = 2 + _random.nextInt(3);
          final findings = _pickRandom(
            MockDatabase.findingsPool,
            findingsCount,
          );
          final recsCount = 1 + _random.nextInt(3);
          final recommendations = _pickRandom(
            MockDatabase.recommendationsPool,
            recsCount,
          );

          // Determine verification status
          CleaningStatus status;
          String? verifiedBy;
          if (daysAgo > 3) {
            status = _random.nextDouble() > 0.2
                ? CleaningStatus.verified
                : CleaningStatus.rejected;
            verifiedBy = 't003'; // PLH teacher
          } else if (daysAgo > 1) {
            status = _random.nextDouble() > 0.5
                ? CleaningStatus.verified
                : CleaningStatus.pending;
            if (status == CleaningStatus.verified) verifiedBy = 't003';
          } else {
            status = CleaningStatus.pending;
          }

          records.add(CleaningRecordModel(
            id: 'cr_${className.hashCode}_${daysAgo}_${student.id}',
            studentId: student.id,
            studentName: student.name,
            className: className,
            date: date,
            score: score,
            findings: findings,
            recommendations: recommendations,
            status: status,
            verifiedBy: verifiedBy,
            createdAt: date.add(Duration(
              hours: 7 + _random.nextInt(3),
              minutes: _random.nextInt(60),
            )),
          ));
        }
      }
    }

    return records;
  }

  static List<VerificationModel> _generateVerifications() {
    final verifications = <VerificationModel>[];
    final verifiedRecords = records.where(
      (r) => r.status != CleaningStatus.pending,
    );

    for (final record in verifiedRecords) {
      verifications.add(VerificationModel(
        id: 'v_${record.id}',
        recordId: record.id,
        teacherId: 't003',
        teacherName: 'Pak Yaqub',
        action: record.status == CleaningStatus.verified ? 'approved' : 'rejected',
        notes: record.status == CleaningStatus.rejected
            ? 'Photo quality insufficient, please retake.'
            : 'Assessment looks accurate. Good job!',
        timestamp: record.createdAt.add(const Duration(hours: 2)),
      ));
    }

    return verifications;
  }

  static List<String> _pickRandom(List<String> pool, int count) {
    final shuffled = List<String>.from(pool)..shuffle(_random);
    return shuffled.take(count).toList();
  }

  // ─── Query helpers ──────────────────────────────────
  static List<CleaningRecordModel> getRecordsByStudent(String studentId) {
    return allRecords.where((r) => r.studentId == studentId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  static List<CleaningRecordModel> getRecordsByClass(String className) {
    return allRecords.where((r) => r.className == className).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  static List<CleaningRecordModel> getTodaysRecords() {
    final now = DateTime.now();
    return allRecords.where((r) =>
        r.date.year == now.year &&
        r.date.month == now.month &&
        r.date.day == now.day).toList();
  }

  static List<CleaningRecordModel> getPendingRecords() {
    return allRecords.where((r) => r.status == CleaningStatus.pending).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static List<CleaningRecordModel> getVerifiedToday() {
    final now = DateTime.now();
    return allRecords.where((r) =>
        r.status == CleaningStatus.verified &&
        r.date.year == now.year &&
        r.date.month == now.month &&
        r.date.day == now.day).toList();
  }

  static double getAverageScore({String? className, String? studentId}) {
    var filtered = allRecords.toList();
    if (className != null) {
      filtered = filtered.where((r) => r.className == className).toList();
    }
    if (studentId != null) {
      filtered = filtered.where((r) => r.studentId == studentId).toList();
    }
    if (filtered.isEmpty) return 0;
    return filtered.map((r) => r.score).reduce((a, b) => a + b) / filtered.length;
  }

  static double getAverageScoreForPeriod({
    String? className,
    required DateTime start,
    required DateTime end,
  }) {
    var filtered = allRecords.where(
      (r) => r.date.isAfter(start) && r.date.isBefore(end),
    ).toList();
    if (className != null) {
      filtered = filtered.where((r) => r.className == className).toList();
    }
    if (filtered.isEmpty) return 0;
    return filtered.map((r) => r.score).reduce((a, b) => a + b) / filtered.length;
  }

  static List<RankingModel> getClassRanking(String className) {
    final students = MockDatabase.getStudentsByClass(className);
    final rankings = <RankingModel>[];

    for (final student in students) {
      final studentRecords = getRecordsByStudent(student.id);
      if (studentRecords.isEmpty) {
        rankings.add(RankingModel(
          studentId: student.id,
          studentName: student.name,
          className: className,
          averageScore: 0,
          rank: 0,
          totalSubmissions: 0,
          trend: 'stable',
        ));
        continue;
      }

      final avg = studentRecords.map((r) => r.score).reduce((a, b) => a + b) /
          studentRecords.length;

      // Calculate trend (last 7 days vs previous 7 days)
      final now = DateTime.now();
      final recentRecords = studentRecords.where(
        (r) => r.date.isAfter(now.subtract(const Duration(days: 7))),
      );
      final olderRecords = studentRecords.where(
        (r) => r.date.isAfter(now.subtract(const Duration(days: 14))) &&
            r.date.isBefore(now.subtract(const Duration(days: 7))),
      );

      String trend = 'stable';
      if (recentRecords.isNotEmpty && olderRecords.isNotEmpty) {
        final recentAvg = recentRecords.map((r) => r.score).reduce((a, b) => a + b) /
            recentRecords.length;
        final olderAvg = olderRecords.map((r) => r.score).reduce((a, b) => a + b) /
            olderRecords.length;
        if (recentAvg > olderAvg + 2) trend = 'up';
        if (recentAvg < olderAvg - 2) trend = 'down';
      }

      rankings.add(RankingModel(
        studentId: student.id,
        studentName: student.name,
        className: className,
        averageScore: avg,
        rank: 0,
        totalSubmissions: studentRecords.length,
        trend: trend,
      ));
    }

    // Sort and assign ranks
    rankings.sort((a, b) => b.averageScore.compareTo(a.averageScore));
    final ranked = <RankingModel>[];
    for (int i = 0; i < rankings.length; i++) {
      ranked.add(RankingModel(
        studentId: rankings[i].studentId,
        studentName: rankings[i].studentName,
        className: rankings[i].className,
        averageScore: rankings[i].averageScore,
        rank: i + 1,
        totalSubmissions: rankings[i].totalSubmissions,
        trend: rankings[i].trend,
      ));
    }
    return ranked;
  }

  static List<RankingModel> getSchoolRanking() {
    final allRankings = [
      ...getClassRanking(MockDatabase.class1Name),
      ...getClassRanking(MockDatabase.class2Name),
    ];
    allRankings.sort((a, b) => b.averageScore.compareTo(a.averageScore));
    final ranked = <RankingModel>[];
    for (int i = 0; i < allRankings.length; i++) {
      ranked.add(RankingModel(
        studentId: allRankings[i].studentId,
        studentName: allRankings[i].studentName,
        className: allRankings[i].className,
        averageScore: allRankings[i].averageScore,
        rank: i + 1,
        totalSubmissions: allRankings[i].totalSubmissions,
        trend: allRankings[i].trend,
      ));
    }
    return ranked;
  }
}
