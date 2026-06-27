import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibeco_app/core/constants/app_colors.dart';
import 'package:vibeco_app/core/constants/app_typography.dart';
import 'package:vibeco_app/core/utils/extensions.dart';
import 'package:vibeco_app/core/widgets/custom_app_bar.dart';
import 'package:vibeco_app/core/widgets/glass_card.dart';
import 'package:vibeco_app/core/widgets/score_indicator.dart';
import 'package:vibeco_app/core/widgets/gradient_button.dart';
import 'package:vibeco_app/data/models/cleaning_record_model.dart';
import 'package:vibeco_app/features/teacher/plh/providers/plh_provider.dart';

class VerificationPage extends ConsumerStatefulWidget {
  final CleaningRecordModel record;

  const VerificationPage({
    super.key,
    required this.record,
  });

  @override
  ConsumerState<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends ConsumerState<VerificationPage> {
  late double _currentScore;
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _currentScore = widget.record.score;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitVerification(CleaningStatus status) async {
    setState(() {
      _isSubmitting = true;
    });

    final success = await ref.read(plhProvider.notifier).verifyAssessment(
          recordId: widget.record.id,
          status: status,
          newScore: _currentScore,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        );

    setState(() {
      _isSubmitting = false;
    });

    if (success && mounted) {
      context.showSnackBar('Assessment verified successfully!');
      Navigator.pop(context);
    } else {
      if (mounted) {
        context.showSnackBar('Failed to verify assessment.', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Verify Assessment',
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Photo Preview
              if (widget.record.photoPath != null && widget.record.photoPath!.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    height: 220,
                    width: double.infinity,
                    child: widget.record.photoPath!.startsWith('/')
                        ? Image.file(
                            File(widget.record.photoPath!),
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            widget.record.photoPath!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey.withValues(alpha: 0.2),
                              child: const Icon(Icons.broken_image, size: 48),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Metadata card
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Submission Info',
                      style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Student:', style: AppTypography.bodySmall),
                        Text(widget.record.studentName.titleCase, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Class:', style: AppTypography.bodySmall),
                        Text(widget.record.className, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('AI Suggested Score:', style: AppTypography.bodySmall),
                        Text('${widget.record.score.toStringAsFixed(0)}%', style: AppTypography.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // AI Findings
              Text(
                'AI Identified Findings',
                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.record.findings.length,
                  separatorBuilder: (_, __) => const Divider(height: 12),
                  itemBuilder: (context, index) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_outline, color: AppColors.primary, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(widget.record.findings[index], style: AppTypography.bodySmall)),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Verify / Adjust score Slider
              Text(
                'Adjust Assessment Score',
                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              GlassCard(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Score:', style: AppTypography.bodyMedium),
                        Text(
                          '${_currentScore.toStringAsFixed(0)}%',
                          style: AppTypography.headlineMedium.copyWith(
                            color: AppColors.getScoreColor(_currentScore),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _currentScore,
                      min: 0,
                      max: 100,
                      divisions: 100,
                      activeColor: AppColors.getScoreColor(_currentScore),
                      onChanged: (val) {
                        setState(() {
                          _currentScore = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Verification Notes input
              Text(
                'Verification Notes',
                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Enter approval or rejection audit feedback here...',
                ),
              ),
              const SizedBox(height: 32),

              // Actions buttons
              if (_isSubmitting)
                const Center(child: CircularProgressIndicator())
              else ...[
                GradientButton(
                  text: 'Approve & Verify',
                  icon: Icons.check_circle_rounded,
                  onPressed: () => _submitVerification(CleaningStatus.verified),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _submitVerification(CleaningStatus.rejected),
                  icon: const Icon(Icons.cancel_rounded, color: AppColors.error),
                  label: const Text('Reject Submission', style: TextStyle(color: AppColors.error)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error, width: 1.5),
                  ),
                ),
              ],
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
