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
import 'package:vibeco_app/data/models/cleaning_record_model.dart';
import 'package:vibeco_app/features/auth/providers/auth_provider.dart';
import 'package:vibeco_app/features/student/dashboard/providers/student_dashboard_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StudentDashboardPage extends ConsumerWidget {
  const StudentDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final dashboardState = ref.watch(studentDashboardProvider);
    final isDark = context.isDark;

    if (authState.student == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final student = authState.student!;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'SmartClean AI',
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          child: CircleAvatar(
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            child: Text(
              student.name.initials,
              style: AppTypography.labelLarge.copyWith(color: AppColors.primary),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/student/settings'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: dashboardState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(studentDashboardProvider.notifier).loadDashboardData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Greeting Card
                    _buildGreetingSection(context, student, dashboardState),
                    const SizedBox(height: 20),

                    // Today's Score & Status
                    _buildTodayScoreSection(context, dashboardState),
                    const SizedBox(height: 20),

                    // Today's Duty Schedule
                    _buildDutySection(context, ref, dashboardState),
                    const SizedBox(height: 20),

                    // Ranking Preview
                    _buildRankingPreviewSection(context, dashboardState),
                    const SizedBox(height: 20),

                    // Recent History
                    _buildRecentHistorySection(context, dashboardState),
                    const SizedBox(height: 20),

                    // Motivational Card
                    _buildMotivationalSection(context, dashboardState),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildGreetingSection(
      BuildContext context, dynamic student, StudentDashboardState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello, ${student.name.titleCase} 👋',
          style: AppTypography.displaySmall.copyWith(
            fontWeight: FontWeight.w800,
            color: context.isDark ? Colors.white : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Class: ${student.className}',
          style: AppTypography.titleMedium.copyWith(
            color: context.isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
      ],
    ).animate().fade().slideX(begin: -0.1, duration: 300.ms);
  }

  Widget _buildTodayScoreSection(BuildContext context, StudentDashboardState state) {
    final sub = state.todaysSubmission;
    final isDark = context.isDark;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s SmartCheck',
                style: AppTypography.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                ),
              ),
              if (sub != null)
                StatusBadge(
                  label: sub.status.name.toUpperCase(),
                  type: sub.status == CleaningStatus.verified
                      ? BadgeType.verified
                      : sub.status == CleaningStatus.rejected
                          ? BadgeType.error
                          : BadgeType.pending,
                ),
            ],
          ),
          const SizedBox(height: 20),
          if (sub != null) ...[
            Row(
              children: [
                ScoreIndicator(score: sub.score, size: 90, lineWidth: 8),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Score Assessment',
                        style: AppTypography.labelLarge.copyWith(
                          color: isDark ? Colors.white : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Findings: ${sub.findings.length} issues identified.',
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => context.push('/student/smartcheck/result', extra: sub),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('View AI Findings'),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_rounded, size: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ] else ...[
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 48,
                    color: AppColors.primary.withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No submission yet today',
                    style: AppTypography.titleMedium.copyWith(
                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    state.isOnDutyToday
                        ? 'It is your cleaning schedule today! Submit a photo to score.'
                        : 'Submit classroom photo to track cleanliness scores.',
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/student/smartcheck'),
                    icon: const Icon(Icons.cloud_upload_outlined),
                    label: const Text('Start Daily SmartCheck'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate().fade(delay: 100.ms).slideY(begin: 0.1, duration: 300.ms);
  }

  Widget _buildDutySection(BuildContext context, WidgetRef ref, StudentDashboardState state) {
    final isDark = context.isDark;
    final duty = state.todaysDuty;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Cleaning Schedule',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                ),
              ),
              if (state.isOnDutyToday)
                StatusBadge(
                  label: 'YOUR TURN',
                  type: BadgeType.success,
                  icon: Icons.star_rounded,
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (duty == null)
            Text(
              'No cleaning tasks scheduled for today.',
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            )
          else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: duty.studentNames.length,
              separatorBuilder: (_, __) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final studentName = duty.studentNames[index];
                final studentId = duty.studentIds[index];
                final isMe = ref.read(authProvider).student?.id == studentId;

                return Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isMe ? AppColors.primary : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        studentName.titleCase,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                          color: isMe
                              ? AppColors.primary
                              : (isDark ? Colors.white : AppColors.textPrimaryLight),
                        ),
                      ),
                    ),
                    if (isMe)
                      Text(
                        '(You)',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    ).animate().fade(delay: 200.ms).slideY(begin: 0.1, duration: 300.ms);
  }

  Widget _buildRankingPreviewSection(BuildContext context, StudentDashboardState state) {
    final isDark = context.isDark;
    final rank = state.rankingPreview;

    return GlassCard(
      onTap: () => context.push('/student/ranking'),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cleanliness Rank',
                  style: AppTypography.labelLarge.copyWith(
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  rank != null
                      ? 'Rank #${rank.rank} in your class'
                      : 'Not ranked yet',
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          if (rank != null) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${rank.averageScore.toStringAsFixed(1)}%',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'Average Score',
                  style: AppTypography.labelSmall.copyWith(
                    fontSize: 9,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
          ],
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
        ],
      ),
    ).animate().fade(delay: 300.ms).slideY(begin: 0.1, duration: 300.ms);
  }

  Widget _buildRecentHistorySection(BuildContext context, StudentDashboardState state) {
    final isDark = context.isDark;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent SmartChecks',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                ),
              ),
              TextButton(
                onPressed: () => context.push('/student/history'),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (state.recentHistory.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'No cleanliness records found.',
                style: AppTypography.bodySmall.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.recentHistory.length,
              separatorBuilder: (_, __) => const Divider(height: 20),
              itemBuilder: (context, index) {
                final record = state.recentHistory[index];
                final scoreColor = AppColors.getScoreColor(record.score);

                return InkWell(
                  onTap: () => context.push('/student/smartcheck/result', extra: record),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: scoreColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          record.score.toStringAsFixed(0),
                          style: AppTypography.labelLarge.copyWith(
                            color: scoreColor,
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
                              record.date.formatted,
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : AppColors.textPrimaryLight,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${record.findings.length} findings identified',
                              style: AppTypography.bodySmall.copyWith(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      StatusBadge(
                        label: record.status.name,
                        type: record.status == CleaningStatus.verified
                            ? BadgeType.verified
                            : record.status == CleaningStatus.rejected
                                ? BadgeType.error
                                : BadgeType.pending,
                        fontSize: 9,
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    ).animate().fade(delay: 400.ms).slideY(begin: 0.1, duration: 300.ms);
  }

  Widget _buildMotivationalSection(BuildContext context, StudentDashboardState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lightbulb_rounded,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              state.motivationalQuote,
              style: AppTypography.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    ).animate().fade(delay: 500.ms).scale(duration: 300.ms);
  }
}
