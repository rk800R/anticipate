import 'package:flutter/material.dart';

/// Event kind enumeration.
enum EventKind {
  once,      // One-time event
  yearly,    // Repeats yearly (anniversary)
  birthday,  // Birthday (yearly with age tracking)
}

/// Event color presets.
enum EventColor {
  amber(0xFFFFAB40),
  blue(0xFF4FC3F7),
  green(0xFF66BB6A),
  purple(0xFFBA68C8),
  red(0xFFEF5350),
  pink(0xFFEC407A),
  teal(0xFF26A69A),
  orange(0xFFFFA726);

  final int value;
  const EventColor(this.value);

  static EventColor fromValue(int value) {
    return EventColor.values.firstWhere(
      (c) => c.value == value,
      orElse: () => defaultColor,
    );
  }

  static const EventColor defaultColor = EventColor.amber;

  Color toColor() => Color(value);
}

/// Domain model for a calendar event.
class CalEvent {
  final String id;
  final String title;
  final DateTime date;
  final EventKind kind;
  final EventColor color;

  CalEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.kind,
    required this.color,
  });

  /// Check if this is a past event (for once events).
  bool get isPast => date.isBefore(DateTime.now());

  /// Get the color as a Material Color.
  Color get colorValue => color.toColor();
}

/// An upcoming occurrence of an event.
class UpcomingOccurrence {
  final CalEvent event;
  final DateTime? occurrenceDate; // null if no future occurrence
  final int daysUntil;

  UpcomingOccurrence({
    required this.event,
    required this.occurrenceDate,
    required this.daysUntil,
  });
}
