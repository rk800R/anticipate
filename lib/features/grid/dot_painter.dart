import 'package:flutter/material.dart';
import '../../core/tokens/app_tokens.dart';
import '../../core/dates/comet_tail.dart';
import 'dot_state.dart';

/// CustomPainter for one month grid dots.
/// Four layers per dot in order: opacity multiplier (cometTail) → fill → halo/ring → overlay.
class DotPainter extends CustomPainter {
  final DotState state;
  final Color? eventColor;
  final bool isSelected;
  final double size;

  DotPainter({
    required this.state,
    this.eventColor,
    this.isSelected = false,
    this.size = AppTokens.dotSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = this.size / 2;

    // Calculate opacity multiplier from comet tail
    double opacityMultiplier = 1.0;
    if (state == DotState.past) {
      // For past days, we need daysAgo - pass as negative daysDiff
      opacityMultiplier = cometTailOpacity(0); // Will be overridden by caller
    }

    switch (state) {
      case DotState.past:
        _drawPast(canvas, center, baseRadius, opacityMultiplier);
        break;
      case DotState.today:
        _drawToday(canvas, center, baseRadius);
        break;
      case DotState.future:
        _drawFuture(canvas, center, baseRadius);
        break;
      case DotState.eventDistant:
        _drawEventDistant(canvas, center, baseRadius);
        break;
      case DotState.eventProximate:
        _drawEventProximate(canvas, center, baseRadius);
        break;
      case DotState.eventImminent:
        _drawEventImminent(canvas, center, baseRadius);
        break;
      case DotState.eventDayOf:
        _drawEventDayOf(canvas, center, baseRadius);
        break;
    }

    // Selected overlay
    if (isSelected) {
      _drawSelected(canvas, center, baseRadius);
    }
  }

  void _drawPast(Canvas canvas, Offset center, double radius, double opacity) {
    final paint = Paint()
      ..color = AppTokens.pastDay.withOpacity(opacity * AppTokens.fadeFloor)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, paint);
  }

  void _drawToday(Canvas canvas, Offset center, double radius) {
    // Fill
    final fillPaint = Paint()
      ..color = AppTokens.todayPulse
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, fillPaint);

    // Halo/ring
    final haloPaint = Paint()
      ..color = AppTokens.accent.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius + 8, haloPaint);
  }

  void _drawFuture(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = AppTokens.futureDay
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, paint);
  }

  void _drawEventDistant(Canvas canvas, Offset center, double radius) {
    // Event color dot
    final dotPaint = Paint()
      ..color = eventColor ?? AppTokens.eventDot
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, dotPaint);

    // 1px ring
    final ringPaint = Paint()
      ..color = (eventColor ?? AppTokens.eventDot).withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius + 1, ringPaint);
  }

  void _drawEventProximate(Canvas canvas, Offset center, double radius) {
    // Lerp size 4→6
    final lerpedRadius = radius * 1.25;
    
    final dotPaint = Paint()
      ..color = eventColor ?? AppTokens.eventDot
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, lerpedRadius, dotPaint);

    // Ring 1→2
    final ringPaint = Paint()
      ..color = (eventColor ?? AppTokens.eventDot).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, lerpedRadius + 1.5, ringPaint);
  }

  void _drawEventImminent(Canvas canvas, Offset center, double radius) {
    // Full size
    final lerpedRadius = radius * 1.5;
    
    final dotPaint = Paint()
      ..color = eventColor ?? AppTokens.imminentGlow
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, lerpedRadius, dotPaint);

    // Halo range 6→10 (paint at max statically)
    final haloPaint = Paint()
      ..color = (eventColor ?? AppTokens.imminentGlow).withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, lerpedRadius + 8, haloPaint);
  }

  void _drawEventDayOf(Canvas canvas, Offset center, double radius) {
    // White fill
    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, fillPaint);

    // Merged halo Color.lerp(accent, eventColor, 0.5), alpha×1.5
    final mergedColor = Color.lerp(
      AppTokens.todayPulse,
      eventColor ?? AppTokens.eventDot,
      0.5,
    )?.withOpacity(0.6) ?? AppTokens.todayPulse.withOpacity(0.6);
    
    final haloPaint = Paint()
      ..color = mergedColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius + 6, haloPaint);
  }

  void _drawSelected(Canvas canvas, Offset center, double radius) {
    // White 2px stroke, 2px gap, scale 1.2
    final scale = 1.2;
    final gap = 2.0;
    final strokeWidth = 2.0;
    
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    
    canvas.drawCircle(
      center,
      (radius * scale) + gap,
      paint,
    );
  }

  @override
  bool shouldRepaint(DotPainter oldDelegate) {
    return oldDelegate.state != state ||
        oldDelegate.eventColor != eventColor ||
        oldDelegate.isSelected != isSelected ||
        oldDelegate.size != size;
  }
}
