import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_constants.dart';
import '../config/env.dart';
import '../models/social_post.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/launcher.dart';
import '../widgets/app_bottom_bar.dart';
import '../widgets/ios_press.dart';
import '../widgets/lottie_badge.dart';
import '../widgets/section_header.dart';
import 'about_screen.dart';
import 'request_screen.dart';
import 'settings_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final c = app.content;
    final p = context.palette;
    final donationUrl = app.config.donationUrl.trim();

    void push(Widget page) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            CupertinoSliverRefreshControl(onRefresh: app.loadSocial),
            SliverList.list(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
                  child: Text('MORE', style: AppText.display(44, color: p.text)),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
                  child: Text(
                    'Send us a prayer or song request. Our team would be honoured to pray with you.',
                    style: TextStyle(fontSize: 16, height: 1.4, color: p.textMuted),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: IosPress(
                          child: FilledButton.icon(
                            onPressed: () => push(const RequestScreen(kind: RequestKind.prayer)),
                            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12)),
                            icon: const Icon(Icons.volunteer_activism_outlined, size: 20),
                            label: const Text('Prayer'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: IosPress(
                          child: OutlinedButton.icon(
                            onPressed: () => push(const RequestScreen(kind: RequestKind.song)),
                            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12)),
                            icon: const Icon(Icons.music_note_rounded, size: 20),
                            label: const Text('Song'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (c.youtubeUrl.isNotEmpty || c.instagramUrl.isNotEmpty) ...[
                  const SectionHeader('Follow us', padding: EdgeInsets.fromLTRB(18, 32, 18, 14)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      children: [
                        if (c.youtubeUrl.isNotEmpty)
                          Expanded(
                            child: _SocialButton(
                              logo: 'assets/youtube.png',
                              name: 'YouTube',
                              handle: '@${_handle(c.youtubeUrl).replaceFirst('@', '')}',
                              url: c.youtubeUrl,
                            ),
                          ),
                        if (c.youtubeUrl.isNotEmpty && c.instagramUrl.isNotEmpty) const SizedBox(width: 12),
                        if (c.instagramUrl.isNotEmpty)
                          Expanded(
                            child: _SocialButton(
                              logo: 'assets/instagram.png',
                              name: 'Instagram',
                              handle: '@${_handle(c.instagramUrl)}',
                              url: c.instagramUrl,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
                if (c.youtubeUrl.isNotEmpty || app.youtubeVideos.isNotEmpty) ...[
                  SectionHeader(
                    'Latest videos',
                    action: 'YouTube',
                    onAction: () => Launcher.social(context, c.youtubeUrl),
                    padding: const EdgeInsets.fromLTRB(18, 32, 18, 14),
                  ),
                  _Strip(
                    height: 214,
                    loading: app.socialLoading && app.youtubeVideos.isEmpty,
                    placeholderWidth: 130,
                    items: [for (final v in app.youtubeVideos.take(10)) _VideoCard(post: v)],
                    empty: _FollowCard(
                      animation: AppAnimation.likes,
                      title: 'EZRA BIBLE NETWORK',
                      subtitle: 'Worship, sermons and shorts on YouTube',
                      url: c.youtubeUrl,
                    ),
                  ),
                ],
                if (c.instagramUrl.isNotEmpty) ...[
                  SectionHeader(
                    'On Instagram',
                    action: 'Follow',
                    onAction: () => Launcher.social(context, c.instagramUrl),
                    padding: const EdgeInsets.fromLTRB(18, 28, 18, 14),
                  ),
                  _Strip(
                    height: 140,
                    loading: app.socialLoading && app.instagramPosts.isEmpty && Env.instagramAccessToken.isNotEmpty,
                    placeholderWidth: 140,
                    items: [
                      for (final post in app.instagramPosts) SizedBox(width: 140, child: _InstagramTile(post: post)),
                    ],
                    empty: _FollowCard(
                      animation: AppAnimation.social,
                      title: '@${_handle(c.instagramUrl)}',
                      subtitle: 'Verses, reels and moments from the ministry',
                      url: c.instagramUrl,
                    ),
                  ),
                ],
                const SectionHeader('Contact us', padding: EdgeInsets.fromLTRB(18, 32, 18, 8)),
                if (c.whatsapp.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.chat_rounded),
                    title: const Text('WhatsApp'),
                    subtitle: Text(c.whatsapp),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Launcher.whatsapp(context, c.whatsapp),
                  ),
                if (c.phone.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.call_rounded),
                    title: const Text('Call'),
                    subtitle: Text(c.phone),
                    onTap: () => Launcher.call(context, c.phone),
                  ),
                if (donationUrl.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.favorite_border_rounded),
                    title: const Text('Give'),
                    subtitle: const Text('Support the ministry'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Launcher.url(context, donationUrl),
                  ),
                const SectionHeader('App', padding: EdgeInsets.fromLTRB(18, 28, 18, 8)),
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded),
                  title: const Text('About'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => push(const AboutScreen()),
                ),
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('Settings'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => push(const SettingsScreen()),
                ),
                ListTile(
                  leading: const Icon(Icons.ios_share_rounded),
                  title: const Text('Share app'),
                  onTap: () => SharePlus.instance.share(
                    ShareParams(text: 'Watch ${AppConstants.appName} live, anywhere:\n${AppConstants.playStoreUrl}'),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.star_outline_rounded),
                  title: const Text('Rate app'),
                  onTap: () => _rate(context),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    '${AppConstants.appName} · v${app.appVersion}',
                    style: TextStyle(color: p.textMuted, fontSize: 12),
                  ),
                ),
                SizedBox(height: AppBottomBar.clearance(context)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _handle(String url) {
    final segments = Uri.tryParse(url)?.pathSegments.where((s) => s.isNotEmpty).toList() ?? const [];
    return segments.isEmpty ? 'instagram' : segments.first;
  }

  Future<void> _rate(BuildContext context) async {
    // Prefer the Play Store app; fall back to the web listing.
    try {
      if (await launchUrl(Uri.parse(AppConstants.playStoreMarketUrl), mode: LaunchMode.externalApplication)) {
        return;
      }
    } catch (_) {}
    if (context.mounted) await Launcher.url(context, AppConstants.playStoreUrl);
  }
}

class _Strip extends StatelessWidget {
  const _Strip({
    required this.height,
    required this.placeholderWidth,
    required this.loading,
    required this.items,
    required this.empty,
  });

  final double height;

  /// Width of the loading placeholders; items size themselves.
  final double placeholderWidth;
  final bool loading;
  final List<Widget> items;
  final Widget empty;

  @override
  Widget build(BuildContext context) {
    if (!loading && items.isEmpty) {
      return Padding(padding: const EdgeInsets.symmetric(horizontal: 18), child: empty);
    }
    final p = context.palette;
    final children = loading
        ? [
            for (var i = 0; i < 3; i++)
              SizedBox(
                width: placeholderWidth,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: p.tile(i), borderRadius: BorderRadius.circular(14)),
                ),
              ),
          ]
        : items;
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        itemCount: children.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => children[i],
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.url, required this.index});
  final String url;
  final int index;

  @override
  Widget build(BuildContext context) {
    final placeholder = ColoredBox(color: context.palette.tile(index));
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, __) => placeholder,
      errorWidget: (_, __, ___) => placeholder,
    );
  }
}

