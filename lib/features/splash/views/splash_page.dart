import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vibeco_app/core/constants/app_colors.dart';
import 'package:vibeco_app/core/constants/app_typography.dart';
import 'package:vibeco_app/core/utils/extensions.dart';
import 'package:vibeco_app/features/auth/providers/auth_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    _handleTransition();
  }

  Future<void> _handleTransition() async {
    // Keep splash for 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authState = ref.read(authProvider);

    if (authState.student != null) {
      context.go('/student/dashboard');
    } else if (authState.teacher != null) {
      if (authState.teacher!.isHomeroom) {
        context.go('/teacher/homeroom/dashboard');
      } else {
        context.go('/teacher/plh/dashboard');
      }
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

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
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.cleaning_services_rounded,
                  size: 72,
                  color: AppColors.primary,
                ),
              ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 24),
              Text(
                'SmartClean AI',
                style: AppTypography.displayLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.0,
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                ),
              ).animate().fade(delay: 200.ms).slideY(begin: 0.2, duration: 400.ms),
              const SizedBox(height: 8),
              Text(
                'Classroom Cleanliness Assessment System',
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ).animate().fade(delay: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
