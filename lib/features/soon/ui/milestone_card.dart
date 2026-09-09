import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../events/domain/models.dart';
import '../../../core/format/app_formatters.dart';
import '../../../core/tokens/app_tokens.dart';
import 'milestones.dart';

/// Card displaying a milestone in the SOON feed.
class MilestoneCard extends StatelessWidget {
  final Milestone milestone;
  final VoidCallback? onTap;

  const MilestoneCard({
    super.key,
    required this.milestone,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTokens.surface,
      borderRadius: BorderRadius.circular(AppTokens.radius),
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          onTap?.call();
        },
        borderRadius: BorderRadius.circular(AppTokens.radius),
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.padding),
          child: Row(
            children: [
              // Accent strip
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: milestone.event.color.toColor(),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: AppTokens.padding),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      milestone.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${milestone.event.title} • ${AppFormatters.dateShort(milestone.date)}',
                      style: TextStyle(
                        color: AppTokens.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Days until
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppFormatters.days(milestone.daysUntil),
                    style: TextStyle(
                      color: AppTokens.accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (milestone.daysUntil == 0)
                    Text(
                      'Today!',
                      style: TextStyle(
                        color: AppTokens.accent,
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
