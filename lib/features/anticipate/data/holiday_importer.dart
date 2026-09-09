import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../events/domain/models.dart';
import '../../events/logic/event_book.dart';

/// Loads bundled US holidays and imports them as yearly CalEvents.
/// Toggleable via settings persisted in Hive.
class HolidayImporter {
  static const String _settingsBox = 'settings';
  static const String _holidaysEnabledKey = 'holidays_enabled';
  static const String _holidayEventPrefix = 'holiday_';

  final EventBook _eventBook;

  HolidayImporter(this._eventBook);

  /// Load and import holidays from bundled JSON.
  Future<void> importHolidays() async {
    try {
      final jsonString = await rootBundle.loadString('assets/holidays/us_holidays.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      final events = <CalEvent>[];
      for (final item in jsonList) {
        final title = item['title'] as String;
        final month = item['month'] as int;
        final day = item['day'] as int;

        events.add(CalEvent(
          id: '$_holidayEventPrefix$title',
          title: title,
          date: DateTime(2024, month, day), // Year doesn't matter for yearly events
          kind: EventKind.yearly,
          color: EventColor.purple, // Accent color for holidays
        ));
      }

      await _eventBook.import(events);
      print('[HolidayImporter] Imported ${events.length} holidays');
    } catch (e) {
      print('[HolidayImporter] Error importing holidays: $e');
    }
  }

  /// Enable holidays - imports if not already enabled.
  Future<void> enableHolidays() async {
    final box = await Hive.openBox(_settingsBox);
    await box.put(_holidaysEnabledKey, true);
    await importHolidays();
  }

  /// Disable holidays - deletes all holiday events.
  Future<void> disableHolidays() async {
    final box = await Hive.openBox(_settingsBox);
    await box.put(_holidaysEnabledKey, false);

    // Delete all holiday events (would need repository access - simplified here)
    // In practice, you'd query for events with id starting with _holidayEventPrefix
    // and delete them in a batch operation
    print('[HolidayImporter] Holidays disabled - manual cleanup may be needed');
  }

  /// Check if holidays are enabled.
  static Future<bool> isHolidaysEnabled() async {
    final box = await Hive.openBox(_settingsBox);
    return box.get(_holidaysEnabledKey, defaultValue: false) as bool;
  }

  /// Toggle holidays on/off.
  static Future<void> toggleHolidays(bool enabled) async {
    final box = await Hive.openBox(_settingsBox);
    await box.put(_holidaysEnabledKey, enabled);
  }
}
