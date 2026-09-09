import 'package:flutter_test/flutter_test.dart';
import 'package:soon/core/tokens/app_tokens.dart';

void main() {
  group('AppTokens', () {
    test('fade floor is 0.15 as per D9', () {
      expect(AppTokens.fadeFloor, equals(0.15));
    });

    test('trail reach is 7 days as per D9', () {
      expect(AppTokens.trailReachDays, equals(7));
    });

    test('motion tiers are 100/300/600ms', () {
      expect(AppTokens.motionQuick.inMilliseconds, equals(100));
      expect(AppTokens.motionStandard.inMilliseconds, equals(300));
      expect(AppTokens.motionDeliberate.inMilliseconds, equals(600));
    });

    test('all color tokens are defined', () {
      expect(AppTokens.backgroundPrimary, isNotNull);
      expect(AppTokens.backgroundSecondary, isNotNull);
      expect(AppTokens.backgroundTertiary, isNotNull);
      expect(AppTokens.todayPulse, isNotNull);
      expect(AppTokens.eventDot, isNotNull);
      expect(AppTokens.imminentGlow, isNotNull);
      expect(AppTokens.pastDay, isNotNull);
      expect(AppTokens.futureDay, isNotNull);
      expect(AppTokens.textPrimary, isNotNull);
      expect(AppTokens.textSecondary, isNotNull);
      expect(AppTokens.errorColor, isNotNull);
      expect(AppTokens.successColor, isNotNull);
    });

    test('dark theme is default (background is dark)', () {
      // Primary background should be dark (low luminance)
      expect(AppTokens.backgroundPrimary.red, lessThan(50));
      expect(AppTokens.backgroundPrimary.green, lessThan(50));
      expect(AppTokens.backgroundPrimary.blue, lessThan(50));
    });

    test('spacing tokens are defined', () {
      expect(AppTokens.spacingXxs, equals(4.0));
      expect(AppTokens.spacingXs, equals(8.0));
      expect(AppTokens.spacingSm, equals(12.0));
      expect(AppTokens.spacingMd, equals(16.0));
      expect(AppTokens.spacingLg, equals(24.0));
      expect(AppTokens.spacingXl, equals(32.0));
      expect(AppTokens.spacingXxl, equals(48.0));
    });

    test('dot grid tokens are defined', () {
      expect(AppTokens.dotSize, equals(8.0));
      expect(AppTokens.dotSpacing, equals(4.0));
      expect(AppTokens.todayDotSize, equals(10.0));
      expect(AppTokens.eventDotSize, equals(8.0));
    });

    test('typography tokens are defined', () {
      expect(AppTokens.displayLarge, isNotNull);
      expect(AppTokens.headlineMedium, isNotNull);
      expect(AppTokens.bodyLarge, isNotNull);
      expect(AppTokens.bodyMedium, isNotNull);
      expect(AppTokens.countdownMono, isNotNull);
    });

    test('countdown mono has tabular figures', () {
      final fontFeatures = AppTokens.countdownMono.fontFeatures;
      expect(fontFeatures, isNotEmpty);
      expect(fontFeatures!.any((f) => f.toString().contains('tnum')), true);
    });
  });
}
