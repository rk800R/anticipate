import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/tokens/app_tokens.dart';
import '../../core/format/app_formatters.dart';
import '../events/domain/models.dart';

/// Year ring view showing events as dots around a circle.
class YearRing extends ConsumerWidget {
  final List<CalEvent> events;

  const YearRing({
    Key? key,
    required this.events,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(now.year + 1, 1, 1);
    final daysInYear = endOfYear.difference(startOfYear).inDays;
    final dayOfYear = now.difference(startOfYear).inDays + 1;
    final daysRemaining = daysInYear - dayOfYear;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 300,
            height: 300,
            child: CustomPaint(
              painter: YearRingPainter(
                events: events,
                today: now,
                daysInYear: daysInYear,
              ),
            ),
          ),
          const SizedBox(height: AppTokens.spacingLg),
          Text(
            '${AppFormatters.days(daysRemaining)} remaining',
            style: AppTokens.headlineMedium,
          ),
          Text(
            'Day $dayOfYear of $daysInYear',
            style: AppTokens.bodyMedium,
          ),
        ],
      ),
    );
  }
}

/// Custom painter for the year ring.
class YearRingPainter extends CustomPainter {
  final List<CalEvent> events;
  final DateTime today;
  final int daysInYear;

  YearRingPainter({
    required this.events,
    required this.today,
    required this.daysInYear,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 40; // Leave room for month labels

    // Draw ring background
    final ringPaint = Paint()
      ..color = AppTokens.backgroundSecondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, radius, ringPaint);

    // Draw month ticks and labels
    _drawMonthTicks(canvas, center, radius);

    // Draw event dots
    for (final event in events) {
      final eventDate = event.date;
      // Calculate day of year for event
      final startOfYear = DateTime(today.year, 1, 1);
      var dayOfYear = eventDate.difference(startOfYear).inDays + 1;
      
      // For yearly/birthday events in future years, use their occurrence this year
      if (event.kind != EventKind.once && eventDate.year > today.year) {
        dayOfYear = ((eventDate.month - 1) * 30 + eventDate.day) % daysInYear + 1;
      }
      
      // Clamp to valid range
      dayOfYear = ((dayOfYear - 1) % daysInYear + daysInYear) % daysInYear + 1;
      
      final angle = ((dayOfYear - 1) / daysInYear) * 2 * 3.14159 - 1.5708; // -π/2 to start at top
      final dotOffset = Offset(
        center.dx + radius * (angle.cos()),
        center.dy + radius * (angle.sin()),
      );

      // Calculate days until event for glow
      final eventThisYear = DateTime(today.year, eventDate.month, eventDate.day);
      final daysUntil = eventThisYear.difference(DateTime(today.year, today.month, today.day)).inDays;
      
      // Draw event dot with color
      final dotPaint = Paint()
        ..color = Color(event.colorValue)
        ..style = PaintingStyle.fill;
      
      // Glow radius based on proximity
      double glowRadius = 2;
      if (daysUntil >= 0) {
        if (daysUntil <= 7) {
          glowRadius = 8; // Imminent
        } else if (daysUntil <= 30) {
          glowRadius = 5; // Proximate
        }
      }
      
      // Draw glow
      if (glowRadius > 2) {
        final glowPaint = Paint()
          ..color = Color(event.colorValue).withOpacity(0.3)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(dotOffset, glowRadius, glowPaint);
      }
      
      canvas.drawCircle(dotOffset, 4, dotPaint);
    }

    // Draw today marker (accent color)
    final todayAngle = ((dayOfYear(today) - 1) / daysInYear) * 2 * 3.14159 - 1.5708;
    final todayOffset = Offset(
      center.dx + radius * (todayAngle.cos()),
      center.dy + radius * (todayAngle.sin()),
    );
    
    final todayPaint = Paint()
      ..color = AppTokens.accent
      ..style = PaintingStyle.fill;
    canvas.drawCircle(todayOffset, 6, todayPaint);
    
    // Today halo
    final todayHaloPaint = Paint()
      ..color = AppTokens.todayPulse.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(todayOffset, 10, todayHaloPaint);
  }

  int dayOfYear(DateTime dt) {
    final startOfYear = DateTime(dt.year, 1, 1);
    return dt.difference(startOfYear).inDays + 1;
  }

  void _drawMonthTicks(Canvas canvas, Offset center, double radius) {
    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    for (int i = 0; i < 12; i++) {
      final angle = (i / 12) * 2 * 3.14159 - 1.5708;
      final tickOuter = Offset(
        center.dx + (radius + 15) * (angle.cos()),
        center.dy + (radius + 15) * (angle.sin()),
      );
      
      // Draw tick
      final tickPaint = Paint()
        ..color = AppTokens.textSecondary.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawLine(
        Offset(
          center.dx + (radius + 5) * (angle.cos()),
          center.dy + (radius + 5) * (angle.sin()),
        ),
        tickOuter,
        tickPaint,
      );
      
      // Draw month label
      final textPainter = TextPainter(
        text: TextSpan(
          text: monthNames[i],
          style: TextStyle(
            fontSize: 10,
            color: AppTokens.textSecondary,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          center.dx + (radius + 25) * (angle.cos()) - textPainter.width / 2,
          center.dy + (radius + 25) * (angle.sin()) - textPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant YearRingPainter oldDelegate) {
    return oldDelegate.events != events || oldDelegate.today != today;
  }
}

// Extension for cosine/sine on doubles
extension on double {
  double cos() => this;
  double sin() => this;
}
