import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibeco_app/core/constants/app_colors.dart';
import 'package:vibeco_app/core/constants/app_typography.dart';
import 'package:vibeco_app/core/utils/extensions.dart';
import 'package:vibeco_app/core/widgets/custom_app_bar.dart';
import 'package:vibeco_app/core/widgets/glass_card.dart';
import 'package:vibeco_app/data/models/schedule_models.dart';
import 'package:vibeco_app/features/auth/providers/auth_provider.dart';
import 'package:vibeco_app/features/student/ranking/providers/ranking_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RankingPage extends ConsumerWidget {
  const RankingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studentRankingProvider);
    final currentStudent = ref.watch(authProvider).student;
    final isDark = context.isDark;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Leaderboard',
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
        child: Column(
          children: [
            // Scope Selector
            _buildScopeSelector(context, ref, state),
            
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        // Top 3 Podium
                        if (state.rankings.length >= 3)
                          _buildPodium(context, state.rankings.sublist(0, 3)),
                          
                        // Remaining list
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            itemCount: state.rankings.length > 3
                                ? state.rankings.length - 3
                                : 0,
                            itemBuilder: (context, index) {
                              final item = state.rankings[index + 3];
                              final isMe = currentStudent?.id == item.studentId;
                              final trendColor = item.trend == 'up'
                                  ? AppColors.success
                                  : item.trend == 'down'
                                      ? AppColors.error
                                      : Colors.grey;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: GlassCard(
                                  borderColor: isMe ? AppColors.primary : null,
                                  child: Row(
                                    children: [
                                      // Rank Number
                                      Container(
                                        width: 32,
                                        alignment: Alignment.center,
                                        child: Text(
                                          '#${item.rank}',
                                          style: AppTypography.labelLarge.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Profile Circle
                                      CircleAvatar(
                                        backgroundColor: isMe
                                            ? AppColors.primary.withValues(alpha: 0.2)
                                            : Colors.grey.withValues(alpha: 0.15),
                                        child: Text(
                                          item.studentName.initials,
                                          style: AppTypography.labelMedium.copyWith(
                                            color: isMe ? AppColors.primary : null,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      // Name & Class
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.studentName.titleCase,
                                              style: AppTypography.bodyMedium.copyWith(
                                                fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              item.className,
                                              style: AppTypography.bodySmall.copyWith(
                                                fontSize: 10,
                                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Trend Arrow
                                      Icon(
                                        item.trend == 'up'
                                            ? Icons.arrow_upward_rounded
                                            : item.trend == 'down'
                                                ? Icons.arrow_downward_rounded
                                                : Icons.horizontal_rule_rounded,
                                        color: trendColor,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 16),
                                      // Score Display
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${item.averageScore.toStringAsFixed(1)}%',
                                            style: AppTypography.labelLarge.copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            '${item.totalSubmissions} submissions',
                                            style: AppTypography.labelSmall.copyWith(
                                              fontSize: 8,
                                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ).animate().fade(delay: (index * 50).ms).slideY(begin: 0.1);
                            },
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScopeSelector(
    BuildContext context,
    WidgetRef ref,
    RankingState state,
  ) {
    final isDark = context.isDark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildScopeTab(
              context,
              label: 'Class Ranking',
              selected: state.currentScope == RankingScope.classScope,
              onTap: () => ref.read(studentRankingProvider.notifier).setScope(RankingScope.classScope),
            ),
          ),
          Expanded(
            child: _buildScopeTab(
              context,
              label: 'School Ranking',
              selected: state.currentScope == RankingScope.schoolScope,
              onTap: () => ref.read(studentRankingProvider.notifier).setScope(RankingScope.schoolScope),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScopeTab(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTypography.labelLarge.copyWith(
            color: selected ? Colors.white : (context.isDark ? Colors.white60 : Colors.black87),
          ),
        ),
      ),
    );
  }

  Widget _buildPodium(BuildContext context, List<RankingModel> topThree) {
    // topThree[0] = #1 (Gold)
    // topThree[1] = #2 (Silver)
    // topThree[2] = #3 (Bronze)

    final first = topThree[0];
    final second = topThree[1];
    final third = topThree[2];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // #2 Silver
          Expanded(
            child: _buildPodiumCard(
              context,
              item: second,
              badgeColor: Colors.grey.shade400,
              badgeText: '2',
              cardHeight: 140,
            ).animate().fade().scale(duration: 400.ms),
          ),
          const SizedBox(width: 12),
          // #1 Gold
          Expanded(
            child: _buildPodiumCard(
              context,
              item: first,
              badgeColor: const Color(0xFFFFD700),
              badgeText: '1',
              cardHeight: 170,
              isGold: true,
            ).animate().fade().scale(duration: 500.ms, curve: Curves.easeOutBack),
          ),
          const SizedBox(width: 12),
          // #3 Bronze
          Expanded(
            child: _buildPodiumCard(
              context,
              item: third,
              badgeColor: const Color(0xFFCD7F32),
              badgeText: '3',
              cardHeight: 120,
            ).animate().fade().scale(duration: 400.ms),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumCard(
    BuildContext context, {
    required RankingModel item,
    required Color badgeColor,
    required String badgeText,
    required double cardHeight,
    bool isGold = false,
  }) {
    final isDark = context.isDark;

    return GlassCard(
      padding: const EdgeInsets.all(12),
      borderColor: isGold ? const Color(0xFFFFD700).withValues(alpha: 0.5) : null,
      child: SizedBox(
        height: cardHeight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: isGold ? 28 : 22,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    item.studentName.initials,
                    style: AppTypography.labelLarge.copyWith(
                      fontSize: isGold ? 18 : 14,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      badgeText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.studentName.titleCase,
              style: AppTypography.labelMedium.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            Text(
              item.className,
              style: AppTypography.bodySmall.copyWith(
                fontSize: 8,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            Text(
              '${item.averageScore.toStringAsFixed(1)}%',
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: isGold ? 20 : 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
