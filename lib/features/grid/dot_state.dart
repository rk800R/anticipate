import '../../events/domain/models.dart';

/// Dot state enumeration for grid rendering.
enum DotState {
  past,
  today,
  future,
  eventDistant,
  eventProximate,
  eventImminent,
  eventDayOf,
}

/// Pure resolver for dot state based on day, today, and events.
/// Uses daysUntil: >30 distant, 8–30 proximate, 1–7 imminent, 0 day-of.
/// Past wins over event states; today+event composes at paint time.
DotState resolveDotState({
  required DateTime day,
  required DateTime today,
  required List<CalEvent> eventsOnDay,
}) {
  final dayDate = day.dateOnly;
  final todayDate = today.dateOnly;
  final daysDiff = dayDate.difference(todayDate).inDays;

  // Check if this is today
  final isToday = daysDiff == 0;

  // Check if this is in the past
  final isPast = daysDiff < 0;

  // If no events, simple state
  if (eventsOnDay.isEmpty) {
    if (isToday) return DotState.today;
    if (isPast) return DotState.past;
    return DotState.future;
  }

  // Has events - determine by daysUntil
  if (isToday) return DotState.eventDayOf;

  // For future days with events, check proximity
  if (daysDiff <= 7 && daysDiff >= 1) {
    return DotState.eventImminent;
  } else if (daysDiff >= 8 && daysDiff <= 30) {
    return DotState.eventProximate;
  } else if (daysDiff > 30) {
    return DotState.eventDistant;
  }

  // Past days with events still show as past (past wins)
  return DotState.past;
}

/// Extension to get dateOnly from DateTime.
extension on DateTime {
  DateTime get dateOnly => DateTime.utc(year, month, day);
}