/// A Short as a tall 9:16 card with the title over it; other videos as a
/// 16:9 card with the title below.
class _VideoCard extends StatelessWidget {
  const _VideoCard({required this.post});
  final SocialPost post;

  @override
  Widget build(BuildContext context) {
    final short = post.url.contains('/shorts/');
    return IosPress(
      scale: 0.97,
      child: GestureDetector(
        onTap: () => Launcher.social(context, post.url),
        child: short ? _short(context) : _video(context),
      ),
    );
  }

  Widget _short(BuildContext context) {
    return SizedBox(
      width: 130,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _Thumb(url: post.imageUrl, index: 0),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.45, 1],
                  colors: [Colors.transparent, Color(0xCC000000)],
                ),
              ),
            ),
            const Positioned(
              right: 8,
              top: 8,
              child: Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 22),
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Text(
                post.title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600, height: 1.25),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _video(BuildContext context) {
    final p = context.palette;
    return SizedBox(
      width: 260,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _Thumb(url: post.imageUrl, index: 0),
                  Center(
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                      ),
                      child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            post.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, height: 1.25, color: p.text),
          ),
          if (post.published != null) ...[
            const SizedBox(height: 3),
            Text(timeAgo(post.published!.toLocal()), style: TextStyle(fontSize: 13, color: p.textMuted)),
          ],
        ],
      ),
    );
  }
}

class _InstagramTile extends StatelessWidget {
  const _InstagramTile({required this.post});
  final SocialPost post;

  @override
  Widget build(BuildContext context) {
    return IosPress(
      scale: 0.96,
      child: GestureDetector(
        onTap: () => Launcher.social(context, post.url),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Semantics(
                label: post.title,
                image: true,
                child: _Thumb(url: post.imageUrl, index: 1),
              ),
              if (post.isVideo)
                const Positioned(
                  right: 8,
                  top: 8,
                  child: Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 22),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shown when a feed is unavailable: the profile; tap to open it.
class _FollowCard extends StatelessWidget {
  const _FollowCard({required this.animation, required this.title, required this.subtitle, required this.url});

  final AppAnimation animation;
  final String title;
  final String subtitle;
  final String url;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return IosPress(
      scale: 0.97,
      child: GestureDetector(
        onTap: () => Launcher.social(context, url),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
          decoration: BoxDecoration(color: p.tile(0), borderRadius: BorderRadius.circular(18)),
          child: Row(
            children: [
              LottieBadge(animation, size: 60, background: Colors.white),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: p.text),
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(fontSize: 13, height: 1.3, color: p.textMuted)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: p.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

/// Brand logo, name and handle; opens the profile in its app.
class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.logo, required this.name, required this.handle, required this.url});

  final String logo;
  final String name;
  final String handle;
  final String url;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      button: true,
      label: 'Open $name',
      excludeSemantics: true,
      child: IosPress(
        scale: 0.95,
        child: GestureDetector(
          onTap: () => Launcher.social(context, url),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: p.tile(0),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: p.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(logo, width: 34, height: 34),
                    const Spacer(),
                    Icon(Icons.north_east_rounded, size: 18, color: p.textMuted),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: p.text),
                ),
                const SizedBox(height: 2),
                Text(
                  handle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.5, color: p.textMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
