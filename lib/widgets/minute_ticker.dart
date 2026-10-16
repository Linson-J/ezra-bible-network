import 'dart:async';

import 'package:flutter/widgets.dart';

/// Rebuilds [builder] at the start of every minute with the current time.
class MinuteTicker extends StatefulWidget {
  const MinuteTicker({super.key, required this.builder});

  final Widget Function(BuildContext context, DateTime now) builder;

  @override
  State<MinuteTicker> createState() => _MinuteTickerState();
}

class _MinuteTickerState extends State<MinuteTicker> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _schedule();
  }

  void _schedule() {
    final now = DateTime.now();
    final next = DateTime(now.year, now.month, now.day, now.hour, now.minute + 1);
    _timer = Timer(next.difference(now), () {
      if (!mounted) return;
      setState(() {});
      _schedule();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, DateTime.now());
}
