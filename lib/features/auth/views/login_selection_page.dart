import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibeco_app/core/constants/app_colors.dart';
import 'package:vibeco_app/core/constants/app_typography.dart';
import 'package:vibeco_app/core/widgets/glass_card.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LoginSelectionPage extends StatelessWidget {
  const LoginSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
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
        child: Stack(
          children: [
            // Decorative background blobs
            Positioned(
              top: -100,
              right: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.25),
                ),
              ).animate().fade(duration: 800.ms).scale(duration: 1000.ms),
            ),
            Positioned(
              bottom: -50,
              left: -50,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent.withValues(alpha: isDark ? 0.1 : 0.2),
                ),
              ).animate().fade(duration: 1200.ms).scale(duration: 1400.ms),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 48),
                    // Header Logo and Slogan
                    Center(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.cleaning_services_rounded,
                              size: 48,
                              color: AppColors.primary,
                            ),
                          ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                          const SizedBox(height: 16),
                          Text(
                            'SmartClean AI',
                            style: AppTypography.displaySmall.copyWith(
                              color: isDark ? Colors.white : AppColors.textPrimaryLight,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ).animate().fade(delay: 200.ms),
                          const SizedBox(height: 8),
                          Text(
                            'AI-Powered Classroom Cleanliness Assessment',
                            style: AppTypography.bodyMedium.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                            textAlign: TextAlign.center,
                          ).animate().fade(delay: 300.ms),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Options Selection Title
                    Text(
                      'Select Portal',
                      style: AppTypography.headlineMedium.copyWith(
                        color: isDark ? Colors.white : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fade(delay: 400.ms).slideY(begin: 0.2, duration: 400.ms),
                    const SizedBox(height: 24),
                    // Student Portal Card
                    GlassCard(
                      onTap: () => context.push('/login/student'),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.school_rounded,
                              color: AppColors.primary,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Student Portal',
                                  style: AppTypography.titleLarge.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Daily SmartCheck, scheduling & tasks',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: isDark ? Colors.white60 : Colors.black54,
                            size: 18,
                          ),
                        ],
                      ),
                    ).animate().fade(delay: 500.ms).slideY(begin: 0.2, duration: 400.ms),
                    const SizedBox(height: 16),
                    // Teacher Portal Card
                    GlassCard(
                      onTap: () => context.push('/login/teacher'),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.supervisor_account_rounded,
                              color: AppColors.accent,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Teacher Portal',
                                  style: AppTypography.titleLarge.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Homeroom monitor & PLH AI verification',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: isDark ? Colors.white60 : Colors.black54,
                            size: 18,
                          ),
                        ],
                      ),
                    ).animate().fade(delay: 600.ms).slideY(begin: 0.2, duration: 400.ms),
                    const Spacer(),
                    // Bottom design credits
                    Center(
                      child: Text(
                        'LKS Nasional 2026',
                        style: AppTypography.labelSmall.copyWith(
                          color: isDark ? Colors.white30 : Colors.black26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
