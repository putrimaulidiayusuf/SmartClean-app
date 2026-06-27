import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vibeco_app/core/constants/app_colors.dart';
import 'package:vibeco_app/core/constants/app_typography.dart';
import 'package:vibeco_app/core/utils/extensions.dart';
import 'package:vibeco_app/core/widgets/custom_app_bar.dart';
import 'package:vibeco_app/core/widgets/empty_state.dart';
import 'package:vibeco_app/core/widgets/glass_card.dart';
import 'package:vibeco_app/core/widgets/status_badge.dart';
import 'package:vibeco_app/data/models/cleaning_record_model.dart';
import 'package:vibeco_app/features/student/history/providers/history_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studentHistoryProvider);
    final isDark = context.isDark;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Cleaning History',
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
            // Filter Selector
            _buildFilterChips(context, ref, state),
            
            // History list
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.filteredRecords.isEmpty
                      ? EmptyState(
                          icon: Icons.history_toggle_off_rounded,
                          title: 'No Records Found',
                          subtitle: 'You don\'t have any ${state.currentFilter.name} records in this view.',
                        )
                      : RefreshIndicator(
                          onRefresh: () => ref.read(studentHistoryProvider.notifier).loadHistory(),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: state.filteredRecords.length,
                            itemBuilder: (context, index) {
                              final record = state.filteredRecords[index];
                              final scoreColor = AppColors.getScoreColor(record.score);

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: GlassCard(
                                  onTap: () => context.push('/student/smartcheck/result', extra: record),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: scoreColor.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          record.score.toStringAsFixed(0),
                                          style: AppTypography.scoreMedium.copyWith(
                                            color: scoreColor,
                                            fontSize: 24,
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
                                              style: AppTypography.titleMedium.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${record.findings.length} findings · ${record.recommendations.length} recs',
                                              style: AppTypography.bodySmall.copyWith(
                                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      StatusBadge(
                                        label: record.status.name.toUpperCase(),
                                        type: record.status == CleaningStatus.verified
                                            ? BadgeType.verified
                                            : record.status == CleaningStatus.rejected
                                                ? BadgeType.error
                                                : BadgeType.pending,
                                      ),
                                    ],
                                  ),
                                ),
                              ).animate().fade(delay: (index * 50).ms).slideY(begin: 0.1);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(
    BuildContext context,
    WidgetRef ref,
    HistoryState state,
  ) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: HistoryFilter.values.length,
        itemBuilder: (context, index) {
          final filter = HistoryFilter.values[index];
          final isSelected = state.currentFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter.name.toUpperCase()),
              selected: isSelected,
              onSelected: (_) {
                ref.read(studentHistoryProvider.notifier).setFilter(filter);
              },
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : (context.isDark ? Colors.white60 : Colors.black54),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              backgroundColor: context.isDark ? Colors.white10 : Colors.white70,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primary
                      : (context.isDark ? Colors.white12 : Colors.grey.shade200),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
