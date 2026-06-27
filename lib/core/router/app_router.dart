import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vibeco_app/data/models/cleaning_record_model.dart';
import 'package:vibeco_app/features/auth/views/login_selection_page.dart';
import 'package:vibeco_app/features/auth/views/student_login_page.dart';
import 'package:vibeco_app/features/auth/views/teacher_login_page.dart';
import 'package:vibeco_app/features/splash/views/splash_page.dart';
import 'package:vibeco_app/features/student/dashboard/views/student_shell_navigation.dart';
import 'package:vibeco_app/features/student/settings/views/settings_page.dart';
import 'package:vibeco_app/features/student/smart_check/views/ai_result_page.dart';
import 'package:vibeco_app/features/student/smart_check/views/smart_check_page.dart';
import 'package:vibeco_app/features/teacher/homeroom/views/homeroom_dashboard_page.dart';
import 'package:vibeco_app/features/teacher/plh/views/audit_log_page.dart';
import 'package:vibeco_app/features/teacher/plh/views/plh_dashboard_page.dart';
import 'package:vibeco_app/features/teacher/plh/views/verification_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // Splash
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashPage(),
      ),
      // Auth Select Portals
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginSelectionPage(),
      ),
      GoRoute(
        path: '/login/student',
        builder: (context, state) => const StudentLoginPage(),
      ),
      GoRoute(
        path: '/login/teacher',
        builder: (context, state) => const TeacherLoginPage(),
      ),
      // Student Shell containing dashboard, history, ranking, profile
      GoRoute(
        path: '/student/dashboard',
        builder: (context, state) => const StudentShellNavigation(),
      ),
      GoRoute(
        path: '/student/smartcheck',
        builder: (context, state) => const SmartCheckPage(),
      ),
      GoRoute(
        path: '/student/smartcheck/result',
        builder: (context, state) {
          final record = state.extra as CleaningRecordModel;
          return AiResultPage(record: record);
        },
      ),
      GoRoute(
        path: '/student/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      // Homeroom Teacher Portal
      GoRoute(
        path: '/teacher/homeroom/dashboard',
        builder: (context, state) => const HomeroomDashboardPage(),
      ),
      // PLH Teacher Portal
      GoRoute(
        path: '/teacher/plh/dashboard',
        builder: (context, state) => const PlhDashboardPage(),
      ),
      GoRoute(
        path: '/teacher/plh/verify',
        builder: (context, state) {
          final record = state.extra as CleaningRecordModel;
          return VerificationPage(record: record);
        },
      ),
      GoRoute(
        path: '/teacher/plh/audit-log',
        builder: (context, state) => const AuditLogPage(),
      ),
    ],
  );
});
