import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'clock.dart';

/// Provider for the clock instance.
/// In production, use SystemClock. In tests, inject FakeClock.
final clockProvider = Provider<Clock>((ref) {
  throw UnimplementedError('clockProvider must be overridden in tests');
});

/// Provider for per-second ticks.
/// Only countdown widgets should listen to this.
final secondTickProvider = StreamProvider<DateTime>((ref) {
  final clock = ref.watch(clockProvider);
  return clock.tickStream(interval: const Duration(seconds: 1));
});

/// Provider for per-day ticks.
/// Grid and day-based calculations listen to this, NOT secondTickProvider.
final dayTickProvider = StreamProvider<DateTime>((ref) {
  final clock = ref.watch(clockProvider);
  return clock.tickStream(interval: const Duration(days: 1));
});

/// Provider for current instant (now).
/// Derived from clock, updated on second tick.
final nowProvider = Provider<DateTime>((ref) {
  ref.watch(secondTickProvider);
  return ref.read(clockProvider).now;
});

/// Provider for current date only (today).
/// Derived from clock, updated on day tick.
final todayProvider = Provider<DateTime>((ref) {
  ref.watch(dayTickProvider);
  return ref.read(clockProvider).today;
});

/// Provider for current date as a date-only value (no time component).
/// Use this for all date comparisons to avoid DST issues.
final dateOnlyProvider = Provider<DateTime>((ref) {
  final today = ref.watch(todayProvider);
  return DateTime(today.year, today.month, today.day);
});
