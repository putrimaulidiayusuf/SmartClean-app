enum CleaningStatus { pending, verified, rejected }

class CleaningRecordModel {
  final String id;
  final String studentId;
  final String studentName;
  final String className;
  final DateTime date;
  final double score;
  final List<String> findings;
  final List<String> recommendations;
  final String? photoPath;
  final CleaningStatus status;
  final String? verifiedBy;
  final String? verificationNotes;
  final DateTime createdAt;

  const CleaningRecordModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.className,
    required this.date,
    required this.score,
    required this.findings,
    required this.recommendations,
    this.photoPath,
    this.status = CleaningStatus.pending,
    this.verifiedBy,
    this.verificationNotes,
    required this.createdAt,
  });

  CleaningRecordModel copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? className,
    DateTime? date,
    double? score,
    List<String>? findings,
    List<String>? recommendations,
    String? photoPath,
    CleaningStatus? status,
    String? verifiedBy,
    String? verificationNotes,
    DateTime? createdAt,
  }) {
    return CleaningRecordModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      className: className ?? this.className,
      date: date ?? this.date,
      score: score ?? this.score,
      findings: findings ?? this.findings,
      recommendations: recommendations ?? this.recommendations,
      photoPath: photoPath ?? this.photoPath,
      status: status ?? this.status,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      verificationNotes: verificationNotes ?? this.verificationNotes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'studentId': studentId,
        'studentName': studentName,
        'className': className,
        'date': date.toIso8601String(),
        'score': score,
        'findings': findings,
        'recommendations': recommendations,
        'photoPath': photoPath,
        'status': status.name,
        'verifiedBy': verifiedBy,
        'verificationNotes': verificationNotes,
        'createdAt': createdAt.toIso8601String(),
      };

  factory CleaningRecordModel.fromJson(Map<String, dynamic> json) =>
      CleaningRecordModel(
        id: json['id'] as String,
        studentId: json['studentId'] as String,
        studentName: json['studentName'] as String,
        className: json['className'] as String,
        date: DateTime.parse(json['date'] as String),
        score: (json['score'] as num).toDouble(),
        findings: List<String>.from(json['findings'] as List),
        recommendations: List<String>.from(json['recommendations'] as List),
        photoPath: json['photoPath'] as String?,
        status: CleaningStatus.values
            .firstWhere((e) => e.name == json['status']),
        verifiedBy: json['verifiedBy'] as String?,
        verificationNotes: json['verificationNotes'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
