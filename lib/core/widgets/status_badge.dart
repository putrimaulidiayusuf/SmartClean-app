import 'package:flutter/material.dart';
import 'package:vibeco_app/core/constants/app_colors.dart';
import 'package:vibeco_app/core/constants/app_typography.dart';

enum BadgeType { success, warning, error, info, pending, verified }

class StatusBadge extends StatelessWidget {
  final String label;
  final BadgeType type;
  final IconData? icon;
  final double fontSize;

  const StatusBadge({
    super.key,
    required this.label,
    required this.type,
    this.icon,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: config.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null || config.defaultIcon != null) ...[
            Icon(
              icon ?? config.defaultIcon,
              size: 14,
              color: config.color,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: config.color,
              fontWeight: FontWeight.w600,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }

  _BadgeConfig _getConfig() {
    switch (type) {
      case BadgeType.success:
        return _BadgeConfig(AppColors.success, Icons.check_circle_rounded);
      case BadgeType.warning:
        return _BadgeConfig(AppColors.warning, Icons.warning_rounded);
      case BadgeType.error:
        return _BadgeConfig(AppColors.error, Icons.error_rounded);
      case BadgeType.info:
        return _BadgeConfig(AppColors.info, Icons.info_rounded);
      case BadgeType.pending:
        return _BadgeConfig(AppColors.warning, Icons.schedule_rounded);
      case BadgeType.verified:
        return _BadgeConfig(AppColors.primary, Icons.verified_rounded);
    }
  }
}

class _BadgeConfig {
  final Color color;
  final IconData? defaultIcon;

  _BadgeConfig(this.color, [this.defaultIcon]);
}
