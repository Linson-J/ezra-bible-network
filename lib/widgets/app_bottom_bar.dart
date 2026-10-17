import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

/// Live · Verse · More, as a floating "liquid glass" capsule like the iOS tab
/// bar: the page blurs through it, and a glassy light-blue pill marks the
/// selected tab. Tap a tab, or press and swipe along the bar: the pill follows
/// the finger, stretches with its speed and snaps to the nearest tab.
///
/// Use with `Scaffold(extendBody: true)` so content scrolls underneath.
/// Scrolling pages add [AppBottomBar.clearance] to their bottom padding.
class AppBottomBar extends StatefulWidget {
  const AppBottomBar({super.key, required this.index, required this.onSelect});

  final int index;
  final ValueChanged<int> onSelect;

  static const _items = [
    (Icons.live_tv_outlined, Icons.live_tv_rounded, 'Live'),
    (Icons.menu_book_outlined, Icons.menu_book_rounded, 'Verse'),
    (Icons.menu_rounded, Icons.menu_open_rounded, 'More'),
  ];

  static const _duration = Duration(milliseconds: 420);
  static const _height = 66.0;
  static const _margin = 16.0;
  static const _radius = _height / 2;

  /// Gap between the pill and the capsule's edge.
  static const _inset = 5.0;

  /// The pill grows like a lens while it's held.
  static const _lift = 1.06;

  /// Space a scrolling page needs at its bottom to clear the bar.
  static double clearance(BuildContext context) => _height + _margin + 12 + MediaQuery.paddingOf(context).bottom;

  @override
  State<AppBottomBar> createState() => _AppBottomBarState();
}

class _AppBottomBarState extends State<AppBottomBar> {
  /// Pill centre while the finger is down; null otherwise.
  double? _dragX;

  /// 0 at rest, up to 0.22 on a fast swipe.
  double _stretch = 0;

  /// Tab under the pill during a drag, for haptics and highlighting.
  int? _hover;

  double _slot = 0;
  double _width = 0;

  int get _count => AppBottomBar._items.length;

  int _nearest(double x) => (x / _slot).floor().clamp(0, _count - 1);

  /// Keeps the (stretched, lifted) pill inside the capsule.
  double _clampCentre(double x, double scaleX) {
    final half = (_slot - AppBottomBar._inset * 2) * scaleX / 2;
    final min = half + AppBottomBar._inset;
    final max = _width - half - AppBottomBar._inset;
    return min > max ? _width / 2 : x.clamp(min, max);
  }

  void _select(int i) {
    if (i == widget.index) return;
    widget.onSelect(i);
  }

  void _tap(TapUpDetails d) {
    final i = _nearest(d.localPosition.dx);
    if (i != widget.index) HapticFeedback.selectionClick();
    _select(i);
  }

  void _dragStart(DragStartDetails d) {
    HapticFeedback.lightImpact();
    setState(() {
      _dragX = d.localPosition.dx;
      _hover = _nearest(d.localPosition.dx);
    });
  }

  void _dragUpdate(DragUpdateDetails d) {
    final x = (_dragX ?? d.localPosition.dx) + d.delta.dx;
    final hover = _nearest(x);
    if (hover != _hover) HapticFeedback.selectionClick();
    setState(() {
      _dragX = x.clamp(0.0, _width);
      _hover = hover;
      _stretch = (d.delta.dx.abs() / 45).clamp(0.0, 0.22);
    });
  }

  void _dragEnd(DragEndDetails d) {
    final x = _dragX ?? 0;
    // A flick carries on a little, like iOS.
    final target = _nearest((x + d.velocity.pixelsPerSecond.dx * 0.08).clamp(0.0, _width - 1));
    setState(() {
      _dragX = null;
      _hover = null;
      _stretch = 0;
    });
    _select(target);
  }

