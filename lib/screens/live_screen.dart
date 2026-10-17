import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_constants.dart';
import '../services/player_service.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/announcement_banner.dart';
import '../widgets/minute_ticker.dart';
import '../widgets/now_playing_card.dart';
import '../widgets/player_controls_bar.dart';
import '../widgets/player_surface.dart';
import '../widgets/verse_card.dart';

class LiveScreen extends StatelessWidget {
  const LiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerService>();
    final app = context.watch<AppState>();
    final offlineMessage = app.config.offlineMessage.isNotEmpty
        ? app.config.offlineMessage
        : 'We\'re having trouble reaching the live stream.';

    // The GlobalKey keeps the same player widget when switching layouts.
    final surface = KeyedSubtree(
      key: player.playerKey,
      child: PlayerSurface(player: player, offlineMessage: offlineMessage, compact: player.inPip),
    );

    if (player.inPip) {
      return ColoredBox(
        color: Colors.black,
        child: Center(child: AspectRatio(aspectRatio: 16 / 9, child: surface)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 32),
            const SizedBox(width: 10),
            const Text(AppConstants.appName),
          ],
        ),
      ),
      body: Column(
        children: [
          AspectRatio(aspectRatio: 16 / 9, child: surface),
          PlayerControlsBar(player: player),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                if (app.config.announcement.trim().isNotEmpty) ...[
                  AnnouncementBanner(text: app.config.announcement.trim()),
                  const SizedBox(height: 14),
                ],
                MinuteTicker(
                  builder: (context, now) => NowPlayingCard(
                    current: app.currentProgram(now),
                    next: app.nextProgram(now),
                    onTap: () => app.tab.value = 1,
                  ),
                ),
                const SizedBox(height: 14),
                if (app.todayVerse != null)
                  VerseCard(verse: app.todayVerse!, onTap: () => app.tab.value = 2)
                else
                  const SizedBox.shrink(),
                if (player.audioOnly) ...[
                  const SizedBox(height: 14),
                  Text(
                    'Audio-only mode hides the video. Playback continues with the screen off '
                    'and can be controlled from the notification.',
                    style: TextStyle(color: context.palette.textMuted, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
