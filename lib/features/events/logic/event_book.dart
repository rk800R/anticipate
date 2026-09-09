import 'dart:async';
import '../domain/models.dart';
import 'event_repository.dart';
import '../../anticipate/data/alarm_scheduler.dart';

/// Idempotency key cache to prevent duplicate operations.
class _IdempotencyCache {
  final Set<String> _keys = {};
  
  bool tryAdd(String key) {
    if (_keys.contains(key)) return false;
    _keys.add(key);
    return true;
  }
  
  void clear() => _keys.clear();
}

/// The mutation door for event operations.
/// Handles validation, repository writes, alarm hooks, and logging.
class EventBook {
  final EventRepository _repository;
  final AlarmScheduler _alarmScheduler;
  final _IdempotencyCache _cache = _IdempotencyCache();

  EventBook(this._repository, this._alarmScheduler);

  /// Validate an event before saving.
  static String? validate(CalEvent event) {
    if (event.title.trim().isEmpty) {
      return 'Title cannot be empty';
    }
    // Date sanity check: not too far in past (> 100 years)
    final now = DateTime.now();
    final hundredYearsAgo = DateTime(now.year - 100);
    if (event.date.isBefore(hundredYearsAgo)) {
      return 'Date is too far in the past';
    }
    return null;
  }

  /// Add an event with idempotency protection.
  Future<bool> add(CalEvent e, String idempotencyKey) async {
    // Check idempotency
    if (!_cache.tryAdd(idempotencyKey)) {
      return false; // Duplicate key, no-op
    }

    // Validate
    final error = validate(e);
    if (error != null) {
      throw ArgumentError(error);
    }

    // Repository write
    await _repository.save(e);

    // Alarm hook
    await _alarmScheduler.scheduleRungs(e);

    // Log
    print('[EventBook] Added event: ${e.id} - ${e.title}');
    
    return true;
  }

  /// Edit an event with idempotency protection.
  Future<bool> edit(CalEvent e, String idempotencyKey) async {
    // Check idempotency
    if (!_cache.tryAdd(idempotencyKey)) {
      return false; // Duplicate key, no-op
    }

    // Validate
    final error = validate(e);
    if (error != null) {
      throw ArgumentError(error);
    }

    // Cancel existing alarms
    await _alarmScheduler.cancelAll(e.id);

    // Repository write
    await _repository.save(e);

    // Schedule new alarms
    await _alarmScheduler.scheduleRungs(e);

    // Log
    print('[EventBook] Edited event: ${e.id} - ${e.title}');
    
    return true;
  }

  /// Remove an event by ID.
  Future<void> remove(String id) async {
    // Cancel alarms first
    await _alarmScheduler.cancelAll(id);

    // Repository delete
    await _repository.delete(id);

    // Log
    print('[EventBook] Removed event: $id');
  }

  /// Import multiple events atomically (for holidays).
  /// Idempotency key = "holiday_<title>_<mm-dd>" so re-import never duplicates.
  Future<bool> import(List<CalEvent> events) async {
    if (events.isEmpty) return false;

    for (final event in events) {
      final idempotencyKey = 'holiday_${event.title}_${event.date.month.toString().padLeft(2, '0')}-${event.date.day.toString().padLeft(2, '0')}';
      
      // Check idempotency
      if (!_cache.tryAdd(idempotencyKey)) {
        continue; // Skip duplicate
      }

      // Validate
      final error = validate(event);
      if (error != null) {
        continue; // Skip invalid events
      }

      // Repository write
      await _repository.save(event);
    }

    print('[EventBook] Imported ${events.length} events');
    return true;
  }

  /// Compute upcoming occurrences for all events.
  List<UpcomingOccurrence> nextOccurrences(List<CalEvent> events) {
    final now = DateTime.now();
    final today = DateTime.utc(now.year, now.month, now.day);
    
    return events.map((event) {
      DateTime? occurrenceDate;
      int daysUntil;

      switch (event.kind) {
        case EventKind.once:
          // Once events: use stored date if future, else null
          final eventDate = DateTime.utc(event.date.year, event.date.month, event.date.day);
          if (eventDate.isAfter(today) || eventDate == today) {
            occurrenceDate = event.date;
            daysUntil = eventDate.difference(today).inDays;
          } else {
            occurrenceDate = null;
            daysUntil = -today.difference(eventDate).inDays; // Negative for "days since"
          }
          break;

        case EventKind.yearly:
        case EventKind.birthday:
          // Yearly/birthday: find next future occurrence
          var nextYear = now.year;
          var candidate = DateTime.utc(nextYear, event.date.month, event.date.day);
          
          if (candidate.isBefore(today)) {
            nextYear++;
            candidate = DateTime.utc(nextYear, event.date.month, event.date.day);
          }
          
          occurrenceDate = candidate;
          daysUntil = candidate.difference(today).inDays;
          break;
      }

      return UpcomingOccurrence(
        event: event,
        occurrenceDate: occurrenceDate,
        daysUntil: daysUntil,
      );
    })
    .where((occ) => occ.occurrenceDate != null || occ.daysUntil < 0) // Include past once-events
    .toList()
    ..sort((a, b) => a.daysUntil.compareTo(b.daysUntil));
  }
}
