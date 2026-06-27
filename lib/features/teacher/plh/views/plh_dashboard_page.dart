import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vibeco_app/core/constants/app_colors.dart';
import 'package:vibeco_app/core/constants/app_typography.dart';
import 'package:vibeco_app/core/utils/extensions.dart';
import 'package:vibeco_app/core/widgets/custom_app_bar.dart';
import 'package:vibeco_app/core/widgets/glass_card.dart';
import 'package:vibeco_app/core/widgets/score_indicator.dart';
import 'package:vibeco_app/core/widgets/status_badge.dart';
import 'package:vibeco_app/features/auth/providers/auth_provider.dart';
import 'package:vibeco_app/features/teacher/plh/providers/plh_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PlhDashboardPage extends ConsumerWidget {
  const PlhDashboardPage({super.key});

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
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
    final authState = ref.watch(authProvider);
    final state = ref.watch(plhProvider);
    final isDark = context.isDark;

    if (authState.teacher == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final teacher = authState.teacher!;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'PLH Portal',
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          child: CircleAvatar(
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            child: Text(
              teacher.name.initials,
              style: AppTypography.labelLarge.copyWith(color: AppColors.primary),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_outlined),
            onPressed: () => context.push('/teacher/plh/audit-log'),
            tooltip: 'Audit Log',
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            onPressed: () => _handleLogout(context, ref),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(plhProvider.notifier).loadPlhData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // PLH Header
                    _buildHeader(context, teacher, state),
                    const SizedBox(height: 24),

                    // Key Performance Indicators (KPIs)
                    _buildSchoolKpis(context, state),
                    const SizedBox(height: 24),

                    // Pending Verification Queue
                    _buildVerificationQueue(context, state),
                    const SizedBox(height: 24),

                    // School Rankings (Class rankings list)
                    _buildClassRankings(context, state),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic teacher, PlhState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome, ${teacher.name.titleCase} 👋',
          style: AppTypography.displaySmall.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'PLH Environment Teacher (School Access)',
          style: AppTypography.titleMedium.copyWith(
            color: context.isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
      ],
    ).animate().fade().slideX(begin: -0.1);
  }

  Widget _buildSchoolKpis(BuildContext context, PlhState state) {
    return Row(
      children: [
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  '${state.pendingQueue.length}',
                  style: AppTypography.scoreMedium.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Pending Review',
                  style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  '${state.verifiedToday.length}',
                  style: AppTypography.scoreMedium.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Verified Today',
                  style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  '${state.schoolAverageScore.toStringAsFixed(1)}%',
                  style: AppTypography.scoreMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'School Avg',
                  style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    ).animate().fade(delay: 100.ms).slideY(begin: 0.1);
  }

  Widget _buildVerificationQueue(BuildContext context, PlhState state) {
    final isDark = context.isDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Verification Queue',
          style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (state.pendingQueue.isEmpty)
          GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 40),
                  const SizedBox(height: 12),
                  Text(
                    'All Caught Up!',
                    style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'No cleaning reports are currently pending verification.',
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.pendingQueue.length,
            itemBuilder: (context, index) {
              final record = state.pendingQueue[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: GlassCard(
                  onTap: () => context.push('/teacher/plh/verify', extra: record),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.getScoreColor(record.score).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          record.score.toStringAsFixed(0),
                          style: AppTypography.scoreMedium.copyWith(
                            fontSize: 22,
                            color: AppColors.getScoreColor(record.score),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              record.studentName.titleCase,
                              style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Class: ${record.className} · ${record.createdAt.relative}',
                              style: AppTypography.bodySmall.copyWith(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    ).animate().fade(delay: 200.ms).slideY(begin: 0.1);
  }

  Widget _buildClassRankings(BuildContext context, PlhState state) {
    final isDark = context.isDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'School Class Rankings',
          style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GlassCard(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.schoolRankings.length > 5 ? 5 : state.schoolRankings.length,
            separatorBuilder: (_, __) => const Divider(height: 16),
            itemBuilder: (context, index) {
              final ranking = state.schoolRankings[index];
              return Row(
                children: [
                  Text(
                    '#${index + 1}',
                    style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ranking.studentName.titleCase,
                          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          ranking.className,
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${ranking.averageScore.toStringAsFixed(1)}%',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    ).animate().fade(delay: 300.ms).slideY(begin: 0.1);
  }
}
