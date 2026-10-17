import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_constants.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/launcher.dart';
import '../widgets/section_header.dart';
import 'about_screen.dart';
import 'prayer_request_screen.dart';
import 'settings_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final c = app.content;
    final donationUrl = app.config.donationUrl.trim();

    void push(Widget page) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: context.palette.headerGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Image.asset('assets/images/logo.png', height: 56),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Text(
                          'Need prayer? Our team would be honoured to pray with you.',
                          style: TextStyle(fontSize: 15, height: 1.35),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => push(const PrayerRequestScreen()),
                          icon: const Icon(Icons.volunteer_activism_rounded),
                          label: const Text('Prayer request'),
                        ),
                      ),
                      if (donationUrl.isNotEmpty) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: context.palette.goldFill,
                              foregroundColor: context.palette.onGold,
                            ),
                            onPressed: () => Launcher.url(context, donationUrl),
                            icon: const Icon(Icons.favorite_rounded),
                            label: const Text('Donate'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SectionHeader('Contact us'),
          if (c.phone.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.call_rounded),
              title: const Text('Call'),
              subtitle: Text(c.phone),
              onTap: () => Launcher.call(context, c.phone),
            ),
          if (c.whatsapp.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.chat_rounded),
              title: const Text('WhatsApp'),
              subtitle: Text(c.whatsapp),
              onTap: () => Launcher.whatsapp(context, c.whatsapp),
            ),
          if (c.email.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.email_rounded),
              title: const Text('Email'),
              subtitle: Text(c.email),
              onTap: () => Launcher.email(context, c.email, subject: AppConstants.appName),
            ),
          const SectionHeader('Follow us'),
          _SocialRow(urls: {
            Icons.smart_display_rounded: ('YouTube', c.youtubeUrl),
            Icons.facebook_rounded: ('Facebook', c.facebookUrl),
            Icons.photo_camera_rounded: ('Instagram', c.instagramUrl),
            Icons.language_rounded: ('Website', c.websiteUrl),
          }),
          const SectionHeader('App'),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text('About'),
            onTap: () => push(const AboutScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () => push(const SettingsScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.share_rounded),
            title: const Text('Share app'),
            onTap: () => SharePlus.instance.share(ShareParams(
              text: 'Watch ${AppConstants.appName} live, anywhere:\n${AppConstants.playStoreUrl}',
            )),
          ),
          ListTile(
            leading: const Icon(Icons.star_rate_rounded),
            title: const Text('Rate app'),
            onTap: () => _rate(context),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              '${AppConstants.appName} · v${app.appVersion}',
              style: TextStyle(color: context.palette.textMuted, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _rate(BuildContext context) async {
    // Prefer the Play Store app; fall back to the web listing.
    try {
      if (await launchUrl(Uri.parse(AppConstants.playStoreMarketUrl),
          mode: LaunchMode.externalApplication)) {
        return;
      }
    } catch (_) {}
    if (context.mounted) await Launcher.url(context, AppConstants.playStoreUrl);
  }
}

class _SocialRow extends StatelessWidget {
  const _SocialRow({required this.urls});
  final Map<IconData, (String, String)> urls;

  @override
  Widget build(BuildContext context) {
    final items = urls.entries.where((e) => e.value.$2.trim().isNotEmpty).toList();
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          for (final e in items)
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Launcher.url(context, e.value.$2),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: context.palette.surfaceHigh,
                        child: Icon(e.key, color: context.palette.gold),
                      ),
                      const SizedBox(height: 6),
                      Text(e.value.$1, style: TextStyle(fontSize: 12, color: context.palette.textMuted)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
