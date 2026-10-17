import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Bundled Lottie animations (assets/*.json).
enum AppAnimation {
  live('assets/live-streaming.json'),
  likes('assets/likes.json'),
  post('assets/post.json'),
  social('assets/social-media.json');

  const AppAnimation(this.asset);
  final String asset;
}

/// A looping Lottie animation on a light circle. The artwork has black
/// outlines, so the circle stays light in dark mode too. Shows a still frame
/// when the system asks for reduced motion.
class LottieBadge extends StatelessWidget {
  const LottieBadge(this.animation, {super.key, this.size = 52, this.background = const Color(0xFFF4F9FC)});

  final AppAnimation animation;
  final double size;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: ClipOval(
          child: Lottie.asset(
            animation.asset,
            animate: !still,
            repeat: true,
            fit: BoxFit.cover,
            frameRate: FrameRate.max,
            // Skip a frame of the badge rather than show an error.
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
