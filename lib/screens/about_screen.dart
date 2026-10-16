import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_constants.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AppState>().content;
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(child: Image.asset('assets/images/logo.png', height: 120)),
          const SizedBox(height: 16),
          const Center(
            child: Text(AppConstants.appName,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.gold)),
          ),
          const SizedBox(height: 24),
          Text(c.about, style: const TextStyle(fontSize: 16, height: 1.6)),
          if (c.address.isNotEmpty) ...[
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.place_rounded, color: AppColors.gold),
                const SizedBox(width: 12),
                Expanded(child: Text(c.address, style: const TextStyle(color: AppColors.textMuted, height: 1.4))),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
