import 'package:flutter_test/flutter_test.dart';
import 'package:soon/core/clock/clock.dart';

void main() {
  group('FakeClock', () {
    test('initializes with provided start time', () {
      final startTime = DateTime(2024, 1, 15, 10, 30, 0);
      final clock = FakeClock(startTime: startTime);
      
      expect(clock.now, equals(startTime));
      expect(clock.today, equals(DateTime(2024, 1, 15)));
      
      clock.dispose();
    });

    test('advance moves time forward by duration', () {
      final clock = FakeClock(startTime: DateTime(2024, 1, 15, 10, 0, 0));
      
      clock.advance(const Duration(hours: 2, minutes: 30));
      
      expect(clock.now, equals(DateTime(2024, 1, 15, 12, 30, 0)));
      
      clock.dispose();
    });

    test('setTo moves time to specific datetime', () {
      final clock = FakeClock(startTime: DateTime(2024, 1, 15, 10, 0, 0));
      final newTime = DateTime(2024, 6, 20, 18, 45, 30);
      
      clock.setTo(newTime);
      
      expect(clock.now, equals(newTime));
      expect(clock.today, equals(DateTime(2024, 6, 20)));
      
      clock.dispose();
    });

    test('crossMidnight advances to next day boundary', () {
      final clock = FakeClock(startTime: DateTime(2024, 1, 15, 14, 30, 0));
      
      clock.crossMidnight();
      
      expect(clock.today, equals(DateTime(2024, 1, 16)));
      expect(clock.now.hour, equals(0));
      expect(clock.now.minute, equals(0));
      
      clock.dispose();
    });

    test('today returns date-only value', () {
      final clock = FakeClock(startTime: DateTime(2024, 3, 20, 15, 45, 30, 123));
      
      final today = clock.today;
      
      expect(today.year, equals(2024));
      expect(today.month, equals(3));
      expect(today.day, equals(20));
      expect(today.hour, equals(0));
      expect(today.minute, equals(0));
      expect(today.second, equals(0));
      expect(today.millisecond, equals(0));
      
      clock.dispose();
    });

    test('tickStream emits on advance', () async {
      final clock = FakeClock(startTime: DateTime(2024, 1, 15, 10, 0, 0));
      final emittedTimes = <DateTime>[];
      
      final subscription = clock.tickStream().listen(emittedTimes.add);
      
      clock.advance(const Duration(seconds: 1));
      clock.advance(const Duration(seconds: 1));
      clock.advance(const Duration(seconds: 1));
      
      await Future.delayed(const Duration(milliseconds: 50));
      
      expect(emittedTimes.length, equals(3));
      expect(emittedTimes[0], equals(DateTime(2024, 1, 15, 10, 0, 1)));
      expect(emittedTimes[1], equals(DateTime(2024, 1, 15, 10, 0, 2)));
      expect(emittedTimes[2], equals(DateTime(2024, 1, 15, 10, 0, 3)));
      
      await subscription.cancel();
      clock.dispose();
    });
  });

  group('SystemClock', () {
    test('now returns current system time', () {
      final before = DateTime.now();
      final clock = SystemClock();
      final now = clock.now;
      final after = DateTime.now();
      
      expect(now.isAfter(before) || now.isAtSameMomentAs(before), true);
      expect(now.isBefore(after) || now.isAtSameMomentAs(after), true);
      
      clock.dispose();
    });

    test('today returns date-only for current day', () {
      final clock = SystemClock();
      final today = clock.today;
      final now = DateTime.now();
      
      expect(today.year, equals(now.year));
      expect(today.month, equals(now.month));
      expect(today.day, equals(now.day));
      expect(today.hour, equals(0));
      expect(today.minute, equals(0));
      expect(today.second, equals(0));
      
      clock.dispose();
    });
  });

  group('Midnight Rollover Proof', () {
    test('crossing midnight updates today correctly', () {
      // Start just before midnight
      final clock = FakeClock(startTime: DateTime(2024, 12, 31, 23, 59, 59));
      
      final beforeToday = clock.today;
      expect(beforeToday, equals(DateTime(2024, 12, 31)));
      expect(beforeToday.year, equals(2024));
      
      // Cross midnight into new year
      clock.crossMidnight();
      
      final afterToday = clock.today;
      expect(afterToday, equals(DateTime(2025, 1, 1)));
      expect(afterToday.year, equals(2025));
      expect(afterToday.month, equals(1));
      expect(afterToday.day, equals(1));
      
      clock.dispose();
    });

    test('multiple day crossings work correctly', () {
      final clock = FakeClock(startTime: DateTime(2024, 1, 1, 12, 0, 0));
      
      expect(clock.today, equals(DateTime(2024, 1, 1)));
      
      clock.crossMidnight();
      expect(clock.today, equals(DateTime(2024, 1, 2)));
      
      clock.crossMidnight();
      expect(clock.today, equals(DateTime(2024, 1, 3)));
      
      clock.crossMidnight();
      expect(clock.today, equals(DateTime(2024, 1, 4)));
      
      clock.dispose();
    });

    test('DST boundary simulation (spring forward)', () {
      // Simulate DST spring forward: March 10, 2024 at 2:00 AM -> 3:00 AM
      // We use UTC-based calculations so DST is irrelevant
      final clock = FakeClock(startTime: DateTime(2024, 3, 10, 1, 30, 0));
      
      // Advance through DST boundary using date arithmetic
      clock.advance(const Duration(hours: 3)); // Would skip 2:00-3:00 in local time
      
      // Date-only comparison works regardless of DST
      expect(clock.today, equals(DateTime(2024, 3, 10)));
      
      clock.crossMidnight();
      expect(clock.today, equals(DateTime(2024, 3, 11)));
      
      clock.dispose();
    });

    test('year rollover works correctly', () {
      final clock = FakeClock(startTime: DateTime(2024, 12, 30, 12, 0, 0));
      
      clock.crossMidnight(); // Dec 31
      expect(clock.today, equals(DateTime(2024, 12, 31)));
      
      clock.crossMidnight(); // Jan 1, 2025
      expect(clock.today, equals(DateTime(2025, 1, 1)));
      expect(clock.today.year, equals(2025));
      
      clock.dispose();
    });
  });
}
