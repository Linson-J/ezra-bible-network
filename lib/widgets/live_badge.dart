import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Red "LIVE" pill. When [active] is false it is shown dimmed (e.g. paused).
class LiveBadge extends StatelessWidget {
  const LiveBadge({super.key, this.active = true, this.label = 'LIVE'});

  final bool active;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: active ? AppColors.live : Colors.black54,
        borderRadius: BorderRadius.circular(4),
        border: active ? null : Border.all(color: Colors.white38),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: active ? Colors.white : Colors.white54,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
