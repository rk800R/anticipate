/// Clock abstraction for SOON.
/// 
/// D1: Two clocks, one source of truth.
/// The entire app renders from two streams: per-second tick and per-day tick.
/// No widget, service, or calculation reads system time directly.

import 'dart:async';

/// Abstract clock interface - the only way to get time in SOON.
abstract class Clock {
  /// Current instant (for countdowns, per-second updates)
  DateTime get now;
  
  /// Current date only (for grid, day-based calculations)
  DateTime get today;
  
  /// Stream of ticks at the specified interval
  Stream<DateTime> tickStream({Duration interval = const Duration(seconds: 1)});
  
  /// Dispose of any resources
  void dispose();
}

/// System clock implementation - reads actual system time.
class SystemClock implements Clock {
  final StreamController<DateTime> _secondController = StreamController<DateTime>.broadcast();
  final StreamController<DateTime> _dayController = StreamController<DateTime>.broadcast();
  Timer? _secondTimer;
  Timer? _dayTimer;
  
  SystemClock() {
    _startTimers();
  }
  
  void _startTimers() {
    // Per-second timer
    _secondTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_secondController.isClosed) {
        _secondController.add(DateTime.now());
      }
    });
    
    // Per-day timer - fires at midnight
    _scheduleDayTimer();
  }
  
  void _scheduleDayTimer() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final delay = tomorrow.difference(now);
    
    _dayTimer = Timer(delay, () {
      if (!_dayController.isClosed) {
        _dayController.add(DateTime.now());
        _scheduleDayTimer(); // Schedule next day
      }
    });
  }
  
  @override
  DateTime get now => DateTime.now();
  
  @override
  DateTime get today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
  
  @override
  Stream<DateTime> tickStream({Duration interval = const Duration(seconds: 1)}) {
    if (interval.inMilliseconds < 1000) {
      return _secondController.stream;
    } else if (interval.inHours >= 24) {
      return _dayController.stream;
    }
    throw ArgumentError('Unsupported interval: $interval');
  }
  
  @override
  void dispose() {
    _secondTimer?.cancel();
    _dayTimer?.cancel();
    _secondController.close();
    _dayController.close();
  }
}

/// Fake clock for testing - time can be advanced manually.
/// Enables deterministic testing of midnight rollover, DST boundaries, etc.
class FakeClock implements Clock {
  DateTime _now;
  final StreamController<DateTime> _tickController = StreamController<DateTime>.broadcast();
  
  FakeClock({required DateTime startTime}) : _now = startTime;
  
  /// Advance time by the given duration
  void advance(Duration duration) {
    _now = _now.add(duration);
    if (!_tickController.isClosed) {
      _tickController.add(_now);
    }
  }
  
  /// Advance to a specific datetime
  void setTo(DateTime newTime) {
    _now = newTime;
    if (!_tickController.isClosed) {
      _tickController.add(_now);
    }
  }
  
  /// Advance to just before midnight, then cross it
  void crossMidnight() {
    final currentDayEnd = DateTime(_now.year, _now.month, _now.day + 1);
    _now = currentDayEnd;
    if (!_tickController.isClosed) {
      _tickController.add(_now);
    }
  }
  
  @override
  DateTime get now => _now;
  
  @override
  DateTime get today => DateTime(_now.year, _now.month, _now.day);
  
  @override
  Stream<DateTime> tickStream({Duration interval = const Duration(seconds: 1)}) {
    return _tickController.stream;
  }
  
  @override
  void dispose() {
    _tickController.close();
  }
}
