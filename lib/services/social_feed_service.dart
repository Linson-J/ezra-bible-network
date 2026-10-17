import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/social_post.dart';

/// Latest YouTube videos (public channel feed, no key needed) and Instagram
/// posts (Instagram API; needs an access token).
class SocialFeedService {
  SocialFeedService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _timeout = Duration(seconds: 15);

  Future<List<SocialPost>> youtube(String channelId) async {
    final res = await _client
        .get(Uri.https('www.youtube.com', '/feeds/videos.xml', {'channel_id': channelId}))
        .timeout(_timeout);
    if (res.statusCode != 200) throw http.ClientException('YouTube feed: HTTP ${res.statusCode}');
    return parseYouTubeFeed(utf8.decode(res.bodyBytes));
  }

  Future<List<SocialPost>> instagram(String token, {int limit = 12}) async {
    final res = await _client
        .get(
          Uri.https('graph.instagram.com', '/me/media', {
            'fields': 'id,caption,media_type,media_url,thumbnail_url,permalink,timestamp',
            'limit': '$limit',
            'access_token': token,
          }),
        )
        .timeout(_timeout);
    if (res.statusCode != 200) throw http.ClientException('Instagram: HTTP ${res.statusCode}');
    final data = (jsonDecode(res.body) as Map<String, dynamic>)['data'] as List? ?? const [];
    return [
      for (final m in data.cast<Map<String, dynamic>>())
        if ((m['thumbnail_url'] ?? m['media_url']) != null)
          SocialPost(
            id: '${m['id']}',
            title: (m['caption'] as String? ?? '').trim(),
            imageUrl: (m['thumbnail_url'] ?? m['media_url']) as String,
            url: m['permalink'] as String? ?? 'https://www.instagram.com/',
            published: DateTime.tryParse(m['timestamp'] as String? ?? ''),
            isVideo: m['media_type'] == 'VIDEO',
          ),
    ];
  }
}

/// Parses YouTube's Atom feed. Kept dependency-free: the feed's shape is
/// fixed and only four fields are needed.
List<SocialPost> parseYouTubeFeed(String xml) {
  String? tag(String entry, String pattern) => RegExp(pattern, dotAll: true).firstMatch(entry)?.group(1);
  final posts = <SocialPost>[];
  for (final m in RegExp(r'<entry>(.*?)</entry>', dotAll: true).allMatches(xml)) {
    final e = m.group(1)!;
    final id = tag(e, r'<yt:videoId>(.*?)</yt:videoId>');
    if (id == null) continue;
    posts.add(
      SocialPost(
        id: id,
        title: _unescape(tag(e, r'<title>(.*?)</title>') ?? ''),
        imageUrl: 'https://i.ytimg.com/vi/$id/hqdefault.jpg',
        url: tag(e, r'<link rel="alternate" href="(.*?)"/>') ?? 'https://www.youtube.com/watch?v=$id',
        published: DateTime.tryParse(tag(e, r'<published>(.*?)</published>') ?? ''),
        isVideo: true,
      ),
    );
  }
  return posts;
}

String _unescape(String s) => s
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .replaceAll('&quot;', '"')
    .replaceAll('&#39;', "'")
    .replaceAll('&apos;', "'")
    .replaceAll('&amp;', '&');
