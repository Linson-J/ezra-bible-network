import 'package:flutter/material.dart';

import '../services/player_service.dart';
import '../theme/app_theme.dart';
import 'ios_press.dart';

/// Shown over the player when the stream can't play.
class OfflineView extends StatelessWidget {
  const OfflineView({
    super.key,
    required this.status,
    required this.message,
    required this.retryInSeconds,
    required this.onRetry,
  });

  final PlayerStatus status;
  final String message;
  final int retryInSeconds;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final (icon, title) = switch (status) {
      PlayerStatus.offline => (Icons.wifi_off_rounded, 'You\'re offline'),
      PlayerStatus.offAir => (Icons.tv_off_rounded, 'We\'re off air right now'),
      _ => (Icons.cloud_off_rounded, 'Stream unavailable'),
    };
    final detail = status == PlayerStatus.offline
        ? 'Check your connection. We\'ll reconnect automatically.'
        : message;

    return Container(
      color: AppColors.video,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: AppColors.accent, size: 40),
                const SizedBox(height: 10),
                Text(title,
                    style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(detail,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 14),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IosPress(
                      child: FilledButton.icon(
                      onPressed: onRetry,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.onAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: Text(status == PlayerStatus.offAir ? 'Try anyway' : 'Retry now'),
                    ),
                    ),
                    if (retryInSeconds > 0) ...[
                      const SizedBox(width: 12),
                      Text('Retrying in ${retryInSeconds}s',
                          style: const TextStyle(color: Colors.white60, fontSize: 12)),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
