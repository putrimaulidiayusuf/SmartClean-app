import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibeco_app/core/constants/app_colors.dart';
import 'package:vibeco_app/core/constants/app_typography.dart';
import 'package:vibeco_app/core/utils/extensions.dart';
import 'package:vibeco_app/core/widgets/custom_app_bar.dart';
import 'package:vibeco_app/core/widgets/empty_state.dart';
import 'package:vibeco_app/core/widgets/glass_card.dart';
import 'package:vibeco_app/features/teacher/plh/providers/plh_provider.dart';

class AuditLogPage extends ConsumerWidget {
  const AuditLogPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(plhProvider);
    final isDark = context.isDark;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Audit Log Feed',
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
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.auditLogs.isEmpty
                ? const EmptyState(
                    icon: Icons.history_edu_rounded,
                    title: 'No Activity Found',
                    subtitle: 'Verifications will appear here once verifications occur.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: state.auditLogs.length,
                    itemBuilder: (context, index) {
                      final log = state.auditLogs[index];
                      final isApproved = log.action == 'approved';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        isApproved ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                        color: isApproved ? AppColors.success : AppColors.error,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        isApproved ? 'APPROVED' : 'REJECTED',
                                        style: AppTypography.labelLarge.copyWith(
                                          color: isApproved ? AppColors.success : AppColors.error,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    log.timestamp.formattedFull,
                                    style: AppTypography.bodySmall.copyWith(fontSize: 10),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Auditor: ${log.teacherName}',
                                style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              if (log.newScore != null && log.oldScore != null && log.newScore != log.oldScore)
                                Text(
                                  'Score Changed: ${log.oldScore!.toStringAsFixed(0)}% ➔ ${log.newScore!.toStringAsFixed(0)}%',
                                  style: AppTypography.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                                ),
                              if (log.notes != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Notes: "${log.notes}"',
                                  style: AppTypography.bodySmall.copyWith(fontStyle: FontStyle.italic),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
