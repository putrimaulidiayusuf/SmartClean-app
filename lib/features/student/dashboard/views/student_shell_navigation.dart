import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:vibeco_app/core/constants/app_colors.dart';
import 'package:vibeco_app/core/utils/extensions.dart';
import 'package:vibeco_app/features/student/dashboard/views/student_dashboard_page.dart';
import 'package:vibeco_app/features/student/history/views/history_page.dart';
import 'package:vibeco_app/features/student/ranking/views/ranking_page.dart';
import 'package:vibeco_app/features/student/profile/views/profile_page.dart';

class StudentShellNavigation extends StatefulWidget {
  const StudentShellNavigation({super.key});

  @override
  State<StudentShellNavigation> createState() => _StudentShellNavigationState();
}

class _StudentShellNavigationState extends State<StudentShellNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    StudentDashboardPage(),
    HistoryPage(),
    RankingPage(),
    StudentProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark
              ? Colors.black.withValues(alpha: 0.8)
              : Colors.white.withValues(alpha: 0.8),
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.glassBorderDark : Colors.grey.shade200,
            ),
          ),
        ),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              backgroundColor: Colors.transparent,
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: isDark ? Colors.white60 : Colors.black54,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined),
                  activeIcon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history_outlined),
                  activeIcon: Icon(Icons.history),
                  label: 'History',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.emoji_events_outlined),
                  activeIcon: Icon(Icons.emoji_events),
                  label: 'Leaderboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline_rounded),
                  activeIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
