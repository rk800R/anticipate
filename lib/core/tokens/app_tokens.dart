import 'package:flutter/material.dart';

/// Design tokens for SOON - the anticipation engine.
/// All visual values live here. Raw literals are banned everywhere else.

class AppTokens {
  AppTokens._();

  // ===========================================================================
  // COMET TAIL & FADE TOKENS (D9)
  // ===========================================================================
  
  /// The minimum opacity for past days in the comet trail
  static const double fadeFloor = 0.15;
  
  /// Number of days over which the comet trail fades linearly
  static const int trailReachDays = 7;

  // ===========================================================================
  // MOTION TOKENS
  // ===========================================================================
  
  /// Quick feedback animations (~100ms)
  static const Duration motionQuick = Duration(milliseconds: 100);
  
  /// Standard transitions (~300ms)
  static const Duration motionStandard = Duration(milliseconds: 300);
  
  /// Deliberate animations like midnight cascade (~600ms)
  static const Duration motionDeliberate = Duration(milliseconds: 600);
  
  /// Motion curve for all animations - consistent language
  static const Curve motionCurve = Curves.easeOutCubic;

  // ===========================================================================
  // COLOR TOKENS - Dark Theme Default
  // ===========================================================================
  
  /// Primary background
  static const Color backgroundPrimary = Color(0xFF0A0A0F);
  
  /// Secondary background for cards/surfaces
  static const Color backgroundSecondary = Color(0xFF12121A);
  
  /// Tertiary background for elevated elements
  static const Color backgroundTertiary = Color(0xFF1E1E28);
  
  /// Today's pulse color
  static const Color todayPulse = Color(0xFF4FC3F7);
  
  /// Accent color for highlights
  static const Color accent = Color(0xFF4FC3F7);
  
  /// Event dot base color
  static const Color eventDot = Color(0xFFFFAB40);
  
  /// Imminent event glow
  static const Color imminentGlow = Color(0xFFFF5252);
  
  /// Past day faded color
  static const Color pastDay = Color(0xFF424242);
  
  /// Future day color
  static const Color futureDay = Color(0xFF616161);
  
  /// Text primary
  static const Color textPrimary = Color(0xFFFFFFFF);
  
  /// Text secondary
  static const Color textSecondary = Color(0xFFB0B0B0);
  
  /// Error state
  static const Color errorColor = Color(0xFFEF5350);
  
  /// Success state
  static const Color successColor = Color(0xFF66BB6A);

  // ===========================================================================
  // SPACING TOKENS
  // ===========================================================================
  
  static const double spacingXxs = 4.0;
  static const double spacingXs = 8.0;
  static const double spacingSm = 12.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // ===========================================================================
  // DOT GRID TOKENS (D10 - Monday First)
  // ===========================================================================
  
  /// Size of each dot in the grid
  static const double dotSize = 8.0;
  
  /// Spacing between dots
  static const double dotSpacing = 4.0;
  
  /// Size of today's pulsing dot
  static const double todayDotSize = 10.0;
  
  /// Size of event dots
  static const double eventDotSize = 8.0;

  // ===========================================================================
  // TYPOGRAPHY TOKENS
  // ===========================================================================
  
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -1,
    color: textPrimary,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimary,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textSecondary,
  );
  
  static const TextStyle countdownMono = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w300,
    fontFeatures: [FontFeature.tabularFigures()],
    color: textPrimary,
  );
}
