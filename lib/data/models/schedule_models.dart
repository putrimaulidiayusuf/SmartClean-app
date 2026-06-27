class DutyScheduleModel {
  final String dayName;
  final int dayIndex; // 0=Monday, 1=Tuesday, ..., 4=Friday
  final String className;
  final List<String> studentIds;
  final List<String> studentNames;

  const DutyScheduleModel({
    required this.dayName,
    required this.dayIndex,
    required this.className,
    required this.studentIds,
    required this.studentNames,
  });

  Map<String, dynamic> toJson() => {
        'dayName': dayName,
        'dayIndex': dayIndex,
        'className': className,
        'studentIds': studentIds,
        'studentNames': studentNames,
      };

  factory DutyScheduleModel.fromJson(Map<String, dynamic> json) =>
      DutyScheduleModel(
        dayName: json['dayName'] as String,
        dayIndex: json['dayIndex'] as int,
        className: json['className'] as String,
        studentIds: List<String>.from(json['studentIds'] as List),
        studentNames: List<String>.from(json['studentNames'] as List),
      );
}

class ClassModel {
  final String id;
  final String name;
  final List<String> studentIds;

  const ClassModel({
    required this.id,
    required this.name,
    required this.studentIds,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'studentIds': studentIds,
      };

  factory ClassModel.fromJson(Map<String, dynamic> json) => ClassModel(
        id: json['id'] as String,
        name: json['name'] as String,
        studentIds: List<String>.from(json['studentIds'] as List),
      );
}

class VerificationModel {
  final String id;
  final String recordId;
  final String teacherId;
  final String teacherName;
  final String action; // 'approved', 'rejected', 'score_changed'
  final double? newScore;
  final double? oldScore;
  final String? notes;
  final DateTime timestamp;

  const VerificationModel({
    required this.id,
    required this.recordId,
    required this.teacherId,
    required this.teacherName,
    required this.action,
    this.newScore,
    this.oldScore,
    this.notes,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'recordId': recordId,
        'teacherId': teacherId,
        'teacherName': teacherName,
        'action': action,
        'newScore': newScore,
        'oldScore': oldScore,
        'notes': notes,
        'timestamp': timestamp.toIso8601String(),
      };

  factory VerificationModel.fromJson(Map<String, dynamic> json) =>
      VerificationModel(
        id: json['id'] as String,
        recordId: json['recordId'] as String,
        teacherId: json['teacherId'] as String,
        teacherName: json['teacherName'] as String,
        action: json['action'] as String,
        newScore: (json['newScore'] as num?)?.toDouble(),
        oldScore: (json['oldScore'] as num?)?.toDouble(),
        notes: json['notes'] as String?,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}

class RankingModel {
  final String studentId;
  final String studentName;
  final String className;
  final double averageScore;
  final int rank;
  final int totalSubmissions;
  final String trend; // 'up', 'down', 'stable'

  const RankingModel({
    required this.studentId,
    required this.studentName,
    required this.className,
    required this.averageScore,
    required this.rank,
    required this.totalSubmissions,
    this.trend = 'stable',
  });
}
