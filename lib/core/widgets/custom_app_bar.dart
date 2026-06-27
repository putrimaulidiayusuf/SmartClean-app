import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:vibeco_app/core/constants/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final bool transparent;
  final Widget? flexibleSpace;
  final double height;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = false,
    this.transparent = true,
    this.flexibleSpace,
    this.height = 64,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRect(
      child: BackdropFilter(
        filter: transparent
            ? ImageFilter.blur(sigmaX: 10, sigmaY: 10)
            : ImageFilter.blur(),
        child: AppBar(
          title: Text(title),
          leading: showBackButton
              ? IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                )
              : leading,
          actions: actions,
          backgroundColor: transparent
              ? (isDark
                  ? AppColors.backgroundDark.withValues(alpha: 0.8)
                  : AppColors.backgroundLight.withValues(alpha: 0.8))
              : null,
          flexibleSpace: flexibleSpace,
        ),
      ),
    );
  }
}
