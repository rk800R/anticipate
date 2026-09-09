import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/format/app_formatters.dart';
import '../../core/tokens/app_tokens.dart';
import '../events/domain/models.dart';

/// Provider for current time (for live countdown updates).
final nowProvider = StateProvider<DateTime>((ref) => DateTime.now());

/// Live countdown widget that rebuilds only itself.
class CountdownWidget extends ConsumerWidget {
  final UpcomingOccurrence occurrence;

  const CountdownWidget({
    Key? key,
    required this.occurrence,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch now provider for live updates
    final now = ref.watch(nowProvider);

    if (occurrence.occurrenceDate == null) {
      // Past event - show "days since"
      final daysSince = -occurrence.daysUntil;
      return Text(
        '${AppFormatters.days(daysSince)} since',
        style: AppTokens.bodyMedium.copyWith(
          color: AppTokens.textSecondary,
        ),
      );
    }

    final duration = occurrence.occurrenceDate!.difference(now);
    
    if (duration.isNegative) {
      // Event just passed
      return Text(
        'Today!',
        style: AppTokens.headlineMedium.copyWith(
          color: AppTokens.todayPulse,
        ),
      );
    }

    final parts = AppFormatters.countdownParts(duration);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        _buildUnit(AppFormatters.number(parts['days']!), 'd'),
        if (parts['days']! > 0) ...[
          const SizedBox(width: AppTokens.spacingXs),
          _buildUnit(AppFormatters.number(parts['hours']!, minLength: 2), 'h'),
          const SizedBox(width: AppTokens.spacingXs),
          _buildUnit(AppFormatters.number(parts['minutes']!, minLength: 2), 'm'),
          const SizedBox(width: AppTokens.spacingXs),
          _buildUnit(AppFormatters.number(parts['seconds']!, minLength: 2), 's'),
        ] else ...[
          // For < 1 day, show h:m:s
          const SizedBox(width: AppTokens.spacingXs),
          _buildUnit(AppFormatters.number(parts['hours']!), 'h'),
          const SizedBox(width: AppTokens.spacingXs),
          _buildUnit(AppFormatters.number(parts['minutes']!, minLength: 2), 'm'),
          const SizedBox(width: AppTokens.spacingXs),
          _buildUnit(AppFormatters.number(parts['seconds']!, minLength: 2), 's'),
        ],
      ],
    );
  }

  Widget _buildUnit(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppTokens.countdownMono.copyWith(
            fontSize: 32,
          ),
        ),
        Text(
          label,
          style: AppTokens.bodyMedium.copyWith(
            fontSize: 10,
            color: AppTokens.textSecondary,
          ),
        ),
      ],
    );
  }
}
