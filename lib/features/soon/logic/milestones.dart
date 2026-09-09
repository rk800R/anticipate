import '../../events/domain/models.dart';
import '../../../core/format/app_formatters.dart';

/// A milestone to track for yearly/birthday events.
class Milestone {
  final String label;
  final CalEvent event;
  final DateTime date;
  final int daysUntil;

  Milestone({
    required this.label,
    required this.event,
    required this.date,
    required this.daysUntil,
  });
}

/// Pure functions for computing milestones from yearly/birthday events.
/// No stored state - all computed at read time.
class Milestones {
  Milestones._();

  /// Compute milestones for a list of yearly/birthday events.
  /// Returns milestones sorted by daysUntil.
  static List<Milestone> compute(List<CalEvent> events) {
    final now = DateTime.now();
    final today = DateTime.utc(now.year, now.month, now.day);
    final milestones = <Milestone>[];

    for (final event in events) {
      if (event.kind != EventKind.yearly && event.kind != EventKind.birthday) {
        continue;
      }

      // Calculate current age/year count based on original event date
      final originalYear = event.date.year;
      final currentAge = now.year - originalYear;

      // Round occurrences: multiples of 10 ("Turns 30", "10th anniversary")
      final nextMultipleOf10 = ((currentAge ~/ 10) + 1) * 10;
      final yearsUntilMultiple = nextMultipleOf10 - currentAge;
      
      if (yearsUntilMultiple > 0 && yearsUntilMultiple <= 10) {
        final milestoneYear = now.year + yearsUntilMultiple;
        final milestoneDate = DateTime.utc(
          milestoneYear,
          event.date.month,
          event.date.day,
        );
        
        if (milestoneDate.isAfter(today) || milestoneDate == today) {
          final daysUntil = milestoneDate.difference(today).inDays;
          final label = event.kind == EventKind.birthday
              ? 'Turns $nextMultipleOf10'
              : '${nextMultipleOf10}th anniversary';
          
          milestones.add(Milestone(
            label: label,
            event: event,
            date: milestoneDate,
            daysUntil: daysUntil,
          ));
        }
      }

      // Day-multiples since first occurrence (1000/5000/10000 days)
      final dayMultiples = [1000, 5000, 10000];
      final eventStartDate = DateTime.utc(
        originalYear,
        event.date.month,
        event.date.day,
      );
      
      for (final multiple in dayMultiples) {
        final targetDate = eventStartDate.add(Duration(days: multiple));
        final targetDateUtc = DateTime.utc(
          targetDate.year,
          targetDate.month,
          targetDate.day,
        );
        
        if (targetDateUtc.isAfter(today) || targetDateUtc == today) {
          final daysUntil = targetDateUtc.difference(today).inDays;
          final label = '${AppFormatters.compact(multiple)} days';
          
          milestones.add(Milestone(
            label: label,
            event: event,
            date: targetDateUtc,
            daysUntil: daysUntil,
          ));
        }
      }
    }

    // Sort by daysUntil
    milestones.sort((a, b) => a.daysUntil.compareTo(b.daysUntil));
    return milestones;
  }
}
