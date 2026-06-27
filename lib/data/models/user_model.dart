enum UserRole { student, homeroomTeacher, plhTeacher }

class StudentModel {
  final String id;
  final String nis;
  final String name;
  final String className;
  final String? profileImage;

  const StudentModel({
    required this.id,
    required this.nis,
    required this.name,
    required this.className,
    this.profileImage,
  });

  StudentModel copyWith({
    String? id,
    String? nis,
    String? name,
    String? className,
    String? profileImage,
  }) {
    return StudentModel(
      id: id ?? this.id,
      nis: nis ?? this.nis,
      name: name ?? this.name,
      className: className ?? this.className,
      profileImage: profileImage ?? this.profileImage,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nis': nis,
        'name': name,
        'className': className,
        'profileImage': profileImage,
      };

  factory StudentModel.fromJson(Map<String, dynamic> json) => StudentModel(
        id: json['id'] as String,
        nis: json['nis'] as String,
        name: json['name'] as String,
        className: json['className'] as String,
        profileImage: json['profileImage'] as String?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class TeacherModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? className;
  final String? profileImage;

  const TeacherModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.className,
    this.profileImage,
  });

  TeacherModel copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? className,
    String? profileImage,
  }) {
    return TeacherModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      className: className ?? this.className,
      profileImage: profileImage ?? this.profileImage,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role.name,
        'className': className,
        'profileImage': profileImage,
      };

  factory TeacherModel.fromJson(Map<String, dynamic> json) => TeacherModel(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        role: UserRole.values.firstWhere((e) => e.name == json['role']),
        className: json['className'] as String?,
        profileImage: json['profileImage'] as String?,
      );

  bool get isHomeroom => role == UserRole.homeroomTeacher;
  bool get isPlh => role == UserRole.plhTeacher;
}
