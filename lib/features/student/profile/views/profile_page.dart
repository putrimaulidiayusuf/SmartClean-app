import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vibeco_app/core/constants/app_colors.dart';
import 'package:vibeco_app/core/constants/app_typography.dart';
import 'package:vibeco_app/core/utils/extensions.dart';
import 'package:vibeco_app/core/widgets/custom_app_bar.dart';
import 'package:vibeco_app/core/widgets/glass_card.dart';
import 'package:vibeco_app/features/auth/providers/auth_provider.dart';
import 'package:vibeco_app/features/student/dashboard/providers/student_dashboard_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StudentProfilePage extends ConsumerWidget {
  const StudentProfilePage({super.key});

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out from SmartClean AI?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(authProvider.notifier).logout();
      if (context.mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final student = ref.watch(authProvider).student;
    final dashboardState = ref.watch(studentDashboardProvider);
    final isDark = context.isDark;

    if (student == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final avgScore = dashboardState.rankingPreview?.averageScore ?? 0.0;
    final rank = dashboardState.rankingPreview?.rank ?? 0;
    final totalSubmissions = dashboardState.rankingPreview?.totalSubmissions ?? 0;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Profile',
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF020617)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [Color(0xFFE8F5E9), Color(0xFFFAFFFE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User header info
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                      child: Text(
                        student.name.initials,
                        style: AppTypography.scoreDisplay.copyWith(
                          color: AppColors.primary,
                          fontSize: 36,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      student.name.titleCase,
                      style: AppTypography.headlineLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'NIS: ${student.nis}',
                      style: AppTypography.bodyMedium.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Chip(
                      label: Text(student.className),
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    ),
                  ],
                ),
              ).animate().fade().scale(duration: 300.ms),
              const SizedBox(height: 32),

              // Performance Summary Stats
              Text(
                'Performance Summary',
                style: AppTypography.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      label: 'Avg Score',
                      value: '${avgScore.toStringAsFixed(1)}%',
                      icon: Icons.star_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      label: 'Class Rank',
                      value: rank > 0 ? '#$rank' : '-',
                      icon: Icons.emoji_events_rounded,
                      color: const Color(0xFFFFD700),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      label: 'Total Uploads',
                      value: '$totalSubmissions',
                      icon: Icons.cloud_done_rounded,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ).animate().fade(delay: 100.ms).slideY(begin: 0.1),
              const SizedBox(height: 24),

              // Achievements section
              Text(
                'Student Badges',
                style: AppTypography.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              GlassCard(
                child: Column(
                  children: [
                    _buildBadgeRow(
                      context,
                      icon: Icons.shield_rounded,
                      title: 'Cleanliness Champion',
                      desc: 'Maintain average score > 90%',
                      unlocked: avgScore >= 90.0,
                    ),
                    const Divider(height: 24),
                    _buildBadgeRow(
                      context,
                      icon: Icons.speed_rounded,
                      title: 'Consistent Sweeper',
                      desc: 'Submit at least 15 clean logs',
                      unlocked: totalSubmissions >= 15,
                    ),
                    const Divider(height: 24),
                    _buildBadgeRow(
                      context,
                      icon: Icons.check_circle_rounded,
                      title: 'First SmartCheck',
                      desc: 'Complete your first classroom scan',
                      unlocked: totalSubmissions >= 1,
                    ),
                  ],
                ),
              ).animate().fade(delay: 200.ms).slideY(begin: 0.1),
              const SizedBox(height: 32),

              // Settings & Logout Buttons
              GlassCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.settings_outlined),
                      title: const Text('App Settings'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => context.push('/student/settings'),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.logout_rounded, color: AppColors.error),
                      title: const Text(
                        'Log Out',
                        style: TextStyle(color: AppColors.error),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.error),
                      onTap: () => _handleLogout(context, ref),
                    ),
                  ],
                ),
              ).animate().fade(delay: 300.ms),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final isDark = context.isDark;

    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              fontSize: 9,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String desc,
    required bool unlocked,
  }) {
    final isDark = context.isDark;

    return Opacity(
      opacity: unlocked ? 1.0 : 0.4,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: unlocked
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : Colors.grey.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: unlocked ? AppColors.primary : Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  desc,
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          if (unlocked)
            const Icon(
              Icons.check_circle,
              color: AppColors.primary,
              size: 20,
            )
          else
            const Icon(
              Icons.lock_outline_rounded,
              color: Colors.grey,
              size: 20,
            ),
        ],
      ),
    );
  }
}
