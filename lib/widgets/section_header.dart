import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Letter-spaced grey section title ("LATER TODAY") with an optional action
/// on the right ("Schedule").
class SectionHeader extends StatelessWidget {
  const SectionHeader(
    this.title, {
    super.key,
    this.action,
    this.onAction,
    this.padding = const EdgeInsets.fromLTRB(20, 28, 20, 14),
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(child: Text(title.toUpperCase(), style: AppText.eyebrow(context.palette.textMuted))),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              behavior: HitTestBehavior.opaque,
              child: Text(
                action!,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: context.palette.text),
              ),
            ),
        ],
      ),
    );
  }
}
