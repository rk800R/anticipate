import 'dart:async';
import '../../events/domain/models.dart';

/// Abstract interface for scheduling alarms/notifications.
abstract class AlarmScheduler {
  /// Schedule reminder rungs for an event.
  Future<void> scheduleRungs(CalEvent event);

  /// Cancel all alarms for an event.
  Future<void> cancelAll(String eventId);
}

/// No-op implementation for development/testing.
class FakeAlarmScheduler implements AlarmScheduler {
  @override
  Future<void> scheduleRungs(CalEvent event) async {
    // No-op: fake scheduler does nothing
  }

  @override
  Future<void> cancelAll(String eventId) async {
    // No-op: fake scheduler does nothing
  }
}
