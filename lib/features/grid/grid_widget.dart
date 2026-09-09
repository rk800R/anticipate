import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/dates/comet_tail.dart';
import '../../core/tokens/app_tokens.dart';
import '../events/domain/models.dart';
import 'dot_state.dart';
import 'dot_painter.dart';

/// Provider for today's date (day tick only, not second tick).
final todayProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime.utc(now.year, now.month, now.day);
});

/// Month grid widget with Monday-first layout.
class GridWidget extends ConsumerStatefulWidget {
  final DateTime monthStart;
  final List<CalEvent> events;
  final Function(DateTime)? onDaySelected;

  const GridWidget({
    Key? key,
    required this.monthStart,
    required this.events,
    this.onDaySelected,
  }) : super(key: key);

  @override
  ConsumerState<GridWidget> createState() => _GridWidgetState();
}

class _GridWidgetState extends ConsumerState<GridWidget> {
  DateTime? _selectedDate;
  late DateTime _today;
  late List<DateTime> _gridDays;

  @override
  void initState() {
    super.initState();
    _today = ref.read(todayProvider);
    _gridDays = _generateGridDays();
  }

  @override
  void didUpdateWidget(GridWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.monthStart != oldWidget.monthStart) {
      setState(() {
        _gridDays = _generateGridDays();
      });
    }
  }

  List<DateTime> _generateGridDays() {
    final days = <DateTime>[];
    
    // First day of month
    final firstDay = DateTime(widget.monthStart.year, widget.monthStart.month, 1);
    
    // Leading blanks to start on Monday (weekdayMon0)
    final leadingBlanks = firstDay.weekdayMon0;
    for (int i = 0; i < leadingBlanks; i++) {
      days.add(firstDay.subtract(Duration(days: leadingBlanks - i)));
    }
    
    // All days of the month
    var current = firstDay;
    while (current.month == widget.monthStart.month) {
      days.add(current);
      current = current.add(const Duration(days: 1));
    }
    
    // Trailing blanks to complete 6 rows (42 cells total)
    while (days.length < 42) {
      days.add(current);
      current = current.add(const Duration(days: 1));
    }
    
    return days;
  }

  void _handleDayTap(DateTime day) {
    setState(() {
      _selectedDate = day;
    });
    widget.onDaySelected?.call(day);
  }

  @override
  Widget build(BuildContext context) {
    // Watch today provider for day changes
    final today = ref.watch(todayProvider);
    if (today != _today) {
      _today = today;
      // Staggered refresh based on grid distance from today
      _staggeredRefresh();
    }

    return Container(
      padding: const EdgeInsets.all(AppTokens.spacingMd),
      child: Column(
        children: [
          // Weekday headers (Mon-Sun)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .map((d) => SizedBox(
                      width: AppTokens.dotSize + AppTokens.dotSpacing * 2,
                      child: Text(
                        d,
                        textAlign: TextAlign.center,
                        style: AppTokens.bodyMedium.copyWith(
                          fontSize: 10,
                          color: AppTokens.textSecondary,
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: AppTokens.spacingSm),
          // Grid
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: AppTokens.dotSpacing,
                crossAxisSpacing: AppTokens.dotSpacing,
              ),
              itemCount: _gridDays.length,
              itemBuilder: (context, index) {
                final day = _gridDays[index];
                final isCurrentMonth = day.month == widget.monthStart.month;
                final eventsOnDay = widget.events
                    .where((e) =>
                        e.date.year == day.year &&
                        e.date.month == day.month &&
                        e.date.day == day.day)
                    .toList();

                final state = resolveDotState(
                  day: day,
                  today: today,
                  eventsOnDay: eventsOnDay,
                );

                // Calculate opacity for past days
                double opacity = 1.0;
                if (state == DotState.past) {
                  final daysAgo = today.difference(day).inDays;
                  opacity = cometTailOpacity(daysAgo);
                }

                final isSelected = _selectedDate != null &&
                    _selectedDate!.year == day.year &&
                    _selectedDate!.month == day.month &&
                    _selectedDate!.day == day.day;

                final eventColor = eventsOnDay.isNotEmpty
                    ? eventsOnDay.first.colorValue
                    : null;

                return Semantics(
                  label: _buildSemanticsLabel(day, eventsOnDay, today),
                  key: ValueKey('dot_${day.toIso8601String().split('T')[0]}'),
                  button: true,
                  child: GestureDetector(
                    onTap: () => _handleDayTap(day),
                    child: Opacity(
                      opacity: isCurrentMonth ? opacity : 0.3,
                      child: CustomPaint(
                        painter: DotPainter(
                          state: state,
                          eventColor: eventColor,
                          isSelected: isSelected,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _buildSemanticsLabel(DateTime day, List<CalEvent> events, DateTime today) {
    final daysDiff = day.difference(today).inDays;
    String timeRelation;
    if (daysDiff == 0) {
      timeRelation = 'today';
    } else if (daysDiff == 1) {
      timeRelation = 'tomorrow';
    } else if (daysDiff == -1) {
      timeRelation = 'yesterday';
    } else if (daysDiff > 0) {
      timeRelation = 'in ${daysDiff} days';
    } else {
      timeRelation = '${-daysDiff} days ago';
    }

    if (events.isEmpty) {
      return '$timeRelation';
    }

    final eventNames = events.map((e) => e.title).join(', ');
    return '$eventNames, $timeRelation';
  }

  void _staggeredRefresh() {
    // Find today's position in grid
    final todayIndex = _gridDays.indexWhere(
      (d) =>
          d.year == _today.year && d.month == _today.month && d.day == _today.day,
    );

    if (todayIndex == -1) return;

    // Staggered refresh: 40ms × grid distance from today, capped at 2000ms
    for (int i = 0; i < _gridDays.length; i++) {
      final distance = (i - todayIndex).abs();
      final delay = (40 * distance).clamp(0, 2000);
      
      Future.delayed(Duration(milliseconds: delay), () {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }
}
