import 'package:flutter/material.dart';
import '../models/subscription_tier.dart';
import '../theme/vibrant_theme.dart';

class CoachReviewCard extends StatelessWidget {
  final CoachProfile coach;
  final VoidCallback? onMessageCoach;

  const CoachReviewCard({
    super.key,
    required this.coach,
    this.onMessageCoach,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: VibrantColors.border,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [VibrantColors.neonMagenta, Color(0xFF9333EA)],
                  ),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  coach.avatarInitials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            coach.name,
                            style: const TextStyle(
                              color: VibrantColors.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: VibrantColors.neonMagenta.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: VibrantColors.neonMagenta,
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            'HUMAN COACH',
                            style: TextStyle(
                              color: VibrantColors.neonMagenta,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      coach.credentials,
                      style: const TextStyle(
                        color: VibrantColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),


          // Feedback container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: VibrantColors.border,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline,
                      size: 13,
                      color: VibrantColors.neonMagenta,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'LATEST TELEMETRY & ADHERENCE REVIEW',
                      style: TextStyle(
                        color: VibrantColors.neonMagenta.withValues(alpha: 0.9),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  coach.latestFeedback,
                  style: const TextStyle(
                    color: VibrantColors.textPrimary,
                    fontSize: 12.5,
                    height: 1.4,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Check-in date + action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.event_available,
                    size: 15,
                    color: VibrantColors.neonCyan,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Next Sync: ${coach.nextCheckInDate}',
                    style: const TextStyle(
                      color: VibrantColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: onMessageCoach ??
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFF0F172A),
                          content: Text(
                            'Telemetry packet sent to ${coach.name}. Weekly sync locked for Sunday.',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: VibrantColors.neonMagenta.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: VibrantColors.neonMagenta,
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.send_rounded,
                          size: 12, color: VibrantColors.neonMagenta),
                      SizedBox(width: 4),
                      Text(
                        'PING COACH',
                        style: TextStyle(
                          color: VibrantColors.neonMagenta,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
