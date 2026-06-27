import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Context extensions
extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  EdgeInsets get padding => MediaQuery.of(this).padding;

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade400 : Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

// String extensions
extension StringExtensions on String {
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  String get titleCase {
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  String get initials {
    final parts = trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}

// DateTime extensions
extension DateTimeExtensions on DateTime {
  String get formatted => DateFormat('dd MMM yyyy').format(this);
  String get formattedTime => DateFormat('HH:mm').format(this);
  String get formattedFull => DateFormat('dd MMM yyyy, HH:mm').format(this);
  String get dayName => DateFormat('EEEE').format(this);
  String get shortDay => DateFormat('EEE').format(this);
  String get monthYear => DateFormat('MMMM yyyy').format(this);

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  String get relative {
    if (isToday) return 'Today';
    if (isYesterday) return 'Yesterday';
    return formatted;
  }

  int get weekdayIndex {
    // Monday = 0, Tuesday = 1, ... Friday = 4
    return weekday - 1;
  }
}

// Num extensions
extension NumExtensions on num {
  String get scoreLabel {
    if (this >= 90) return 'Excellent';
    if (this >= 75) return 'Good';
    if (this >= 60) return 'Average';
    return 'Needs Improvement';
  }
}
