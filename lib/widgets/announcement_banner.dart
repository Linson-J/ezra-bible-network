import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AnnouncementBanner extends StatelessWidget {
  const AnnouncementBanner({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.palette.gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.palette.gold.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.campaign_rounded, color: context.palette.gold),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: TextStyle(color: context.palette.text, fontSize: 15, height: 1.35)),
          ),
        ],
      ),
    );
  }
}
