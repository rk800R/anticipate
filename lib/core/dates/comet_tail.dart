import '../tokens/app_tokens.dart';

/// Pure date logic utilities.
extension DateTimeExtension on DateTime {
  /// Get date-only DateTime (midnight UTC).
  DateTime get dateOnly => DateTime.utc(year, month, day);

  /// Get weekday with Monday=0, Sunday=6.
  int get weekdayMon0 => (weekday - 1) % 7;

  /// Days before another date (UTC-safe).
  int daysBefore(DateTime other) {
    final thisDate = dateOnly;
    final otherDate = other.dateOnly;
    return otherDate.difference(thisDate).inDays;
  }

  /// Leading pad for display.
  String get leadingPad => day < 10 ? '0$day' : '$day';
}

/// Calculate comet tail opacity based on days ago.
/// ≤0 → 1.0, else 0.15 floor + (1-0.15)*(1 - min(daysAgo/7, 1))
double cometTailOpacity(int daysAgo) {
  if (daysAgo <= 0) return 1.0;
  
  final floor = AppTokens.fadeFloor;
  final reach = AppTokens.trailReachDays;
  final ratio = (daysAgo / reach).clamp(0.0, 1.0);
  
  return floor + (1.0 - floor) * (1.0 - ratio);
}
