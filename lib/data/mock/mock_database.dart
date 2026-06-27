import 'package:vibeco_app/data/models/user_model.dart';
import 'package:vibeco_app/data/models/schedule_models.dart';

class MockDatabase {
  MockDatabase._();

  // ─── Classes ────────────────────────────────────────
  static const String class1Name = 'XI PPLG RPL 1';
  static const String class2Name = 'XI PPLG RPL 2';

  static const ClassModel class1 = ClassModel(
    id: 'class_1',
    name: class1Name,
    studentIds: [
      's001', 's002', 's003', 's004', 's005', 's006', 's007', 's008',
      's009', 's010', 's011', 's012', 's013', 's014', 's015',
    ],
  );

  static const ClassModel class2 = ClassModel(
    id: 'class_2',
    name: class2Name,
    studentIds: [
      's016', 's017', 's018', 's019', 's020', 's021', 's022', 's023',
      's024', 's025', 's026', 's027', 's028', 's029', 's030',
    ],
  );

  static const List<ClassModel> classes = [class1, class2];

  // ─── Students XI PPLG RPL 1 ─────────────────────────
  static const List<StudentModel> studentsClass1 = [
    StudentModel(id: 's001', nis: '242510037', name: 'ADIFTYA RAHMAD', className: class1Name),
    StudentModel(id: 's002', nis: '242510038', name: 'ALYANDRA ADHYTIA SOPYAN', className: class1Name),
    StudentModel(id: 's003', nis: '242510039', name: 'ANDHIKA NOOR HIDAYAT', className: class1Name),
    StudentModel(id: 's004', nis: '242510040', name: 'BAMA MAULANA WIBISANA', className: class1Name),
    StudentModel(id: 's005', nis: '242510041', name: 'DIKA PRAYOGA GUNAWAN', className: class1Name),
    StudentModel(id: 's006', nis: '242510042', name: 'DIMITAR BAYANAKA MUGIZA', className: class1Name),
    StudentModel(id: 's007', nis: '242510043', name: 'DZAKY FADHILAH RAHMAWAN', className: class1Name),
    StudentModel(id: 's008', nis: '242510044', name: 'FARIZ DZULHAMI', className: class1Name),
    StudentModel(id: 's009', nis: '242510045', name: 'IBNU HAMBAL AL BANTANI RCH', className: class1Name),
    StudentModel(id: 's010', nis: '242510046', name: 'ILISHA NEOLA PINO', className: class1Name),
    StudentModel(id: 's011', nis: '242510047', name: 'JIBRIL IBNI JUBAIR', className: class1Name),
    StudentModel(id: 's012', nis: '242510048', name: 'JIHAN FAUZIAH', className: class1Name),
    StudentModel(id: 's013', nis: '242510049', name: 'KIANO DEVARO RIDHO', className: class1Name),
    StudentModel(id: 's014', nis: '242510050', name: 'M ARKAN RAIHAN NUGRAHA', className: class1Name),
    StudentModel(id: 's015', nis: '242510051', name: 'M RAFI NADHIR ABDURRAHMAN', className: class1Name),
  ];

  // ─── Students XI PPLG RPL 2 ─────────────────────────
  static const List<StudentModel> studentsClass2 = [
    StudentModel(id: 's016', nis: '242510055', name: 'MUHAMAD FARREL RADITHYA', className: class2Name),
    StudentModel(id: 's017', nis: '242510056', name: 'MUHAMMAD ARSA PRAYATA', className: class2Name),
    StudentModel(id: 's018', nis: '242510057', name: 'MUHAMMAD ASYRAF RIZQULLAH', className: class2Name),
    StudentModel(id: 's019', nis: '242510058', name: 'MUHAMMAD DERYL FABIENSYAH', className: class2Name),
    StudentModel(id: 's020', nis: '242510059', name: 'MUHAMMAD FAGIAN DARMAWAN', className: class2Name),
    StudentModel(id: 's021', nis: '242510060', name: 'MUHAMMAD HAIDAR ALMER RAFIF', className: class2Name),
    StudentModel(id: 's022', nis: '242510061', name: 'MUHAMMAD ROFI\'I ALAWI', className: class2Name),
    StudentModel(id: 's023', nis: '242510062', name: 'NAZWATUS SHIFA', className: class2Name),
    StudentModel(id: 's024', nis: '242510063', name: 'NESYA KIRANI NURROFFI', className: class2Name),
    StudentModel(id: 's025', nis: '242510064', name: 'PANCA SATIA NUGRAHA', className: class2Name),
    StudentModel(id: 's026', nis: '242510065', name: 'PUTRI MAULIDIA YUSUF', className: class2Name),
    StudentModel(id: 's027', nis: '242510066', name: 'RAFA KHADAFI', className: class2Name),
    StudentModel(id: 's028', nis: '242510067', name: 'RAHMA SANTIKA AL ANSHORI', className: class2Name),
    StudentModel(id: 's029', nis: '242510068', name: 'RASHQA ANDEAN FITRAH SULAEMAN', className: class2Name),
    StudentModel(id: 's030', nis: '242510069', name: 'RESNA RAHMAWATI', className: class2Name),
  ];

