import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:vibeco_app/core/constants/app_colors.dart';
import 'package:vibeco_app/core/constants/app_typography.dart';

class ScoreIndicator extends StatelessWidget {
  final double score;
  final double size;
  final double lineWidth;
  final bool showLabel;
  final bool animate;

  const ScoreIndicator({
    super.key,
    required this.score,
    this.size = 120,
    this.lineWidth = 12,
    this.showLabel = true,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getScoreColor(score);

    return CircularPercentIndicator(
      radius: size / 2,
      lineWidth: lineWidth,
      percent: (score / 100).clamp(0.0, 1.0),
      center: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            score.toStringAsFixed(0),
            style: AppTypography.scoreMedium.copyWith(
              color: color,
              fontSize: size * 0.28,
            ),
          ),
          if (showLabel)
            Text(
              _getLabel(),
              style: AppTypography.labelSmall.copyWith(
                color: color.withValues(alpha: 0.8),
                fontSize: size * 0.09,
              ),
            ),
        ],
      ),
      progressColor: color,
      backgroundColor: color.withValues(alpha: 0.15),
      circularStrokeCap: CircularStrokeCap.round,
      animation: animate,
      animationDuration: 1200,
    );
  }

  String _getLabel() {
    if (score >= 90) return 'Excellent';
    if (score >= 75) return 'Good';
    if (score >= 60) return 'Average';
    return 'Needs Work';
  }
}

class ScoreBar extends StatelessWidget {
  final double score;
  final double height;
  final String? label;
  final bool showPercentage;

  const ScoreBar({
    super.key,
    required this.score,
    this.height = 8,
    this.label,
    this.showPercentage = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getScoreColor(score);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null || showPercentage)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (label != null)
                  Text(
                    label!,
                    style: AppTypography.bodySmall.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                if (showPercentage)
                  Text(
                    '${score.toStringAsFixed(0)}%',
                    style: AppTypography.labelMedium.copyWith(color: color),
                  ),
              ],
            ),
          ),
        LinearPercentIndicator(
          padding: EdgeInsets.zero,
          lineHeight: height,
          percent: (score / 100).clamp(0.0, 1.0),
          progressColor: color,
          backgroundColor: color.withValues(alpha: 0.15),
          barRadius: Radius.circular(height),
          animation: true,
          animationDuration: 1000,
        ),
      ],
    );
  }
}
