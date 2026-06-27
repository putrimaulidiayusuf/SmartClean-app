import 'dart:io';
import 'package:fl_chart/fl_chart.dart';
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
import 'package:vibeco_app/features/teacher/homeroom/providers/homeroom_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeroomDashboardPage extends ConsumerWidget {
  const HomeroomDashboardPage({super.key});

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
    final state = ref.watch(homeroomProvider);
    final isDark = context.isDark;

    if (authState.teacher == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final teacher = authState.teacher!;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Homeroom Portal',
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          child: CircleAvatar(
            backgroundColor: AppColors.accent.withValues(alpha: 0.2),
            child: Text(
              teacher.name.initials,
              style: AppTypography.labelLarge.copyWith(color: AppColors.accent),
            ),
          ),
        ),
        actions: [
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
              onRefresh: () => ref.read(homeroomProvider.notifier).loadHomeroomData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Class Header
                    _buildHeader(context, teacher, state),
                    const SizedBox(height: 24),

                    // Average Scores Cards (Total, Weekly, Monthly)
                    _buildOverviewScores(context, state),
                    const SizedBox(height: 24),

                    // Today's Upload & Missing list
                    _buildTodayUploads(context, state),
                    const SizedBox(height: 24),

                    // Performance Trend Graph
                    _buildTrendChart(context, state),
                    const SizedBox(height: 24),

                    // Student Ranking List
                    _buildRankingList(context, state),
                    const SizedBox(height: 24),

                    // Roster Duty Schedule
                    _buildDutyRoster(context, state),
                    const SizedBox(height: 24),

                    // Reward Recommendations
                    _buildRewardRecommendations(context, state),
                    const SizedBox(height: 24),

                    // Classroom Gallery
                    _buildGallery(context, state),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic teacher, HomeroomState state) {
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
          'Homeroom Teacher for: ${state.className}',
          style: AppTypography.titleMedium.copyWith(
            color: context.isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
      ],
    ).animate().fade().slideX(begin: -0.1);
  }

  Widget _buildOverviewScores(BuildContext context, HomeroomState state) {
    return Row(
      children: [
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Column(
              children: [
                ScoreIndicator(score: state.averageScore, size: 70, lineWidth: 6, showLabel: false),
                const SizedBox(height: 12),
                Text(
                  'Class Avg',
                  style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Column(
              children: [
                ScoreIndicator(score: state.weeklyAverageScore, size: 70, lineWidth: 6, showLabel: false),
                const SizedBox(height: 12),
                Text(
                  'Weekly Avg',
                  style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Column(
              children: [
                ScoreIndicator(score: state.monthlyAverageScore, size: 70, lineWidth: 6, showLabel: false),
                const SizedBox(height: 12),
                Text(
                  'Monthly Avg',
                  style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    ).animate().fade(delay: 100.ms).slideY(begin: 0.1);
  }

  Widget _buildTodayUploads(BuildContext context, HomeroomState state) {
    final isDark = context.isDark;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Upload Status',
                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              StatusBadge(
                label: '${state.todaysRecords.length} / ${state.onDutyToday.length} UPLOADED',
                type: state.missingUploadsToday.isEmpty ? BadgeType.success : BadgeType.warning,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (state.onDutyToday.isEmpty)
            Text(
              'No cleaning schedules recorded for today.',
              style: AppTypography.bodySmall,
            )
          else ...[
            Text(
              'On Duty Roster:',
              style: AppTypography.labelMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.onDutyToday.length,
              separatorBuilder: (_, __) => const Divider(height: 12),
              itemBuilder: (context, index) {
                final student = state.onDutyToday[index];
                final uploaded = state.todaysRecords.any((r) => r.studentId == student.id);

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      student.name.titleCase,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: uploaded ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    Row(
                      children: [
                        if (uploaded) ...[
                          const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                          const SizedBox(width: 4),
                          Text('Submitted', style: AppTypography.bodySmall.copyWith(color: AppColors.success)),
                        ] else ...[
                          const Icon(Icons.pending_actions_rounded, color: AppColors.warning, size: 20),
                          const SizedBox(width: 4),
                          Text('Missing Upload', style: AppTypography.bodySmall.copyWith(color: AppColors.warning)),
                        ],
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    ).animate().fade(delay: 200.ms).slideY(begin: 0.1);
  }

  Widget _buildTrendChart(BuildContext context, HomeroomState state) {
    final isDark = context.isDark;

    // Filter past 7 submissions to render trend
    final recentRecords = state.classRecords.take(7).toList().reversed.toList();
    if (recentRecords.length < 2) {
      return const SizedBox.shrink();
    }

    final spots = List.generate(recentRecords.length, (index) {
      return FlSpot(index.toDouble(), recentRecords[index].score);
    });

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Cleanliness Trend',
            style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < recentRecords.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              recentRecords[index].date.shortDay,
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      reservedSize: 30,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3.5,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withValues(alpha: 0.15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fade(delay: 300.ms).slideY(begin: 0.1);
  }

  Widget _buildRankingList(BuildContext context, HomeroomState state) {
    final isDark = context.isDark;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Class Cleaning Rankings',
            style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.studentRankings.length > 5 ? 5 : state.studentRankings.length,
            separatorBuilder: (_, __) => const Divider(height: 16),
            itemBuilder: (context, index) {
              final student = state.studentRankings[index];
              return Row(
                children: [
                  Text(
                    '#${student.rank}',
                    style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      student.studentName.initials,
                      style: AppTypography.labelSmall.copyWith(color: AppColors.primary, fontSize: 10),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      student.studentName.titleCase,
                      style: AppTypography.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${student.averageScore.toStringAsFixed(1)}%',
                    style: AppTypography.labelMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    ).animate().fade(delay: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildDutyRoster(BuildContext context, HomeroomState state) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Weekly Duty Schedule Roster',
            style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.dutySchedule.length,
            separatorBuilder: (_, __) => const Divider(height: 16),
            itemBuilder: (context, index) {
              final roster = state.dutySchedule[index];
              final isToday = DateTime.now().dayName == roster.dayName;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        roster.dayName,
                        style: AppTypography.labelLarge.copyWith(
                          color: isToday ? AppColors.primary : null,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isToday)
                        StatusBadge(label: 'TODAY', type: BadgeType.success, fontSize: 8),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    roster.studentNames.map((name) => name.titleCase).join(', '),
                    style: AppTypography.bodySmall,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    ).animate().fade(delay: 500.ms).slideY(begin: 0.1);
  }

  Widget _buildRewardRecommendations(BuildContext context, HomeroomState state) {
    final isDark = context.isDark;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 24),
              const SizedBox(width: 8),
              Text(
                'Reward Recommendations',
                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'The following students maintain a Cleanliness Score of 90% or above and are recommended for special recognition rewards:',
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 16),
          if (state.rewardRecommendations.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'No students currently recommended.',
                style: AppTypography.bodySmall.copyWith(fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.rewardRecommendations.length,
              itemBuilder: (context, index) {
                final student = state.rewardRecommendations[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.military_tech_rounded, color: Color(0xFFFFD700), size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          student.name.titleCase,
                          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      StatusBadge(label: '90%+ AVG', type: BadgeType.success, fontSize: 8),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    ).animate().fade(delay: 600.ms).slideY(begin: 0.1);
  }

  Widget _buildGallery(BuildContext context, HomeroomState state) {
    if (state.galleryPhotos.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Classroom SmartCheck Gallery',
          style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: state.galleryPhotos.length,
            itemBuilder: (context, index) {
              final photo = state.galleryPhotos[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: 120,
                    child: photo.startsWith('/')
                        ? Image.file(
                            File(photo),
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            photo,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey.withValues(alpha: 0.2),
                              child: const Icon(Icons.broken_image),
                            ),
                          ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ).animate().fade(delay: 700.ms).slideY(begin: 0.1);
  }
}
