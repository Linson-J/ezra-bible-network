import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../config/app_constants.dart';
import '../models/verse.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/app_bottom_bar.dart';
import '../widgets/ios_press.dart';
import '../widgets/verse_notification_settings.dart';

class VerseScreen extends StatelessWidget {
  const VerseScreen({super.key});

  static const translation = 'KJV';

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final verse = app.todayVerse;
    final yesterday = app.yesterdayVerse;
    final p = context.palette;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: verse == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: EdgeInsets.fromLTRB(18, 20, 18, AppBottomBar.clearance(context)),
                children: [
                  Text(formatEyebrowDate(DateTime.now()), style: AppText.eyebrow(p.textMuted, size: 13)),
                  const SizedBox(height: 8),
                  Text('TODAY\'S WORD', style: AppText.display(44, color: p.text)),
                  const SizedBox(height: 26),
                  Divider(color: p.text, thickness: 1.5, height: 1.5),
                  const SizedBox(height: 26),
                  SelectableText(
                    verse.text,
                    style: TextStyle(fontFamily: AppText.verseFont, fontSize: 32, height: 1.3, color: p.text),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Flexible(
                        child: Text(
                          verse.reference,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: p.text),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(translation, style: TextStyle(fontSize: 13, letterSpacing: 1.5, color: p.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: IosPress(
                          child: SizedBox(
                            height: 50,
                            child: FilledButton.icon(
                              onPressed: () => SharePlus.instance.share(
                                ShareParams(
                                  text:
                                      '${verse.shareText} ($translation)\n\nShared from ${AppConstants.appName}\n'
                                      '${AppConstants.playStoreUrl}',
                                  subject: 'Today\'s Word · ${verse.reference}',
                                ),
                              ),
                              icon: const Icon(Icons.ios_share_rounded, size: 22),
                              label: const Text('Share'),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IosPress(
                        child: SizedBox.square(
                          dimension: 50,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
                            onPressed: () async {
                              await Clipboard.setData(ClipboardData(text: '${verse.shareText} ($translation)'));
                              if (context.mounted) {
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(const SnackBar(content: Text('Verse copied')));
                              }
                            },
                            child: const Icon(Icons.copy_rounded, size: 22, semanticLabel: 'Copy'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Divider(),
                  const MorningVerseRow(),
                  const Divider(),
                  if (yesterday != null)
                    InkWell(
                      onTap: () => _showVerse(context, 'Yesterday', yesterday),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        child: Row(
                          children: [
                            Text(
                              'Yesterday',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: p.text),
                            ),
                            const Spacer(),
                            Text(yesterday.reference, style: TextStyle(fontSize: 16, color: p.textMuted)),
                            const SizedBox(width: 4),
                            Icon(Icons.chevron_right_rounded, color: p.textFaint),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  void _showVerse(BuildContext context, String label, Verse verse) {
    final p = context.palette;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: p.background,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(), style: AppText.eyebrow(p.textMuted)),
            const SizedBox(height: 14),
            Text(
              verse.text,
              style: TextStyle(fontFamily: AppText.verseFont, fontSize: 26, height: 1.3, color: p.text),
            ),
            const SizedBox(height: 16),
            Text(
              verse.reference,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: p.text),
            ),
          ],
        ),
      ),
    );
  }
}
