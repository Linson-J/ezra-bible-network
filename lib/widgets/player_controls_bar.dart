import 'package:flutter/material.dart';

import '../services/player_service.dart';
import '../theme/app_theme.dart';

/// Play/pause, Go Live, audio-only, PiP and fullscreen controls under the player.
class PlayerControlsBar extends StatelessWidget {
  const PlayerControlsBar({super.key, required this.player});

  final PlayerService player;

  @override
  Widget build(BuildContext context) {
    final ready = player.status == PlayerStatus.ready;
    final loading = player.status == PlayerStatus.loading;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 4),
      child: Row(
        children: [
          IconButton.filled(
            tooltip: player.isPlaying ? 'Pause' : 'Play',
            onPressed: loading ? null : player.togglePlay,
            style: IconButton.styleFrom(
              backgroundColor: context.palette.goldFill,
              foregroundColor: context.palette.onGold,
              minimumSize: const Size(48, 48),
            ),
            icon: Icon(player.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 28),
          ),
          const SizedBox(width: 10),
          _GoLiveButton(
            enabled: ready && player.isBehindLive,
            onPressed: player.goLive,
          ),
          const Spacer(),
          IconButton(
            tooltip: player.audioOnly ? 'Show video' : 'Audio only',
            isSelected: player.audioOnly,
            onPressed: player.toggleAudioOnly,
            icon: const Icon(Icons.headphones_outlined),
            selectedIcon: Icon(Icons.headphones_rounded, color: context.palette.gold),
          ),
          if (player.pipSupported)
            IconButton(
              tooltip: 'Picture-in-picture',
              onPressed: ready && !player.audioOnly ? player.enterPip : null,
              icon: const Icon(Icons.picture_in_picture_alt_rounded),
            ),
          IconButton(
            tooltip: 'Fullscreen',
            onPressed: ready && !player.audioOnly ? player.toggleFullScreen : null,
            icon: const Icon(Icons.fullscreen_rounded),
          ),
        ],
      ),
    );
  }
}

class _GoLiveButton extends StatelessWidget {
  const _GoLiveButton({required this.enabled, required this.onPressed});
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: enabled ? onPressed : null,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        side: BorderSide(color: enabled ? context.palette.live : context.palette.outline),
      ),
      icon: Icon(Icons.circle,
          size: 10, color: enabled ? context.palette.live : context.palette.textMuted.withValues(alpha: 0.5)),
      label: const Text('Go Live'),
    );
  }
}
