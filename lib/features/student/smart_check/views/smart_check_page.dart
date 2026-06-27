import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vibeco_app/core/constants/app_colors.dart';
import 'package:vibeco_app/core/constants/app_typography.dart';
import 'package:vibeco_app/core/utils/extensions.dart';
import 'package:vibeco_app/core/widgets/ai_processing_animation.dart';
import 'package:vibeco_app/core/widgets/custom_app_bar.dart';
import 'package:vibeco_app/core/widgets/glass_card.dart';
import 'package:vibeco_app/core/widgets/gradient_button.dart';
import 'package:vibeco_app/features/student/smart_check/providers/smart_check_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SmartCheckPage extends ConsumerStatefulWidget {
  const SmartCheckPage({super.key});

  @override
  ConsumerState<SmartCheckPage> createState() => _SmartCheckPageState();
}

class _SmartCheckPageState extends ConsumerState<SmartCheckPage> {
  @override
  void initState() {
    super.initState();
    // Reset smart check state when entering the page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(smartCheckProvider.notifier).reset();
    });
  }

  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Select Photo Source',
                  style: AppTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPickerOption(
                      icon: Icons.camera_alt_outlined,
                      label: 'Camera',
                      onTap: () {
                        Navigator.pop(context);
                        ref.read(smartCheckProvider.notifier).pickImage(ImageSource.camera);
                      },
                    ),
                    _buildPickerOption(
                      icon: Icons.photo_library_outlined,
                      label: 'Gallery',
                      onTap: () {
                        Navigator.pop(context);
                        ref.read(smartCheckProvider.notifier).pickImage(ImageSource.gallery);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = context.isDark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.grey.shade200,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTypography.labelLarge,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleProcess() async {
    final success = await ref.read(smartCheckProvider.notifier).processWithAi();
    if (success && mounted) {
      final result = ref.read(smartCheckProvider).resultRecord;
      if (result != null) {
        context.pushReplacement('/student/smartcheck/result', extra: result);
      }
    } else {
      if (mounted) {
        final err = ref.read(smartCheckProvider).errorMessage;
        if (err != null) {
          context.showSnackBar(err, isError: true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(smartCheckProvider);
    final isDark = context.isDark;

    if (state.isProcessing) {
      return Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: isDark ? AppColors.darkGradient : AppColors.cardGradientLight,
          ),
          child: const Center(
            child: AiProcessingAnimation(
              label: 'SmartClean AI is assessing cleanliness...',
            ),
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomAppBar(
        title: 'Daily SmartCheck',
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
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: GlassCard(
                    padding: EdgeInsets.zero,
                    child: state.photoPath != null
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(
                                File(state.photoPath!),
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: 16,
                                right: 16,
                                child: IconButton(
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.black54,
                                    foregroundColor: Colors.white,
                                  ),
                                  icon: const Icon(Icons.refresh_rounded),
                                  onPressed: _showImagePickerModal,
                                ),
                              ),
                            ],
                          )
                        : InkWell(
                            onTap: _showImagePickerModal,
                            borderRadius: BorderRadius.circular(20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.add_a_photo_outlined,
                                    size: 64,
                                    color: AppColors.primary,
                                  ),
                                ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                                const SizedBox(height: 24),
                                Text(
                                  'Upload Classroom Photo',
                                  style: AppTypography.titleLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 32),
                                  child: Text(
                                    'Take a high-quality photo of your classroom cleanliness. SmartClean AI will automatically calculate cleanliness scores.',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                if (state.photoPath != null)
                  GradientButton(
                    text: 'Analyze with SmartClean AI',
                    icon: Icons.auto_awesome_rounded,
                    onPressed: _handleProcess,
                  ).animate().fade().scale(duration: 200.ms)
                else
                  OutlinedButton.icon(
                    onPressed: _showImagePickerModal,
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: const Text('Capture Classroom'),
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
