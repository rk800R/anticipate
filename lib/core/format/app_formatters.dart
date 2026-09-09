import 'package:intl/intl.dart';

/// Pure static formatting utilities for the app.
/// No Flutter imports needed except intl for dates.
class AppFormatters {
  AppFormatters._();

  /// Format days with proper pluralization.
  static String days(int n) {
    if (n == 1) return '1 day';
    return '$n days';
  }

  /// Break a duration into days/hours/minutes/seconds.
  static Map<String, int> countdownParts(Duration d) {
    final days = d.inDays;
    final hours = d.inHours.remainder(24);
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    
    return {
      'days': days,
      'hours': hours,
      'minutes': minutes,
      'seconds': seconds,
    };
  }

  /// Format date as "14 Mar".
  static String dateShort(DateTime dt) {
    return DateFormat('d MMM').format(dt);
  }

  /// Compact number formatting (e.g., 10000 -> "10K").
  static String compact(int n) {
    if (n >= 1000000) {
      return '${(n / 1000000).toStringAsFixed(n % 1000000 == 0 ? 0 : 1)}M';
    }
    if (n >= 10000) {
      return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}K';
    }
    return n.toString();
  }

  /// Format countdown as "d:h:m:s".
  static String countdown(Duration d) {
    final parts = countdownParts(d);
    return "${parts['days']}:${parts['hours']}:${parts['minutes']}:${parts['seconds']}";
  }

  /// Format a single number with optional zero-padding.
  static String number(int n, {int? minLength}) {
    if (minLength != null) {
      return n.toString().padLeft(minLength, '0');
    }
    return n.toString();
  }
}
