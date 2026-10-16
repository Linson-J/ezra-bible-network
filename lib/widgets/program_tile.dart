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
        color: isCurrent ? AppColors.surfaceHigh : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent ? AppColors.gold : Colors.transparent,
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
                      color: isCurrent ? AppColors.gold : AppColors.text,
                    )),
                Text(formatHhmm(context, p.endTime),
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
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
                      color: AppColors.live,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('ON AIR',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
                  ),
                Text(p.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                if (p.speaker.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(p.speaker, style: const TextStyle(color: AppColors.goldLight, fontSize: 13)),
                  ),
                if (p.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(p.description,
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.35)),
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
                color: hasReminder ? AppColors.gold : AppColors.textMuted,
              ),
            ),
        ],
      ),
    );
  }
}
