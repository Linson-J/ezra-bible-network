import 'package:flutter/material.dart';

import '../models/verse.dart';
import '../theme/app_theme.dart';

/// Verse of the day. [large] is used on the Verse tab.
class VerseCard extends StatelessWidget {
  const VerseCard({super.key, required this.verse, this.onTap, this.large = false});

  final Verse verse;
  final VoidCallback? onTap;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final textScale = large ? 1.0 : 0.72;
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2B1F78), Color(0xFF16124A)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(large ? 28 : 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_stories_rounded, color: AppColors.gold, size: 18),
                    const SizedBox(width: 8),
                    Text('VERSE OF THE DAY',
                        style: TextStyle(
                          color: AppColors.gold,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                        )),
                  ],
                ),
                SizedBox(height: large ? 22 : 12),
                if (large)
                  const Icon(Icons.format_quote_rounded, color: AppColors.gold, size: 36),
                Text(
                  verse.text,
                  maxLines: large ? null : 4,
                  overflow: large ? null : TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTheme.verseFont,
                    fontSize: 26 * textScale,
                    height: 1.5,
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: large ? 20 : 10),
                Text(
                  verse.reference,
                  style: TextStyle(
                    fontFamily: AppTheme.verseFont,
                    fontSize: large ? 20 : 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.goldLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
