import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/program.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

/// "Now Playing" and "Up Next" from the schedule.
class NowPlayingCard extends StatelessWidget {
  const NowPlayingCard({super.key, required this.current, required this.next, this.onTap});

  final Program? current;
  final Program? next;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Row(label: 'NOW PLAYING', program: current, highlight: true),
              if (next != null) ...[
                const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider()),
                _Row(label: 'UP NEXT', program: next),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.program, this.highlight = false});

  final String label;
  final Program? program;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final p = program;
    final now = DateTime.now();
    String? when;
    if (p != null) {
      final time = '${formatHhmm(context, p.startTime)} – ${formatHhmm(context, p.endTime)}';
      final isToday = p.dayOfWeek == now.weekday ||
          (p.isOnAirAt(now) && highlight); // overnight program still "now"
      when = isToday ? time : '${weekdayShort[p.dayOfWeek - 1]} $time';
    }

    return Row(
      children: [
        _Thumb(url: p?.thumbnailUrl ?? '', highlight: highlight),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                    color: highlight ? AppColors.gold : AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  )),
              const SizedBox(height: 3),
              Text(
                p?.title ?? 'Ezra Bible Network Live',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: highlight ? 17 : 15, fontWeight: FontWeight.w600),
              ),
              if (p != null)
                Text(
                  [if (p.speaker.isNotEmpty) p.speaker, when].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.url, required this.highlight});
  final String url;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final size = highlight ? 56.0 : 44.0;
    final fallback = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(highlight ? Icons.live_tv_rounded : Icons.schedule_rounded,
          color: AppColors.gold, size: size * 0.45),
    );
    if (url.isEmpty) return fallback;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: CachedNetworkImage(
        imageUrl: url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (_, __) => fallback,
        errorWidget: (_, __, ___) => fallback,
      ),
    );
  }
}
