import 'package:flutter/material.dart';

import '../models/verse.dart';
import '../theme/app_theme.dart';
import 'ios_press.dart';

/// Today's verse, shown on the Live tab.
class VerseCard extends StatelessWidget {
  const VerseCard({super.key, required this.verse, this.onTap});

  final Verse verse;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return IosPress(
      scale: 0.98,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TODAY\'S WORD', style: AppText.eyebrow(p.textMuted, size: 12)),
                const SizedBox(height: 12),
                Text(
                  verse.text,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontFamily: AppText.verseFont, fontSize: 22, height: 1.3, color: p.text),
                ),
                const SizedBox(height: 12),
                Text(
                  verse.reference,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: p.text),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
