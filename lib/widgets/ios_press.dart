import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// iPhone-style press feedback: the child shrinks and dims slightly while a
/// finger is down and springs back on release. Uses a [Listener], so it never
/// competes with the wrapped button's own tap handling.
class IosPress extends StatefulWidget {
  const IosPress({super.key, required this.child, this.scale = 0.95, this.enabled = true});

  final Widget child;
  final double scale;
  final bool enabled;

  @override
  State<IosPress> createState() => _IosPressState();
}

class _IosPressState extends State<IosPress> {
  bool _down = false;

  void _set(bool down) {
    if (widget.enabled && down != _down) setState(() => _down = down);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: _down ? const Duration(milliseconds: 90) : const Duration(milliseconds: 380),
        curve: _down ? Curves.easeOut : Curves.elasticOut,
        child: AnimatedOpacity(
          opacity: _down ? 0.82 : 1,
          duration: const Duration(milliseconds: 120),
          child: widget.child,
        ),
      ),
    );
  }
}

/// iOS switch in the app's light blue.
class IosSwitch extends StatelessWidget {
  const IosSwitch({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return CupertinoSwitch(value: value, onChanged: onChanged, activeTrackColor: context.palette.accentFill);
  }
}

/// iOS list row with a switch; tapping the row toggles it.
class IosSwitchTile extends StatelessWidget {
  const IosSwitchTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    required this.value,
    required this.onChanged,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: IosSwitch(value: value, onChanged: onChanged),
      onTap: () => onChanged(!value),
    );
  }
}

/// iOS alert. Returns the tapped action's value.
Future<T?> showIosAlert<T>(
  BuildContext context, {
  required String title,
  required String message,
  required List<(String label, T value, bool isDefault)> actions,
  bool dismissible = true,
}) {
  return showCupertinoDialog<T>(
    context: context,
    barrierDismissible: dismissible,
    builder: (ctx) => PopScope(
      canPop: dismissible,
      child: CupertinoAlertDialog(
        title: Text(title),
        content: Padding(padding: const EdgeInsets.only(top: 6), child: Text(message)),
        actions: [
          for (final a in actions)
            CupertinoDialogAction(isDefaultAction: a.$3, onPressed: () => Navigator.pop(ctx, a.$2), child: Text(a.$1)),
        ],
      ),
    ),
  );
}

/// iOS wheel time picker in a bottom sheet with Cancel / Done.
Future<TimeOfDay?> showIosTimePicker(BuildContext context, {required TimeOfDay initial, String title = ''}) {
  final p = context.palette;
  var picked = initial;
  return showCupertinoModalPopup<TimeOfDay>(
    context: context,
    builder: (ctx) => Container(
      height: 320,
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Row(
              children: [
                CupertinoButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('Cancel', style: TextStyle(color: p.accent)),
                ),
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w600, color: p.text, fontSize: 16),
                  ),
                ),
                CupertinoButton(
                  onPressed: () => Navigator.pop(ctx, picked),
                  child: Text(
                    'Done',
                    style: TextStyle(color: p.accent, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            Expanded(
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  brightness: Theme.of(context).brightness,
                  textTheme: CupertinoTextThemeData(dateTimePickerTextStyle: TextStyle(fontSize: 22, color: p.text)),
                ),
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: MediaQuery.of(context).alwaysUse24HourFormat,
                  initialDateTime: DateTime(2000, 1, 1, initial.hour, initial.minute),
                  onDateTimeChanged: (d) => picked = TimeOfDay(hour: d.hour, minute: d.minute),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
