import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../config/app_constants.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/verse_card.dart';
import '../widgets/verse_notification_settings.dart';

class VerseScreen extends StatelessWidget {
  const VerseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final verse = app.todayVerse;

    return Scaffold(
      appBar: AppBar(title: const Text('Verse of the Day')),
      body: verse == null
          ? Center(child: CircularProgressIndicator(color: context.palette.gold))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                Text(formatLongDate(DateTime.now()),
                    style: TextStyle(color: context.palette.textMuted, fontSize: 15)),
                const SizedBox(height: 14),
                VerseCard(verse: verse, large: true),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: context.palette.goldFill,
                          foregroundColor: context.palette.onGold,
                        ),
                        onPressed: () => SharePlus.instance.share(ShareParams(
                          text: '${verse.shareText}\n\nShared from ${AppConstants.appName}\n'
                              '${AppConstants.playStoreUrl}',
                          subject: 'Verse of the Day · ${verse.reference}',
                        )),
                        icon: const Icon(Icons.share_rounded),
                        label: const Text('Share'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: verse.shareText));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Verse copied')),
                            );
                          }
                        },
                        icon: const Icon(Icons.copy_rounded),
                        label: const Text('Copy'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: VerseNotificationSettings(),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Scripture quotations from the King James Version (public domain).',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: context.palette.textMuted, fontSize: 12),
                ),
              ],
            ),
    );
  }
}