  void _dragCancel() => setState(() {
    _dragX = null;
    _hover = null;
    _stretch = 0;
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final p = context.palette;
    final dragging = _dragX != null;
    final highlighted = _hover ?? widget.index;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppBottomBar._margin + 8,
        0,
        AppBottomBar._margin + 8,
        AppBottomBar._margin + MediaQuery.paddingOf(context).bottom,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppBottomBar._radius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: dark ? 0.5 : 0.14),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppBottomBar._radius),
          child: BackdropFilter(
            filter: ImageFilter.compose(outer: _saturate(1.6), inner: ImageFilter.blur(sigmaX: 22, sigmaY: 22)),
            child: Container(
              height: AppBottomBar._height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppBottomBar._radius),
                // Tinted glass, lighter at the top where it catches the light.
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: dark
                      ? [Colors.white.withValues(alpha: 0.16), Colors.white.withValues(alpha: 0.06)]
                      : [Colors.white.withValues(alpha: 0.72), Colors.white.withValues(alpha: 0.42)],
                ),
                border: Border.all(color: Colors.white.withValues(alpha: dark ? 0.18 : 0.75)),
              ),
              // Labels never grow past the capsule, whatever the font size setting.
              child: MediaQuery.withClampedTextScaling(
                maxScaleFactor: 1.15,
                child: LayoutBuilder(
                  builder: (context, c) {
                    _width = c.maxWidth;
                    _slot = c.maxWidth / _count;
                    final pillWidth = _slot - AppBottomBar._inset * 2;
                    final scaleX = (dragging ? AppBottomBar._lift : 1.0) * (1 + _stretch);
                    final centre = _clampCentre(_dragX ?? _slot * (widget.index + 0.5), scaleX);

                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapUp: _tap,
                      onHorizontalDragStart: _dragStart,
                      onHorizontalDragUpdate: _dragUpdate,
                      onHorizontalDragEnd: _dragEnd,
                      onHorizontalDragCancel: _dragCancel,
                      child: Stack(
                        children: [
                          _Sheen(strength: dark ? 0.14 : 0.35),
                          AnimatedPositioned(
                            duration: dragging ? const Duration(milliseconds: 90) : AppBottomBar._duration,
                            curve: dragging ? Curves.linear : Curves.easeOutCubic,
                            top: AppBottomBar._inset,
                            bottom: AppBottomBar._inset,
                            left: centre - pillWidth / 2,
                            width: pillWidth,
                            child: TweenAnimationBuilder<Offset>(
                              tween: Tween(
                                end: Offset(scaleX, (dragging ? AppBottomBar._lift : 1.0) * (1 - _stretch * 0.35)),
                              ),
                              duration: dragging ? const Duration(milliseconds: 120) : AppBottomBar._duration,
                              curve: dragging ? Curves.easeOut : Curves.elasticOut,
                              builder: (context, s, child) => Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.diagonal3Values(s.dx, s.dy, 1),
                                child: child,
                              ),
                              child: _GlassPill(color: p.accentFill, dark: dark, held: dragging),
                            ),
                          ),
                          Row(
                            children: [
                              for (var i = 0; i < _count; i++)
                                Expanded(
                                  child: Semantics(
                                    selected: i == widget.index,
                                    button: true,
                                    label: AppBottomBar._items[i].$3,
                                    onTap: () => _select(i),
                                    excludeSemantics: true,
                                    child: _Item(item: AppBottomBar._items[i], selected: i == highlighted),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Boosts the colour of what's behind the glass, as real glass does.
ColorFilter _saturate(double s) {
  const r = 0.2126, g = 0.7152, b = 0.0722;
  final i = 1 - s;
  return ColorFilter.matrix([
    r * i + s, g * i, b * i, 0, 0, //
    r * i, g * i + s, b * i, 0, 0, //
    r * i, g * i, b * i + s, 0, 0, //
    0, 0, 0, 1, 0,
  ]);
}

/// Specular highlight along the top edge of the capsule.
class _Sheen extends StatelessWidget {
  const _Sheen({required this.strength});
  final double strength;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 18,
      right: 18,
      height: 18,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: strength),
                Colors.white.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The selection: a drop of light-blue glass with its own highlight and rim.
class _GlassPill extends StatelessWidget {
  const _GlassPill({required this.color, required this.dark, required this.held});
  final Color color;
  final bool dark;

  /// While held it turns clearer, like a lens, with a stronger glow.
  final bool held;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppBottomBar._radius),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(color, Colors.white, 0.35)!.withValues(alpha: held ? 0.75 : 0.95),
            color.withValues(alpha: held ? 0.6 : 0.85),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: dark ? 0.35 : 0.8),
          width: held ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: held ? 0.6 : 0.45),
            blurRadius: held ? 20 : 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.item, required this.selected});

  final (IconData, IconData, String) item;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final color = selected ? p.onAccent : p.text.withValues(alpha: 0.62);
    // FittedBox: shrinks rather than overflowing on narrow screens.
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: selected ? 1.1 : 1.0,
              duration: AppBottomBar._duration,
              curve: Curves.easeOutBack,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, a) => ScaleTransition(scale: a, child: child),
                child: Icon(selected ? item.$2 : item.$1, key: ValueKey(selected), size: 24, color: color),
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              style: TextStyle(
                fontFamily: AppText.bodyFont,
                fontSize: 11.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                color: color,
              ),
              child: Text(item.$3, maxLines: 1),
            ),
          ],
        ),
      ),
    );
  }
}
