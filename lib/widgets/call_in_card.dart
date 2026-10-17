import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/launcher.dart';
import 'ios_press.dart';

/// Live-stream promo on the Live tab: where to watch, and the number to call
/// in during the live show. Stays on the dark brand gradient in both themes so
/// it reads as a broadcast spot, not a regular card.
class CallInCard extends StatelessWidget {
  const CallInCard({super.key, required this.phone, this.whatsapp = ''});

  final String phone;
  final String whatsapp;

  @override
  Widget build(BuildContext context) {
    final muted = Colors.white.withValues(alpha: 0.75);
    // Only the buttons act; the card itself is not tappable.
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(gradient: AppColors.brandGradient, borderRadius: BorderRadius.circular(16)),
      child: Stack(
        children: [
          // Oversized broadcast glyph as a watermark.
          Positioned(
            right: -20,
            top: -16,
            child: Icon(Icons.live_tv_rounded, size: 150, color: Colors.white.withValues(alpha: 0.06)),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const _OnAirDot(),
                    const SizedBox(width: 8),
                    Text('LIVE ON AIR', style: AppText.eyebrow(AppColors.accentLight, size: 12)),
                  ],
                ),
                const SizedBox(height: 12),
                Text('WATCH US LIVE.\nANYWHERE.', style: AppText.display(32, color: Colors.white)),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Channel(leading: Image.asset('assets/youtube.png', height: 16), label: 'YouTube'),
                    const _Channel(
                      leading: Icon(Icons.tv_rounded, size: 16, color: Colors.white),
                      label: 'Local TV',
                    ),
                    const _Channel(
                      leading: Icon(Icons.phone_iphone_rounded, size: 16, color: Colors.white),
                      label: 'This app',
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(height: 1, color: Colors.white.withValues(alpha: 0.14)),
                const SizedBox(height: 14),
                Text('YOUR CHURCH, LIVE', style: AppText.eyebrow(AppColors.accentLight, size: 12)),
                const SizedBox(height: 8),
                Text(
                  'We livestream your sermons, Sunday services and church programmes on YouTube, '
                  'local TV and this app.',
                  style: TextStyle(color: muted, fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 10),
                for (final item in const [
                  'Sermons & Sunday worship',
                  'Conventions & special meetings',
                  'Church events & celebrations',
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.accent),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item,
                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                Text('CALL TO GO LIVE OR CALL IN', style: AppText.eyebrow(muted, size: 11)),
                const SizedBox(height: 6),
                Text(_pretty(phone), style: AppText.display(34, color: AppColors.accent).copyWith(letterSpacing: 0.6)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: IosPress(
                        child: FilledButton.icon(
                          onPressed: () => Launcher.call(context, phone),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: AppColors.onAccent,
                            minimumSize: const Size.fromHeight(46),
                            shape: const StadiumBorder(),
                            textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                          icon: const Icon(Icons.call_rounded, size: 20),
                          label: const Text('Call now'),
                        ),
                      ),
                    ),
                    if (whatsapp.isNotEmpty) ...[
                      const SizedBox(width: 10),
                      IosPress(
                        child: OutlinedButton.icon(
                          onPressed: () => Launcher.whatsapp(context, whatsapp),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(color: Colors.white.withValues(alpha: 0.45)),
                            minimumSize: const Size(0, 46),
                            shape: const StadiumBorder(),
                            textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                          icon: Image.asset('assets/apple.png', width: 20, height: 20),
                          label: const Text('WhatsApp'),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// +919943977366 → +91 99439 77366. Other formats are shown as given.
  static String _pretty(String s) {
    final m = RegExp(r'^\+91(\d{5})(\d{5})$').firstMatch(s.replaceAll(RegExp(r'[^0-9+]'), ''));
    return m == null ? s : '+91 ${m[1]} ${m[2]}';
  }
}

/// A "where to watch" pill.
class _Channel extends StatelessWidget {
  const _Channel({required this.leading, required this.label});

  final Widget leading;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          leading,
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// Pulsing red "on air" dot. Holds still when reduced motion is on.
class _OnAirDot extends StatefulWidget {
  const _OnAirDot();

  @override
  State<_OnAirDot> createState() => _OnAirDotState();
}

class _OnAirDotState extends State<_OnAirDot> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.stop();
      _c.value = 0;
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 14,
      height: 14,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) => Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: 1 + _c.value,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.live.withValues(alpha: (1 - _c.value) * 0.6),
                ),
              ),
            ),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.live),
            ),
          ],
        ),
      ),
    );
  }
}
