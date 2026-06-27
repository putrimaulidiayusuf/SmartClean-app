import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibeco_app/core/constants/app_colors.dart';
import 'package:vibeco_app/core/constants/app_typography.dart';
import 'package:vibeco_app/core/utils/extensions.dart';
import 'package:vibeco_app/core/widgets/custom_app_bar.dart';
import 'package:vibeco_app/core/widgets/glass_card.dart';
import 'package:vibeco_app/core/widgets/score_indicator.dart';
import 'package:vibeco_app/core/widgets/status_badge.dart';
import 'package:vibeco_app/data/models/cleaning_record_model.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AiResultPage extends StatelessWidget {
  final CleaningRecordModel record;

  const AiResultPage({
    super.key,
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomAppBar(
        title: 'SmartCheck Result',
        showBackButton: true,
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Cleanliness Score Circle Card
                GlassCard(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          StatusBadge(
                            label: record.status.name.toUpperCase(),
                            type: record.status == CleaningStatus.verified
                                ? BadgeType.verified
                                : record.status == CleaningStatus.rejected
                                    ? BadgeType.error
                                    : BadgeType.pending,
                          ),
                          Text(
                            record.date.formatted,
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ScoreIndicator(score: record.score, size: 140, lineWidth: 12),
                      const SizedBox(height: 16),
                      Text(
                        'AI Cleanliness Score',
                        style: AppTypography.headlineSmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Submitted by: ${record.studentName.titleCase}',
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ).animate().fade().slideY(begin: 0.1, duration: 300.ms),
                const SizedBox(height: 20),

                // Uploaded Photo preview (optional)
                if (record.photoPath != null && record.photoPath!.isNotEmpty) ...[
                  Text(
                    'Classroom Photo',
                    style: AppTypography.headlineSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: record.photoPath!.startsWith('/')
                          ? Image.file(
                              File(record.photoPath!),
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              record.photoPath!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey.withValues(alpha: 0.2),
                                child: const Icon(Icons.broken_image, size: 48),
                              ),
                            ),
                    ),
                  ).animate().fade(delay: 100.ms),
                  const SizedBox(height: 24),
                ],

                // AI Findings
                Text(
                  'AI Findings',
                  style: AppTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: record.findings.length,
                    separatorBuilder: (_, __) => const Divider(height: 16),
                    itemBuilder: (context, index) {
                      final finding = record.findings[index];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check_circle_outline_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              finding,
                              style: AppTypography.bodyMedium,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ).animate().fade(delay: 200.ms).slideY(begin: 0.05, duration: 300.ms),
                const SizedBox(height: 24),

                // AI Recommendations
                Text(
                  'Recommendations',
                  style: AppTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: record.recommendations.length,
                    separatorBuilder: (_, __) => const Divider(height: 16),
                    itemBuilder: (context, index) {
                      final rec = record.recommendations[index];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.lightbulb_outline_rounded,
                            color: AppColors.warning,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              rec,
                              style: AppTypography.bodyMedium,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ).animate().fade(delay: 300.ms).slideY(begin: 0.05, duration: 300.ms),
                const SizedBox(height: 32),

                // Back to Dashboard Button
                ElevatedButton(
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/student/dashboard');
                    }
                  },
                  child: const Text('Back to Dashboard'),
                ).animate().fade(delay: 400.ms),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
