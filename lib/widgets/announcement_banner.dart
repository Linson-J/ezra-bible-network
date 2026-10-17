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
        color: context.palette.accentFill.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6),
        border: Border(left: BorderSide(color: context.palette.accentFill, width: 3)),
      ),
      child: Text(text, style: TextStyle(color: context.palette.text, fontSize: 15, height: 1.35)),
    );
  }
}
