import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';

import '../services/player_service.dart';
import '../theme/app_theme.dart';
import 'live_badge.dart';
import 'offline_view.dart';

/// The 16:9 video area: player, LIVE badge, audio-only artwork and
/// the offline/error overlay.
class PlayerSurface extends StatelessWidget {
  const PlayerSurface({super.key, required this.player, required this.offlineMessage, this.compact = false});

  final PlayerService player;
  final String offlineMessage;

  /// PiP: just the video and badge.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = player.controller;
    final failed = player.status == PlayerStatus.error ||
        player.status == PlayerStatus.offline ||
        player.status == PlayerStatus.offAir;
    final atLiveEdge = player.isPlaying && !player.isBehindLive;

    return ColoredBox(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (c != null) BetterPlayer(controller: c),
          if (player.audioOnly && !failed) _AudioOnlyArt(compact: compact),
          if (c == null && player.status == PlayerStatus.loading)
            const Center(child: CircularProgressIndicator(color: AppColors.gold)),
          if (failed && !compact)
            OfflineView(
              status: player.status,
              message: offlineMessage,
              retryInSeconds: player.retryInSeconds,
              onRetry: player.retryNow,
            ),
          if (!failed)
            Positioned(
              top: compact ? 6 : 10,
              left: compact ? 6 : 10,
              child: IgnorePointer(
                child: LiveBadge(
                  active: atLiveEdge,
                  label: player.isPlaying && player.isBehindLive ? 'BEHIND LIVE' : 'LIVE',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AudioOnlyArt extends StatelessWidget {
  const _AudioOnlyArt({required this.compact});
  final bool compact;

  @override
  Widget build(BuildContext context) {
    // Absorbs taps so the hidden video's controls don't pop up.
    return AbsorbPointer(
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.headerGradient),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/logo.png', height: compact ? 48 : 88),
              if (!compact) ...[
                const SizedBox(height: 12),
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.headphones_rounded, color: AppColors.gold, size: 18),
                    SizedBox(width: 6),
                    Text('Audio only', style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
