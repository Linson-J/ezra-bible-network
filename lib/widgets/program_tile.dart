import 'package:flutter/material.dart';

import '../models/program.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class ProgramTile extends StatelessWidget {
  const ProgramTile({
    super.key,
    required this.program,
    required this.isCurrent,
    required this.hasReminder,
    required this.onToggleReminder,
  });

  final Program program;
  final bool isCurrent;
  final bool hasReminder;
  final VoidCallback onToggleReminder;

  @override
  Widget build(BuildContext context) {
    final p = program;
    return Container(
      decoration: BoxDecoration(
        color: isCurrent ? context.palette.surfaceHigh : context.palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          // Light tiles need an edge against the near-white background.
          color: isCurrent
              ? context.palette.gold
              : Theme.of(context).brightness == Brightness.light
                  ? context.palette.outlineVariant
                  : Colors.transparent,
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 6, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(formatHhmm(context, p.startTime),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: isCurrent ? context.palette.gold : context.palette.text,
                    )),
                Text(formatHhmm(context, p.endTime),
                    style: TextStyle(color: context.palette.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isCurrent)
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: context.palette.live,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('ON AIR',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
                  ),
                Text(p.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                if (p.speaker.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(p.speaker, style: TextStyle(color: context.palette.goldLight, fontSize: 13)),
                  ),
                if (p.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(p.description,
                        style: TextStyle(color: context.palette.textMuted, fontSize: 13, height: 1.35)),
                  ),
              ],
            ),
          ),
          if (!isCurrent)
            IconButton(
              tooltip: hasReminder ? 'Cancel reminder' : 'Remind me',
              onPressed: onToggleReminder,
              icon: Icon(
                hasReminder ? Icons.notifications_active_rounded : Icons.notifications_none_rounded,
                color: hasReminder ? context.palette.gold : context.palette.textMuted,
              ),
            ),
        ],
      ),
    );
  }
}