  static List<StudentModel> get allStudents => [...studentsClass1, ...studentsClass2];

  // ─── Teachers ────────────────────────────────────────
  static const List<TeacherModel> teachers = [
    TeacherModel(
      id: 't001',
      name: 'Pak Fajar',
      email: 'fajar@gmail.com',
      role: UserRole.homeroomTeacher,
      className: class1Name,
    ),
    TeacherModel(
      id: 't002',
      name: 'Bu Sarah',
      email: 'sarah@gmail.com',
      role: UserRole.homeroomTeacher,
      className: class2Name,
    ),
    TeacherModel(
      id: 't003',
      name: 'Pak Yaqub',
      email: 'yaqub@gmail.com',
      role: UserRole.plhTeacher,
    ),
  ];

  // ─── Duty Schedule ──────────────────────────────────
  static List<DutyScheduleModel> getDutySchedule(String className) {
    final students = className == class1Name ? studentsClass1 : studentsClass2;
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];

    return List.generate(5, (dayIndex) {
      final startIdx = dayIndex * 3;
      final endIdx = (startIdx + 3).clamp(0, students.length);
      final dutyStudents = students.sublist(startIdx, endIdx);

      return DutyScheduleModel(
        dayName: days[dayIndex],
        dayIndex: dayIndex,
        className: className,
        studentIds: dutyStudents.map((s) => s.id).toList(),
        studentNames: dutyStudents.map((s) => s.name).toList(),
      );
    });
  }

  // ─── Get today's duty students ──────────────────────
  static DutyScheduleModel? getTodaysDuty(String className) {
    final now = DateTime.now();
    final weekday = now.weekday; // 1=Monday, ..., 5=Friday
    if (weekday > 5) return null; // Weekend

    final schedule = getDutySchedule(className);
    return schedule[weekday - 1];
  }

  // ─── AI Findings Pool ───────────────────────────────
  static const List<String> findingsPool = [
    'Floor is clean and free of debris',
    'Whiteboard needs wiping — residue marks visible',
    'Chairs are neatly arranged',
    'Trash bin is overflowing',
    'Windows are clean and clear',
    'Dust detected on desk surfaces',
    'Air conditioning vents need cleaning',
    'Books and materials organized properly',
    'Cobwebs found in corner areas',
    'Floor has been mopped recently',
    'Marker stains on whiteboard tray',
    'Classroom door handle needs sanitizing',
    'Light fixtures are dust-free',
    'Student lockers are tidy',
    'Trash properly sorted and disposed',
    'Plants are well-maintained',
    'Cable management needs improvement',
    'Projector screen is clean',
    'Wall decorations are neat',
    'Ventilation is adequate',
  ];

  static const List<String> recommendationsPool = [
    'Wipe the whiteboard thoroughly after each use',
    'Empty trash bins before leaving',
    'Arrange chairs under desks when leaving',
    'Sweep the floor daily',
    'Clean desk surfaces with damp cloth',
    'Organize bookshelves weekly',
    'Sanitize door handles regularly',
    'Report broken equipment to teacher',
    'Water classroom plants on schedule',
    'Maintain tidy personal spaces',
    'Use designated areas for eating',
    'Clean windows bi-weekly',
    'Improve recycling practices',
    'Maintain air quality with proper ventilation',
    'Store cleaning supplies properly',
  ];

  static const List<String> motivationalQuotes = [
    'A clean space is a productive space! 🌟',
    'Small actions lead to big changes! 💪',
    'Cleanliness is next to excellence! ✨',
    'Every clean corner counts! 🏆',
    'Together we make our school shine! 🌈',
    'Your effort makes a difference! 🎯',
    'Clean today, succeed tomorrow! 🚀',
    'Be the change you want to see! 🌱',
  ];

  // ─── Helper to find student by NIS ──────────────────
  static StudentModel? findStudentByNis(String nis) {
    try {
      return allStudents.firstWhere((s) => s.nis == nis);
    } catch (_) {
      return null;
    }
  }

  // ─── Helper to find teacher by email ────────────────
  static TeacherModel? findTeacherByEmail(String email) {
    try {
      return teachers.firstWhere((t) => t.email == email.toLowerCase());
    } catch (_) {
      return null;
    }
  }

  // ─── Helper to get students by class ────────────────
  static List<StudentModel> getStudentsByClass(String className) {
    if (className == class1Name) return studentsClass1;
    if (className == class2Name) return studentsClass2;
    return [];
  }
}
