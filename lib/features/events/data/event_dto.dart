import 'package:hive/hive.dart';
import '../domain/models.dart';

/// Hive DTO for CalEvent with schema versioning support.
class EventDto {
  final String id;
  final String title;
  final int dateMillis;
  final int kindIndex;
  final int colorValue;
  final int schemaVersion;

  EventDto({
    required this.id,
    required this.title,
    required this.dateMillis,
    required this.kindIndex,
    required this.colorValue,
    required this.schemaVersion,
  });

  /// Convert from domain model to DTO.
  factory EventDto.fromModel(CalEvent event) {
    return EventDto(
      id: event.id,
      title: event.title,
      dateMillis: event.date.millisecondsSinceEpoch,
      kindIndex: event.kind.index,
      colorValue: event.color.value,
      schemaVersion: 1,
    );
  }

  /// Convert from DTO to domain model.
  CalEvent toModel() {
    return CalEvent(
      id: id,
      title: title,
      date: DateTime.fromMillisecondsSinceEpoch(dateMillis),
      kind: EventKind.values[kindIndex],
      color: EventColor.fromValue(colorValue),
    );
  }

  /// Migrate raw map data to current schema version.
  static Map<String, dynamic> migrate(Map<dynamic, dynamic> raw) {
    final result = <String, dynamic>{};
    
    // Copy all fields preserving unknown ones
    for (final entry in raw.entries) {
      result[entry.key.toString()] = entry.value;
    }

    // Check if schemaVersion is missing (v0)
    if (!result.containsKey('schemaVersion')) {
      // v0 -> v1 migration: apply defaults
      result['schemaVersion'] = 1;
      
      // Ensure required fields have defaults
      result['title'] ??= 'Untitled';
      result['kindIndex'] ??= 0;
      result['colorValue'] ??= EventColor.defaultColor.value;
    }

    return result;
  }
}

// HiveAdapter registration (run at app startup):
// void registerAdapters() {
//   Hive.registerAdapter(EventDtoAdapter());
// }
